import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trixor/highscores.dart';
import 'package:trixor/settings.dart';
import 'cardView.dart';
import 'logic.dart' as logic;
import 'sounds.dart';
import 'animations.dart' as animation;
import 'package:wakelock/wakelock.dart';
import 'package:vibration/vibration.dart';

const startDuration = Duration(minutes: 3);
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

enum cardAnimation { shrinking, expanding, still }

class _GameState extends State<Game> with WidgetsBindingObserver {
  int score = 0;
  DateTime lastFound = DateTime.now();
  DateTime expiry = DateTime.now().add(startDuration);

  late Timer timer;
  bool timerShow = true;

  late logic.Board board;
  bool isAnimating = false;

  List<cardAnimation> cardState = [];
  List<logic.Card> replacements = [];
  List<int> showSet = [];
  bool replacing = false;

  bool _paused = false;

  static final birthday = DateTime(1977);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        unpause();
        break;
      default:
        pause();
    }
  }

  void unpause() {
    final now = DateTime.now();
    expiry = now.add(expiry.difference(birthday));
    lastFound = now.add(lastFound.difference(birthday));
    timer = setupTimer();
    setState(() {
      _paused = false;
    });
  }

  void pause() {
    if (_paused) return;
    final now = DateTime.now();
    setState(() {
      _paused = true;
    });
    timer.cancel();
    expiry = birthday.add(expiry.difference(now));
    lastFound = birthday.add(expiry.difference(now));
  }

  void pauseToggle() => _paused ? unpause() : pause();

  gameOver() async {
    final name = widget.practise
        ? null
        : await highscores.isHighScore(widget.level, score);
    TextEditingController tc = TextEditingController(text: name);
    if (name != null)
      sound.win.play();
    else
      sound.lose.play();
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return SimpleDialog(
            insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            title: Text(name != null ? "High Score: $score" : "Score: $score",
                textScaleFactor: 1),
            titlePadding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            contentPadding: EdgeInsets.fromLTRB(6, 0, 6, 0),
            children: [
              if (name != null)
                TextFormField(
                    //scrollPadding: EdgeInsets.zero,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                        isCollapsed: true,
                        isDense: true,
                        counter: Container(),
                        hintText: "Your name"),
                    autocorrect: false,
                    //enableSuggestions: false,
                    autofocus: name == "",
                    maxLength: 20,
                    controller: tc),
              Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                        onPressed: () =>
                            finishHighscore(() => Navigator.pop(context), tc),
                        child: Padding(
                            child: Text("Show Board"),
                            padding: EdgeInsets.symmetric(horizontal: 8))),
                    SizedBox(width: 8),
                    TextButton(
                        child: Text("Exit"),
                        onPressed: () => finishHighscore(
                            () => Navigator.popUntil(
                                context, (route) => route.isFirst),
                            tc))
                  ])
            ],
          );

          // return AlertDialog(
          //   title: Text(name != null ? "High Score: $score" : "Score: $score",
          //       textScaleFactor: 1),
          //   titlePadding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          //   contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 0),
          //   scrollable: true,
          //   insetPadding: EdgeInsets.symmetric(horizontal: 40, vertical: 0),
          //   buttonPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          //   actionsPadding: EdgeInsets.zero,
          //   content: TextFormField(
          //       //scrollPadding: EdgeInsets.zero,
          //       keyboardType: TextInputType.name,
          //       decoration: InputDecoration(
          //           isCollapsed: true,
          //           isDense: true,
          //           counter: Container(),
          //           hintText: "Your name"),
          //       autocorrect: false,
          //       enableSuggestions: false,
          //       autofocus: name == "",
          //       maxLength: 20,
          //       controller: tc),
          //   actions: [
          //     TextButton(
          //         onPressed: () =>
          //             finishHighscore(() => Navigator.pop(context), tc),
          //         child: Padding(
          //             child: Text("Show Board"),
          //             padding: EdgeInsets.symmetric(horizontal: 8))),
          //     TextButton(
          //         child: Text("Exit"),
          //         onPressed: () => finishHighscore(
          //             () =>
          //                 Navigator.popUntil(context, (route) => route.isFirst),
          //             tc))
          //   ],
          // );
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
              if (remainingTime.inSeconds < 20 && timerShow) sound.alarm.play();
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
    cardState = List<cardAnimation>.generate(
        board.count, (index) => cardAnimation.still);
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
    Wakelock.disable();
    WidgetsBinding.instance!.removeObserver(this);
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  }

  final selected = <int>[];

  @override
  Widget build(BuildContext context) {
    var remainingTime = expiry.difference(DateTime.now());

    return Scaffold(
        drawer: SettingsDrawer(true),
        body: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          _Timer(remainingTime.inMilliseconds / maxDuration.inMilliseconds, 32,
              score, timerShow, () {
            if (_paused) return;
            sound.cheat.play();
            setState(() => showSet = board.findSet());
          }, pauseToggle),
          Expanded(child:
              Center(child: LayoutBuilder(builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;

            final long = math.max(width, height);
            final short = math.min(width, height);

            final gap = math.min(
                long / (widget.long * 45 - 1), short / (widget.short * 45 - 1));

            final cols = short == width ? widget.short : widget.long;
            final rows = short == width ? widget.long : widget.short;

            return _paused
                ? Container(
                    alignment: Alignment.center,
                    child: Text("PAUSED", textScaleFactor: 2))
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                        2 * rows - 1,
                        (r) => r % 2 == 0
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: List<Widget>.generate(
                                    2 * cols - 1,
                                    (c) => c % 2 == 0
                                        ? SizedBox(
                                            width: gap * 44,
                                            height: gap * 44,
                                            child: tile(
                                                r ~/ 2 * cols + c ~/ 2, gap))
                                        : SizedBox(width: gap)))
                            : SizedBox(height: gap)));
          })))
        ]));
  }

  Widget tile(int i, double gap) {
    Widget contain(CardPainter c) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(gap * 1.6 * 3),
          border: Border.all(
              width: gap / 2,
              color: showSet.contains(i) ? Colors.white : Colors.transparent),
        ),
        padding: EdgeInsets.all(gap / 2),
        child: CustomPaint(painter: c),
      );
    }

    if (replacing && selected.contains(i)) {
      final index = selected.indexOf(i);
      if (replacements.length == 3) {
        final r = CustomPaint(painter: CardPainter(replacements[index]));

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
            contain(CardPainter(board.used[i], fail: replacements[0])),
            index == 0
                ? () => setState(() {
                      isAnimating = false;
                      replacing = false;
                      selected.clear();
                    })
                : () {});
      }
    }

    if (cardState[i] == cardAnimation.expanding) {
      selected.remove(i);
      return animation.Out(
          contain(CardPainter(board.used[i])),
          () => setState(() {
                cardState[i] = cardAnimation.still;
              }));
    }
    if (cardState[i] == cardAnimation.shrinking)
      return animation.In(
          contain(CardPainter(board.used[i])),
          () => setState(() {
                cardState[i] = cardAnimation.still;
                selected.add(i);
                if (selected.length != 3) {
                  return;
                }
                replacements = board.select(selected);
                replacing = true;
                isAnimating = true;
                if (replacements.length == 3) {
                  sound.right.play();
                  if (showSet.isEmpty) {
                    final now = DateTime.now();
                    final diff = now.difference(lastFound);
                    score += widget.practise
                        ? 1
                        : math.max(scoreDuration - diff.inSeconds, 1);
                    expiry = expiry.add(
                        maxTimeAdd < diff ? Duration.zero : maxTimeAdd - diff);
                    if (expiry.difference(now) > maxDuration)
                      expiry = now.add(maxDuration);
                  } else
                    showSet = [];
                } else {
                  sound.wrong.play();
                  if (settings.vibrate) Vibration.vibrate();
                }
              }));

    if (selected.contains(i)) {
      final sc = Transform.scale(
          scale: animation.zoom, child: contain(CardPainter(board.used[i])));
      if (isAnimating) return sc;
      return GestureDetector(
          onTap: () => setState(() {
                //isAnimating = true;
                cardState[i] = cardAnimation.expanding;
              }),
          child: Container(color: Colors.transparent, child: sc));
    } else {
      if (isAnimating) return contain(CardPainter(board.used[i]));
      return GestureDetector(
          onTap: () => setState(() {
                //isAnimating = true;
                cardState[i] = cardAnimation.shrinking;
              }),
          child: Container(
              color: Colors.transparent,
              child: contain(CardPainter(board.used[i]))));
    }
  }
}

class _Timer extends StatelessWidget {
  final double fill, height;
  final int score;
  final bool show;
  final void Function() find, pauseToggle;

  _Timer(this.fill, this.height, this.score, this.show, this.find,
      this.pauseToggle);

  @override
  Widget build(BuildContext context) {
    final colour = () {
      if (!show) return Colors.transparent;
      final col = math.min(math.max((fill - 0.1) / 0.8, 0), 1);
      //return fromHSL(col / 3, 1, 0.4);

      return Color.fromARGB(
          255, (255 * (1 - col)).toInt(), (255 * col).toInt(), 0);
    }();

    return SizedBox(
        height: 32,
        child: Stack(alignment: Alignment.centerLeft, children: [
          Container(
            height: height,
            width: double.infinity,
            transform:
                Matrix4(fill, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1),
            transformAlignment: Alignment.centerLeft,
            color: colour,
          ),
          Padding(
              padding: EdgeInsets.only(left: 48),
              child: Text(
                "TriXOR: $score ",
                textScaleFactor: 1.4,
              )),
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
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Builder(
                    builder: (context) => IconButton(
                        visualDensity: VisualDensity(
                            vertical: VisualDensity.minimumDensity),
                        padding: EdgeInsets.zero,
                        icon: Icon(Icons.settings),
                        onPressed: () => Scaffold.of(context).openDrawer())),
                IconButton(
                  visualDensity:
                      VisualDensity(vertical: VisualDensity.minimumDensity),
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.pause),
                  onPressed: pauseToggle,
                ),
                IconButton(
                  visualDensity:
                      VisualDensity(vertical: VisualDensity.minimumDensity),
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.help_outline),
                  onPressed: find,
                )
              ])),
        ]));
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
