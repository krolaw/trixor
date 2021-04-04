import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'logic.dart' as logic;
import 'dart:ui' as ui;

class BoardView extends StatefulWidget {
  final int rows, cols;
  final logic.Board board;

  BoardView(this.cols, this.rows, int depth)
      : board = logic.Board(cols * rows, depth) {
    print("Board called");
  }

  @override
  _BoardState createState() => _BoardState();
}

class _BoardState extends State<BoardView> {
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    final gap = math.min(
        height / (widget.rows * 15 - 1), width / (widget.cols * 15 - 1));

    /*if (cards.length == 0) {
      final rnd = math.Random();
      final count = math.pow(3, widget.depth) as int;
      cards =
          List.generate(widget.rows * widget.cols, (i) => rnd.nextInt(count));
    }*/

    return AspectRatio(
        aspectRatio: (widget.cols * 15 - 1) / (widget.rows * 15 - 1),
        //width: gap * (widget.cols * 10 - 1),
        child: GridView(
            padding: EdgeInsets.zero,
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: widget.cols,
              childAspectRatio: 1.0,
              mainAxisSpacing: gap,
              crossAxisSpacing: gap,
            ),
            children: List<Widget>.generate(
              widget.board.used.length,
              (i) => CardView(widget.board.used[i]),
            )));
  }
}

class CardView extends StatefulWidget {
  final logic.Card card;

  CardView(this.card);

  @override
  _CardViewState createState() => _CardViewState();
}

class _CardViewState extends State<CardView> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 70),
        vsync: this,
        value: 1,
        upperBound: 1,
        lowerBound: 0.7);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.linear);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.card.selected ^= true;
        widget.card.selected ? _controller.reverse() : _controller.forward();
      },
      child: ScaleTransition(
          scale: _animation,
          child: CustomPaint(painter: CardPainter(widget.card))),
    );
  }
}

var colours = [
  Colors.red,
  Colors.green,
  Colors.blue,
];

class CardPainter extends CustomPainter {
  final List<int> attrs;

  CardPainter(logic.Card card)
      : attrs = <int>[
          ...card.attrs,
          ...List<int>.filled(5 - card.attrs.length, 0)
        ];

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint();

    final colour = colours[attrs[0]];

    canvas.clipRRect(RRect.fromLTRBR(0, 0, size.width, size.height,
        Radius.elliptical(size.width / 10, size.height / 10)));

    switch (attrs[3]) {
      case 0:
        /*p.shader = ui.Gradient.linear(
            Offset(size.width * 0.7, size.height * 0.7),
            Offset(size.width * 0.75, size.height * 0.75),
            [colour, Colors.black],
            [0.7, 0.7]);*/
        /*p.shader = ui.Gradient.linear(
            Offset(size.width * 0.66, size.height * 0.75),
            Offset(size.width * 0.75, size.height * 0.66),
            [colour, Colors.black],
            [0.6, 0.6],
            TileMode.repeated);*/

        p.shader = ui.Gradient.linear(Offset(0, 0), Offset(size.width, 0),
            [colour, Colors.black], [0.5, 0.95]);
        break;
      case 1:
        /*p.shader = ui.Gradient.linear(
            Offset(0, size.height * 0.7),
            Offset(size.width, size.height * 0.3),
            [colour, Colors.black, Colors.black, colour],
            [0.45, 0.45, 0.7, 0.7]);*/

        p.color = colour;
        break;
      case 2:
        /*p.shader = ui.Gradient.linear(Offset(0, 0), Offset(size.width, 0),
            [colour, Colors.black], [0.7, 0.7]);*/

        p.shader = ui.Gradient.linear(
            Offset(0, 0),
            Offset(size.width * 0.20, size.height * 0.10),
            [colour, Colors.black],
            [0.6, 0.6],
            TileMode.repeated);
        break;
    }

    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, size.height), p);

    final pp = Paint()..color = Colors.black;

    switch (this.attrs[4]) {
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

    /*canvas
      ..translate(size.width / 2, size.height / 2)
      ..rotate(this.attrs[4] * math.pi / 2)
      ..translate(-size.width / 2, -size.height / 2);*/

    final sw = 3 * size.longestSide / 20;
    final Path path = Path()..moveTo(sw, size.height - sw);
    switch (attrs[1]) {
      case 0:
        path.lineTo(size.width - sw, sw);
        path.lineTo(size.width - sw, size.height - sw);
        break;
      case 1:
        path.lineTo(size.width - sw, size.height - sw);
        path.relativeMoveTo(-1.5 * sw, 0);
        path.lineTo(size.width - 2.5 * sw, sw);
        break;
      case 2:
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
    }

    final width = size.longestSide / 10;

    canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = Colors.white
          ..strokeWidth = width);

    final o = width * 1.2;
    for (int i = 0; i < attrs[2] + 1; i++)
      canvas.drawCircle(Offset(width + o / 2, width + o / 2 + i * o * 1.5),
          o / 2, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
