import 'dart:math';

import 'package:flutter/material.dart';

const zoom = 0.7;

class In extends StatelessWidget {
  final Widget card;
  final void Function() finished;

  In(this.card, this.finished) : super();

  @override
  Widget build(BuildContext context) => Animator(
      (double t) =>
          Transform.scale(scale: 1.0 - (1 - zoom) * t, child: this.card),
      const Duration(milliseconds: 100),
      finished);
}

class Out extends StatelessWidget {
  final Widget card;
  final void Function() finished;

  Out(this.card, this.finished) : super();

  @override
  Widget build(BuildContext context) => Animator(
      (double t) =>
          Transform.scale(scale: zoom + (1 - zoom) * t, child: this.card),
      const Duration(milliseconds: 100),
      finished);
}

class Success extends StatelessWidget {
  final Widget card, replacement;
  final void Function() finished;

  Success(this.card, this.replacement, this.finished) : super();

  @override
  Widget build(BuildContext context) => Animator(
      (double t) => Transform.scale(
          scale: zoom + (1 - zoom) * t,
          child: Transform.rotate(
            angle: t * 4 * pi,
            child: t > 0.5 ? this.replacement : this.card,
          )),
      const Duration(milliseconds: 500),
      finished);
}

class Fail extends StatelessWidget {
  final Widget card;
  final void Function() finished;

  Fail(this.card, this.finished) : super();

  @override
  Widget build(BuildContext context) => Animator(
      (double t) => Transform.scale(
          scale: zoom + (1 - zoom) * t,
          child: Transform.rotate(
              angle: sin(((t * 4) % 1.0) * 2 * pi) *
                  pi /
                  6 *
                  (1 - t), // 60 degree shake
              child: this.card)),
      const Duration(milliseconds: 1000),
      finished);
}

class Animator extends StatefulWidget {
  final void Function() finished;
  final Widget Function(double) transformer;
  final Duration duration;

  Animator(this.transformer, this.duration, this.finished) : super();

  @override
  _ShrinkState createState() => _ShrinkState();
}

class _ShrinkState extends State<Animator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _controller.forward().then<void>((_) => widget.finished());
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) =>
          widget.transformer(_controller.value),
      child: null);
}
