import 'dart:math';

import 'package:flutter/material.dart';
import 'board.dart';
import 'logic.dart' as logic;

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
  late logic.Board board;
  late List<CardView> cards;

  @override
  initState() {
    super.initState();
    board = logic.Board(widget.width * widget.height, widget.depth);
    CardPainter.mixer = List<int>.generate(5, (i) => i)..shuffle();
    CardPainter.ender =
        List<int>.generate(5 - widget.depth, (i) => Random().nextInt(3));
    cards = List<CardView>.generate(widget.width * widget.height,
        (i) => CardView(board.used[i], handleCardPress));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("TriXOR: $score")),
        body: Container(
            padding: EdgeInsets.only(top: 5),
            child: SafeArea(
                child: Center(
                    child: OrientationBuilder(
                        builder: (context, o) => o.index ==
                                Orientation.landscape.index
                            ? //Row(mainAxisSize: MainAxisSize.min, children: [
                            BoardView(widget.height, widget.width, board,
                                handleCardPress)
                            /*  Column(children: [
                                  Text("Score:\n$score"),
                                ])
                              ])*/
                            : //Column(mainAxisSize: MainAxisSize.min, children: [
                            BoardView(widget.width, widget.height, board,
                                handleCardPress)
                        /*Column(children: [
                                  Text("Score: $score"),
                                ])*/
                        //])
                        )))));
  }

  final selected = <CardViewState>[];

  void handleCardPress(CardViewState c) {
    if (selected.contains(c)) {
      selected.remove(c);
      return;
    }
    selected.add(c);

    if (selected.length == 3) {
      print(selected[0].card.toString() +
          " + " +
          selected[1].card.toString() +
          " = " +
          selected[0].card.match(selected[1].card).toString() +
          " ! " +
          selected[2].card.toString());

      if (selected[0].card.match(selected[1].card) == selected[2].card) {
        print("Pass");
        setState(() {
          score++;
        });
      } else {
        print("Fail");
      }
      selected.forEach((c) {
        c.select(false);
      });
      selected.clear();
    }
  }
}
