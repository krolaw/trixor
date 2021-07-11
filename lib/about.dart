import 'dart:math';

import 'package:flutter/material.dart';
import 'cardView.dart';
import 'logic.dart' as logic;

class HowToPlay extends StatelessWidget {
  late final List<int> s1, s2, s3;
  late final List<List<int>> a1, a2, a3, a4, a5, p1;

  HowToPlay() : super() {
    final r = Random();
    final c1 = r.nextInt(3);
    final c2 = r.nextInt(3);
    s1 = <int>[c1, c1, c1];
    s2 = <int>[0, 1, 2]..shuffle();
    s3 = <int>[c2, c2, (c2 + r.nextInt(2) + 1) % 3]..shuffle();

    final c3 = r.nextInt(3); // Symbol
    final c4 = r.nextInt(3); // Colour
    a1 = ([0, 1, 2]..shuffle()).map<List<int>>((c) => [c3, c]).toList();
    a2 = ([0, 1, 2]..shuffle()).map<List<int>>((c) => [c, c4]).toList();
    final c5 = [0, 1, 2]..shuffle();
    a3 = ([0, 1, 2]..shuffle()).map<List<int>>((c) => [c, c5[c]]).toList();
    final c6 = r.nextInt(3);
    final c7 = [c6, c6, (r.nextInt(2) + c6 + 1) % 3]..shuffle();
    a4 = ([0, 1, 2]..shuffle()).map<List<int>>((c) => [c7[c], c]).toList();
    final c8 = r.nextInt(3);
    final c9 = [c8, c8, (r.nextInt(2) + c8 + 1) % 3]..shuffle();
    a5 = ([0, 1, 2]..shuffle()).map<List<int>>((c) => [c, c9[c]]).toList();

    final c10 = [
      [0, 1, 2]..shuffle(),
      [0, 1, 2]..shuffle(),
      [0, 1, 2]..shuffle(),
      [0, 1, 2]..shuffle(),
      [0, 1, 2]..shuffle(),
    ];

    p1 = c10[0]
        .map<List<int>>((c) => [c, c10[1][c], c10[2][c], c10[3][c], c10[4][c]])
        .toList();
  }

  Widget _tileRow(BuildContext context, Iterable<List<int>> attrs, bool omit,
          bool isSet) =>
      Row(
        mainAxisSize: MainAxisSize.min,
        children: attrs
            .map<Widget>((c) => Expanded(
                child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                        margin: EdgeInsets.all(6),
                        width: 120,
                        height: 120,
                        child: CustomPaint(
                            painter: CardPainter(logic.Card.fromAttrs(c),
                                omit: omit))))))
            .followedBy([
          isSet
              ? Icon(
                  Icons.check,
                  color: Colors.lightGreen,
                  size: 50,
                )
              : Icon(
                  Icons.clear,
                  color: Colors.redAccent,
                  size: 50,
                )
        ]).toList(),
      );

  @override
  Widget build(BuildContext context) {
    final headStyle = Theme.of(context).textTheme.headline1;

    return Scaffold(
      appBar: AppBar(title: Text("TriXOR : About")),
      body: ListView(
        padding: EdgeInsets.all(6),
        children: [
          Text("Introduction", style: headStyle),
          Text(
            "This game is designed to exercise both the pattern matching"
            " (right) and logic (left) sides of the brain simultaneously,"
            " strengthening communication between the two.",
            textAlign: TextAlign.justify,
          ),
          Text("Goal", style: headStyle),
          Text(
            "Earn points by quickly finding sets of three tiles"
            " from the grid.",
            textAlign: TextAlign.justify,
          ),
          Text("Set Concepts", style: headStyle),
          Text("This IS a set (all the same colour):"),
          _tileRow(context, s1.map((e) => [e, -1, 0, 0]), true, true),
          Text("\nThis IS also a set (none the same colour):"),
          _tileRow(context, s2.map((e) => [e, -1, 0, 0]), true, true),
          Text("\nThis is NOT a set (two the same colour):"),
          _tileRow(context, s3.map((e) => [e, -1, 0, 0]), true, false),
          Text("Not so Fast", style: headStyle),
          Text(
              "TriXOR tiles use two or more properties (depending on level)."
              " All properties must follow the \"all or none\" rule, but a single set"
              " can be made up of both \"all\" and \"none\" properties.",
              textAlign: TextAlign.justify),
          _tileRow(context, a1, false, true),
          _tileRow(context, a2, false, true),
          _tileRow(context, a3, false, true),
          Text("\nColor mismatch"),
          _tileRow(context, a4, false, false),
          Text("\nSymbol mismatch"),
          _tileRow(context, a5, false, false),
          Text("Game Details", style: headStyle),
          ...<Widget>[
            ...[
              "There is exactly one set on the grid at any given time.",
              "When the set is found, its three tiles are replaced and the game continues.",
              "Each set increases the game score by between 1 and 30 points,"
                  " depending on the time taken to find it.",
              "Each set increases the remaining game time by between 0 and 20 seconds,"
                  " depending on the time taken to find it.",
              "If the reveal button is used to illuminate the current set,"
                  " the set will not increase points or time.",
              "In practise mode there is no time limit (the game never ends) and each set is worth 1 point."
            ].map((t) => Text(
                  t,
                  textAlign: TextAlign.justify,
                )),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                    "Depending on level, there are up to 5 changing properties:",
                    textAlign: TextAlign.justify),
                ...[
                  "Colour (" +
                      p1.map((c) => ["red", "green", "blue"][c[0]]).join(", ") +
                      ")",
                  "Symbol (" +
                      p1
                          .map((c) => ["curve", "point", "stand"][c[1]])
                          .join(", ") +
                      ")",
                  "Dots (" + p1.map((c) => [1, 2, 3][c[2]]).join(", ") + ")",
                  "Pattern (" +
                      p1
                          .map((c) => ["gradient", "solid", "striped"][c[3]])
                          .join(", ") +
                      ")",
                  "Corner (" +
                      p1
                          .map((c) => ["triangle", "square", "circle"][c[4]])
                          .join(", ") +
                      ")"
                ].map((c) => Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(" • "),
                          Expanded(child: Text(c, textAlign: TextAlign.justify))
                        ])),
                _tileRow(context, p1, false, true),
              ],
            )
          ].asMap().entries.map((c) => Container(
              padding: EdgeInsets.only(top: c.key == 0 ? 0 : 10),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(" ${c.key + 1}. "),
                Expanded(
                  child: c.value,
                )
              ]))),
          /*AspectRatio(
              aspectRatio: 1,
              child: CustomPaint(
                  size: Size(80, 80),
                  painter: CardPainter(logic.Card.fromAttrs([2, 0, 2, 0, 0]),
                      omit: false))),*/
          Text("Licences", style: headStyle),
          Text("This app depends on various libraries. Their licences can be"
              " viewed by clicking the button below."),
          TextButton(
              onPressed: () => showLicensePage(context: context),
              child: Text("View Licences"))
        ],
      )

      /*
# Introduction

This game is designed to exercise both the pattern matching (right) and logic (left) sides
of the brain simultaneously, strengthening communication between the two.

# Goal

Find a group of three tiles, where if two tiles share the same property, so must
the third. Sharing no properties is also valid. Depending on the game level,
tiles will have three to five properties (colour, shape, number, background and
pattern), all must follow the property rule.

These are groups:

Different: Shape, Number, Colour

Same: Shape
Different: Number, Colour

Same: Shape, Number
Different: Colour

These are not groups:

Colour Mismatch

Shape Mismatch

# Game Play
Your score and potentially your remaining time increases depending on how fast
you find each group. There is only ever one possible group on the screen at one
time. Once found, the three tiles are replaced and the game continues.,

# Created by
Richard Warburton of http://www.prototec.co.nz
      */
      ,
    );
  }
}
