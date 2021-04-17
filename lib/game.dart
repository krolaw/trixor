import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'cardView.dart';
import 'logic.dart' as logic;
import 'animations.dart' as animation;

const startDuration = Duration(minutes: 3);
const maxDuration = Duration(minutes: 4);
const scoreDuration = 30;
const maxTimeAdd = Duration(seconds: 20);

class Game extends StatefulWidget {
  final int short, long, depth;
  final bool practise;

  Game(this.short, this.long, this.depth, this.practise) : super();

  @override
  _GameState createState() => _GameState();
}

class _GameState extends State<Game> {
  int score = 0;
  DateTime lastFound = DateTime.now();
  DateTime expiry = DateTime.now().add(startDuration);
  Duration remainingTime = startDuration;

  late Timer timer;
  bool timerShow = true;

  late logic.Board board;
  bool isAnimating = false;

  int shrinking = -1;
  int expanding = -1;

  List<logic.Card> replacements = [];
  List<int> showSet = [];
  bool replacing = false;

  @override
  initState() {
    super.initState();
    timer = widget.practise
        ? Timer(Duration.zero, () {})
        : Timer.periodic(const Duration(milliseconds: 250), (timer) {
            setState(() {
              remainingTime = expiry.difference(DateTime.now());
              if (remainingTime <= Duration.zero) {
                remainingTime = Duration.zero;
                isAnimating = true;
                showSet = board.findSet();
                timer.cancel();
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Game Over", textScaleFactor: 1.5),
                        content: Text("Score: $score"),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text("Show Board")),
                          TextButton(
                              child: Text("Exit"),
                              onPressed: () => Navigator.popUntil(
                                  context, (route) => route.isFirst)),
                        ],
                      );
                    });
              }
              timerShow = (remainingTime.inSeconds >= 20) ||
                  (remainingTime.inMilliseconds % 1000 > 500);
            });
          });

    if (widget.practise) timerShow = false;
    board = logic.Board(widget.short * widget.long, widget.depth);
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
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

    final boardview = GridView(
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
                      if (replacements.length == 3 && showSet.isEmpty) {
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

    return Scaffold(
        //appBar: AppBar(title: Text("TriXOR: $score")),
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
              //child: Container(
              //    color: Colors.lightBlue,
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
        //textAlign: TextAlign.end,
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
