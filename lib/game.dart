import 'dart:math';

import 'package:flutter/material.dart';
import 'cardView.dart';
import 'logic.dart' as logic;
import 'animations.dart' as animation;

const startDuration = Duration(minutes: 3);
const maxDuration = Duration(minutes: 4);
const scoreDuration = Duration(seconds: 30);
const maxTimeAdd = Duration(seconds: 30);

class Game extends StatefulWidget {
  final int short, long, depth;

  Game(this.short, this.long, this.depth) : super() {
    print("width: $short, height: $long, depth: $depth");
  }

  @override
  _GameState createState() => _GameState();
}

class _GameState extends State<Game> {
  int score = 0;
  DateTime lastFound = DateTime.now();
  DateTime expiry = DateTime.now().add(startDuration);
  late logic.Board board;
  bool isAnimating = false;

  int shrinking = -1;
  int expanding = -1;

  List<logic.Card> replacements = [];
  bool replacing = false;

  @override
  initState() {
    super.initState();
    board = logic.Board(widget.short * widget.long, widget.depth);
    CardPainter.mixer = List<int>.generate(5, (i) => i); //..shuffle();
    CardPainter.ender =
        List<int>.generate(5 - widget.depth, (i) => 0); //Random().nextInt(3));
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    final long = max(width, height);
    final short = min(width, height);

    final gap =
        min(long / (widget.long * 15 - 1), short / (widget.short * 15 - 1));

    final cols = short == width ? widget.short : widget.long;
    final rows = short == width ? widget.long : widget.short;

    /*print("");
    print("isAnimating: $isAnimating");
    print("expanding: $expanding");
    print("shrinking: $shrinking");
    print("selected $selected");
    print("isReplacing $replacing");*/

    return Scaffold(
        appBar: AppBar(title: Text("TriXOR: $score")),
        body: Container(
            padding: EdgeInsets.only(top: 5),
            child: SafeArea(
                child: Center(
                    child: AspectRatio(
                        aspectRatio: (cols * 15 - 1) / (rows * 15 - 1),
                        child: GridView(
                            padding: EdgeInsets.zero,
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: cols,
                              childAspectRatio: 1.0,
                              mainAxisSpacing: gap,
                              crossAxisSpacing: gap,
                            ),
                            children:
                                List<Widget>.generate(board.used.length, (i) {
                              final c = CustomPaint(
                                  painter: CardPainter(board.used[i]));

                              if (replacing && selected.contains(i)) {
                                if (replacements.length == 3) {
                                  final index = selected.indexOf(i);
                                  if (index == 0) {
                                    final now = DateTime.now();
                                    final diff = now.difference(lastFound);
                                    score += max(
                                        (scoreDuration - diff).inSeconds, 1);
                                    expiry.add(maxTimeAdd < diff
                                        ? Duration.zero
                                        : maxTimeAdd - diff);
                                    if (expiry.difference(now) > maxDuration)
                                      expiry = now.add(maxDuration);
                                  }
                                  final r = CustomPaint(
                                      painter:
                                          CardPainter(replacements[index]));
                                  return animation.Success(
                                      c,
                                      r,
                                      index == 0
                                          ? () => setState(() {
                                                isAnimating = false;
                                                replacing = false;
                                                board.replace(
                                                    replacements, selected);
                                                //print(board);
                                                selected.clear();
                                                lastFound = DateTime.now();
                                              })
                                          : () {});
                                } else {
                                  return animation.Fail(
                                      c,
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
                                    c,
                                    () => setState(() {
                                          expanding = -1;
                                          isAnimating = false;
                                          selected.remove(i);
                                        }));

                              if (i == shrinking)
                                return animation.In(
                                    c,
                                    () => setState(() {
                                          shrinking = -1;
                                          selected.add(i);
                                          if (selected.length != 3) {
                                            isAnimating = false;
                                            return;
                                          }
                                          replacements = board.select(selected);
                                          replacing = true;
                                        }));

                              if (selected.contains(i)) {
                                final sc = Transform.scale(
                                    scale: animation.zoom, child: c);
                                if (isAnimating) return sc;
                                return GestureDetector(
                                    onTap: () => setState(() {
                                          isAnimating = true;
                                          expanding = i;
                                        }),
                                    child: Container(
                                        color: Colors.transparent, child: sc));
                              } else {
                                if (isAnimating) return c;
                                return GestureDetector(
                                    onTap: () => setState(() {
                                          isAnimating = true;
                                          shrinking = i;
                                        }),
                                    child: Container(
                                        color: Colors.transparent, child: c));
                              }
                            })))))));
  }

  final selected = <int>[];
}
