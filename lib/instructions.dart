import 'package:flutter/material.dart';

class Instructions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final headStyle = Theme.of(context).textTheme.headline6;

    return Scaffold(
      appBar: AppBar(title: Text("TriXOR : About")),
      body: ListView(
        padding: EdgeInsets.all(6),
        children: [
          Text("Introduction", style: headStyle),
          Divider(),
          Text(
            "This game is designed to exercise both the pattern matching"
            " (right) and logic (left) sides of the brain simultaneously,"
            " strengthening communication between the two.",
            textAlign: TextAlign.justify,
          ),
          Divider(),
          Text("How To Play", style: headStyle),
          Divider(),
          Text(
            "Find three cards that have the same properties in common. Therefore"
            " a group must have:\n"
            " - All same or all different background colour; and\n"
            " - All same or all different lexicons; and\n"
            " - All same or all different circle counts; and\n"
            " - All same or all different background shading; and\n"
            " - All same or all different bottom left corner shape\n\n"
            "This means a set of three cards can share nothing in common.\n"
            "Tip: Look for differences rather than similaries.",
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
