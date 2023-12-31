import 'package:flutter/material.dart';

class SlideUpBuilder extends StatefulWidget {
  final Widget? child;

  //builder
  final Widget Function(
      BuildContext, AnimationController controller, Widget? child) builder;
  final Duration duration;
  final AnimationController controller;

  const SlideUpBuilder(
      {Key? key,
      this.child,
      required this.builder,
      required this.controller,
      this.duration = const Duration(milliseconds: 500)})
      : super(key: key);

  @override
  State<SlideUpBuilder> createState() => _SlideUpBuilderState();
}

class _SlideUpBuilderState extends State<SlideUpBuilder> {
  late final Animation<double> _sizeFactor;

  @override
  void initState() {
    super.initState();
    _sizeFactor = CurvedAnimation(
            parent: widget.controller, curve: Curves.fastOutSlowIn)
        .drive(Tween<double>(begin: 1.0, end: 0.0));
  }
  @override
  Widget build(BuildContext context) {
    return SizeTransition(
        sizeFactor: _sizeFactor,
        // axis: Axis.vertical,
        axisAlignment: -1.0,
        child: widget.builder(context, widget.controller, widget.child));
  }
}
