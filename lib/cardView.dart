import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'logic.dart' as logic;
import 'dart:ui' as ui;
import 'settings.dart';

class CardView extends StatefulWidget {
  final int gap;
  final logic.Card card;
  final bool illuminate;
  final bool Function()? onTap;

  CardView(this.card, this.gap, {this.illuminate = false, this.onTap});

  @override
  _CardViewState createState() => _CardViewState();
}

class _CardViewState extends State<CardView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.gap * 1.5),
        border: Border.all(
            width: widget.gap / 6,
            color: widget.illuminate ? Colors.white : Colors.transparent),
      ),
      padding: EdgeInsets.all(widget.gap / 6),
      child: CustomPaint(painter: CardPainter(widget.card)),
    );
  }
}

class CardPainter extends CustomPainter {
  //static late List<int> mixer;
  //static late List<int> ender;

  final List<int> attrs;
  final List<int> fail;
  final failCol = Colors.grey;
  final failCol2 = Colors.grey.shade300;
  final failCol3 = Colors.grey.shade700;
  CardPainter(logic.Card card, {bool omit = false, logic.Card? fail})
      : attrs = [...card.attrs],
        fail = [...(fail?.attrs ?? [])] {
    if (!omit) for (int i = card.attrs.length; i < 5; i++) attrs.add(0);
    for (int i = this.fail.length; i < attrs.length; i++) this.fail.add(-1);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint();

    final colour = (fail[0] != -1 && fail[0] != attrs[0])
        ? failCol2
        : settings.colours[attrs[0]];

    canvas.clipRRect(RRect.fromLTRBR(0, 0, size.width, size.height,
        Radius.elliptical(size.width / 10, size.height / 10)));

    var gradAttr = attrs.length > 3 ? attrs[3] : 1;
    if (gradAttr == 1 && fail[3] != -1 && fail[3] != 1) {
      gradAttr = fail[3];
    }

    switch (gradAttr) {
      case 0:
        p.shader = ui.Gradient.linear(Offset(0, 0), Offset(size.width, 0), [
          colour,
          (attrs.length > 3 && fail[3] != -1 && fail[3] != attrs[3])
              ? failCol3
              : Colors.black
        ], [
          0.5,
          0.95
        ]);
        break;
      case 1:
        p.color = colour;
        break;
      case 2:
        p.shader = ui.Gradient.linear(
            Offset(0, 0),
            Offset(size.width * 0.20, size.height * 0.10),
            [
              colour,
              (fail[3] != -1 && fail[3] != attrs[3]) ? failCol3 : Colors.black
            ],
            [0.6, 0.6],
            TileMode.repeated);
        break;
    }

    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, size.height), p);

    final pp = Paint()
      ..color = attrs.length > 4
          ? (fail[4] != -1 && fail[4] != attrs[4] ? failCol3 : Colors.black)
          : Colors.black;

    switch (attrs.length > 4 ? this.attrs[4] : 0) {
      case 0:
        final t = Path()..moveTo(0, size.height);
        t.relativeLineTo(size.width / 2, 0);
        t.lineTo(0, size.height / 2);
        t.close();
        canvas.drawPath(t, pp);
        break;
      case 1:
        canvas.drawRect(
            Rect.fromLTRB(0, size.height * 0.6, size.width * 0.4, size.height),
            pp);
        break;
      case 2:
        canvas.drawOval(
            Rect.fromCenter(
                center: Offset(0, size.height),
                width: size.width * .8,
                height: size.height * .8),
            pp);
        break;
    }

    final sw = 3 * size.longestSide / 20;
    final width = size.longestSide / 10;

    if (attrs.length > 1) {
      final Path path = Path()..moveTo(sw, size.height - sw);
      switch (attrs.length > 1 ? attrs[1] : -1) {
        case 0:
          path.arcTo(
              Rect.fromLTRB(
                  -size.width + 3 * sw, sw, size.width - sw, size.height - sw),
              math.pi / 2,
              -math.pi / 2,
              true);
          path.arcTo(
              Rect.fromLTRB(
                  -size.width + 6 * sw, sw, size.width - sw, size.height - sw),
              0,
              -math.pi / 2,
              true);
          break;
        case 1:
          path.lineTo(size.width - sw, sw);
          path.lineTo(size.width - sw, size.height - sw);
          break;
        case 2:
          path.lineTo(size.width - sw, size.height - sw);
          path.relativeMoveTo(-1.5 * sw, 0);
          path.lineTo(size.width - 2.5 * sw, sw);
          break;
      }

      canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..color =
                (fail[1] != -1 && fail[1] != attrs[1]) ? failCol : Colors.white
            ..strokeWidth = width);
    }

    if (attrs.length > 2) {
      final o = width * 1.2;
      for (int i = 0; i < attrs[2] + 1; i++)
        canvas.drawCircle(
            Offset(width + o / 2, width + o / 2 + i * o * 1.5),
            o / 2,
            Paint()
              ..color = (fail[2] != -1 && fail[2] != attrs[2])
                  ? failCol
                  : Colors.white);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
