import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trixor/highscores.dart';
import 'package:trixor/settings.dart';
import 'cardView.dart';
import 'logic.dart' as logic;
import 'animations.dart' as animation;
import 'package:wakelock/wakelock.dart';
import 'package:vibration/vibration.dart';

const startDuration = Duration(seconds: 10); //Duration(minutes: 3);
const maxDuration = Duration(minutes: 4);
const scoreDuration = 30;
const maxTimeAdd = Duration(seconds: 20);

class Game extends StatefulWidget {
  final int short, long, depth, level;
  final bool practise;

  Game(this.level, this.short, this.long, this.depth, this.practise) : super();

  @override
  _GameState createState() => _GameState();
}

class _GameState extends State<Game> with WidgetsBindingObserver {
  int score = 0;
  DateTime lastFound = DateTime.now();
  DateTime expiry = DateTime.now().add(startDuration);

  late Timer timer;
  bool timerShow = true;

  late logic.Board board;
  bool isAnimating = false;

  int shrinking = -1;
  int expanding = -1;

  List<logic.Card> replacements = [];
  List<int> showSet = [];
  bool replacing = false;

  bool _paused = false;

  static final birthday = DateTime(1977);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final now = DateTime.now();
    switch (state) {
      case AppLifecycleState.resumed:
        expiry = now.add(expiry.difference(birthday));
        lastFound = now.add(lastFound.difference(birthday));
        timer = setupTimer();
        setState(() {
          _paused = false;
        });
        break;
      default:
        if (_paused) break;
        setState(() {
          _paused = true;
        });
        timer.cancel();
        expiry = birthday.add(expiry.difference(now));
        lastFound = birthday.add(expiry.difference(now));
    }
  }

  gameOver() async {
    final name = widget.practise
        ? null
        : await highscores.isHighScore(widget.level, score);
    TextEditingController tc = TextEditingController(text: name);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Game Over", textScaleFactor: 1.5),
            content: Column(
                mainAxisSize: MainAxisSize.min,
                children: name != null
                    ? [
                        Text("High Score: $score"),
                        TextFormField(
                            decoration: InputDecoration(hintText: "Your name"),
                            autocorrect: false,
                            autofocus: true,
                            maxLength: 20,
                            controller: tc)
                      ]
                    : [Text("Score: $score")]),
            actions: [
              TextButton(
                  onPressed: () =>
                      finishHighscore(() => Navigator.pop(context), tc),
                  child: Text("Show Board")),
              TextButton(
                  child: Text("Exit"),
                  onPressed: () => finishHighscore(
                      () =>
                          Navigator.popUntil(context, (route) => route.isFirst),
                      tc))
            ],
          );
        });
  }

  finishHighscore(void Function() f, TextEditingController tc) async {
    if (tc.text.length > 0)
      await highscores.saveHighScore(widget.level, score, tc.text);
    f();
  }

  Timer setupTimer() {
    return widget.practise
        ? Timer(Duration.zero, () {})
        : Timer.periodic(const Duration(milliseconds: 250), (timer) {
            setState(() {
              var remainingTime = expiry.difference(DateTime.now());
              if (remainingTime <= Duration.zero) {
                remainingTime = Duration.zero;
                isAnimating = true;
                showSet = board.findSet();
                timer.cancel();
                Wakelock.disable();
                gameOver();
              }
              timerShow = (remainingTime.inSeconds >= 20) ||
                  (remainingTime.inMilliseconds % 1000 > 500);
            });
          });
  }

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    if (settings.fullscreen) SystemChrome.setEnabledSystemUIOverlays([]);
    Wakelock.enable();
    timer = setupTimer();

    if (widget.practise) timerShow = false;
    board = logic.Board(widget.short * widget.long, widget.depth);
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
    Wakelock.disable();
    WidgetsBinding.instance!.removeObserver(this);
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    final long = math.max(width, height);
    final short = math.min(width, height);

    final gap = math.min(
        long / (widget.long * 15 - 1), short / (widget.short * 15 - 1));

    final cols = short == width ? widget.short : widget.long;
    final rows = short == width ? widget.long : widget.short;

    final boardview = _paused
        ? Container(
            alignment: Alignment.center,
            child: Text("PAUSED", textScaleFactor: 2))
        : GridView(
            //padding: EdgeInsets.all(2 * gap / 3),
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              childAspectRatio: 1.0,
              mainAxisSpacing: gap / 3,
              crossAxisSpacing: gap / 3,
            ),
            children: List<Widget>.generate(board.used.length, (i) {
              Widget contain(CardPainter c) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(gap * 1.5),
                    border: Border.all(
                        width: gap / 6,
                        color: showSet.contains(i)
                            ? Colors.white
                            : Colors.transparent),
                  ),
                  padding: EdgeInsets.all(gap / 6),
                  child: CustomPaint(painter: c),
                );
              }

              if (replacing && selected.contains(i)) {
                if (replacements.length == 3) {
                  final index = selected.indexOf(i);
                  final r =
                      CustomPaint(painter: CardPainter(replacements[index]));
                  return animation.Success(
                      contain(CardPainter(board.used[i])),
                      r,
                      index == 0
                          ? () => setState(() {
                                isAnimating = false;
                                replacing = false;
                                board.replace(replacements, selected);
                                //print(board);
                                selected.clear();
                                lastFound = DateTime.now();
                              })
                          : () {});
                } else {
                  return animation.Fail(
                      contain(
                          CardPainter(board.used[i], fail: replacements[0])),
                      selected.indexOf(i) == 0
                          ? () => setState(() {
                                isAnimating = false;
                                replacing = false;
                                selected.clear();
                              })
                          : () {});
                }
              }

              if (i == expanding)
                return animation.Out(
                    contain(CardPainter(board.used[i])),
                    () => setState(() {
                          expanding = -1;
                          isAnimating = false;
                          selected.remove(i);
                        }));

              if (i == shrinking)
                return animation.In(
                    contain(CardPainter(board.used[i])),
                    () => setState(() {
                          shrinking = -1;
                          selected.add(i);
                          if (selected.length != 3) {
                            isAnimating = false;
                            return;
                          }
                          replacements = board.select(selected);
                          replacing = true;
                          if (replacements.length == 3) {
                            if (showSet.isEmpty) {
                              final now = DateTime.now();
                              final diff = now.difference(lastFound);
                              score += widget.practise
                                  ? 1
                                  : math.max(scoreDuration - diff.inSeconds, 1);
                              expiry = expiry.add(maxTimeAdd < diff
                                  ? Duration.zero
                                  : maxTimeAdd - diff);
                              if (expiry.difference(now) > maxDuration)
                                expiry = now.add(maxDuration);
                            }
                          } else {
                            Vibration.vibrate();
                          }
                          if (showSet.isNotEmpty) showSet = [];
                        }));

              if (selected.contains(i)) {
                final sc = Transform.scale(
                    scale: animation.zoom,
                    child: contain(CardPainter(board.used[i])));
                if (isAnimating) return sc;
                return GestureDetector(
                    onTap: () => setState(() {
                          isAnimating = true;
                          expanding = i;
                        }),
                    child: Container(color: Colors.transparent, child: sc));
              } else {
                if (isAnimating) return contain(CardPainter(board.used[i]));
                return GestureDetector(
                    onTap: () => setState(() {
                          isAnimating = true;
                          shrinking = i;
                        }),
                    child: Container(
                        color: Colors.transparent,
                        child: contain(CardPainter(board.used[i]))));
              }
            }));
    var remainingTime = expiry.difference(DateTime.now());
    return Scaffold(
        body: Container(
            child: SafeArea(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
          _Timer(
              remainingTime.inMilliseconds / maxDuration.inMilliseconds,
              gap * 3,
              score,
              timerShow,
              () => setState(() => showSet = board.findSet())),
          Expanded(
              child: Center(
                  child: AspectRatio(
                      aspectRatio: (cols * 15 - 1) / (rows * 15 - 1),
                      child: boardview))),
        ]))));
  }

  final selected = <int>[];
}

class _Timer extends StatelessWidget {
  final double fill, height;
  final int score;
  final bool show;
  final void Function() find;

  _Timer(this.fill, this.height, this.score, this.show, this.find);

  @override
  Widget build(BuildContext context) {
    final colour = () {
      if (!show) return Colors.transparent;
      final col = math.min(math.max((fill - 0.1) / 0.8, 0), 1);
      //return fromHSL(col / 3, 1, 0.4);

      return Color.fromARGB(
          255, (255 * (1 - col)).toInt(), (255 * col).toInt(), 0);
    }();

    return Stack(alignment: Alignment.center, children: [
      Container(
        height: height,
        width: double.infinity,
        transform: Matrix4(fill, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1),
        transformAlignment: Alignment.centerLeft,
        color: colour,
      ),
      Text(
        "TriXOR: $score ",
        textScaleFactor: 1.4,
      ),
      Align(
          alignment: Alignment.topLeft,
          child: IconButton(
              visualDensity:
                  VisualDensity(vertical: VisualDensity.minimumDensity),
              padding: EdgeInsets.zero,
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context))),
      Align(
          alignment: Alignment.topRight,
          child: IconButton(
            visualDensity:
                VisualDensity(vertical: VisualDensity.minimumDensity),
            padding: EdgeInsets.zero,
            icon: Icon(Icons.help_outline),
            onPressed: find,
          ))
    ]);
  }
}

/*Color fromHSL(double h, double s, double l) {
  final a = s * math.min(l, 1 - l);
  final double Function(double) f = (double n) {
    final k = (n + h * 12) % 12;
    return l - a * math.max(-1, math.min(math.min(k - 3, 9 - k), 1));
  };
  print("$h ${f(0)} ${f(8)} ${f(4)}");
  return Color.fromARGB(
      255, (255 * f(0)).toInt(), (255 * f(8)).toInt(), (255 * f(4)).toInt());
}*/
