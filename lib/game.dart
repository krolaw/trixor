import 'package:flutter/material.dart';
import 'board.dart';

class Game extends StatefulWidget {
  final int width, height, depth;

  Game(this.width, this.height, this.depth) : super() {
    print("width: $width, height: $height, depth: $depth");
  }

  @override
  _GameState createState() => _GameState();
}

class _GameState extends State<Game> {
  int score = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Center(
                child: OrientationBuilder(
                    builder: (context, o) =>
                        o.index == Orientation.landscape.index
                            ? Row(mainAxisSize: MainAxisSize.min, children: [
                                BoardView(
                                    widget.height, widget.width, widget.depth),
                                Column(children: [
                                  Text("Score:\n$score"),
                                ])
                              ])
                            : Column(mainAxisSize: MainAxisSize.min, children: [
                                BoardView(
                                    widget.width, widget.height, widget.depth),
                                Column(children: [
                                  Text("Score: $score"),
                                ])
                              ])))));
  }
}
