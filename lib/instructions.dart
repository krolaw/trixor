import 'package:flutter/material.dart';
import 'cardView.dart';
import 'logic.dart' as logic;

class Instructions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cardMatch = <logic.Card>[
      logic.Card.fromAttrs([0, 1, 2]),
      logic.Card.fromAttrs([0, 2, 0]),
      logic.Card.fromAttrs([0, 0, 1]),
    ];

    final headStyle = Theme.of(context).textTheme.headline1;

    return Scaffold(
      appBar: AppBar(title: Text("TriXOR : About")),
      body: ListView(
        padding: EdgeInsets.all(6),
        children: [
          Text("Introduction", style: headStyle),
          //Divider(),
          Text(
            "This game is designed to exercise both the pattern matching"
            " (right) and logic (left) sides of the brain simultaneously,"
            " strengthening communication between the two.",
            textAlign: TextAlign.justify,
          ),
          //Divider(),
          Text("Goal", style: headStyle),
          //Divider(),
          Text(
            "Find a set of three cards, where any shared property is shared by all three."
            " i.e. zero, one, or three of cards in the set can be green, but not two.\n\n"
            "Depending on level there are up to 5 changing properties:\n"
            " - Colour (red, green, blue)\n"
            " - Symbol (curve, point, stand)\n"
            " - Dots (1, 2, 3)\n"
            " - Pattern (gradient, solid, striped)\n"
            " - Corner (triangle, circle, square)\n\n"
            "Tip: Differences matter as much as similarities.\n",
            textAlign: TextAlign.justify,
          ),
          Row(
            children: cardMatch
                .map((c) => Container(
                    margin: EdgeInsets.all(6),
                    width: 80,
                    height: 80,
                    child: CustomPaint(painter: CardPainter(c))))
                .toList(),
          ),

          Text("Game Play", style: headStyle),

          //Divider(),
          Text(
            "Score and time accumulates based on how quickly a set is found. "
            "Once found, the three cards are replaced and the game continues. "
            "The game finishes when time runs out. ",
            textAlign: TextAlign.justify,
          ),
        ],
      )

      /*
# Introduction

This game is designed to exercise both the pattern matching (right) and logic (left) sides
of the brain simultaneously, strengthening communication between the two.

# Goal

Find a group of three cards, where if two cards share the same property, so must
the third. Sharing no properties is also valid. Depending on the game level,
cards will have three to five properties (colour, shape, number, background and
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
time. Once found, the three cards are replaced and the game continues.,

# Created by
Richard Warburton of http://www.prototec.co.nz
      */
      ,
    );
  }
}
