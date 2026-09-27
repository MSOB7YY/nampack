import 'package:flutter/material.dart';

import 'package:nampack/nampack.dart';

class NamSnackBar extends StatelessWidget {
  final bool top;
  final EdgeInsetsGeometry margin;
  final AlignmentGeometry alignment;
  final Duration duration;
  final Duration animationDuration;
  final Duration? animationreverseDuration;
  final Curve forwardAnimationCurve;
  final Curve reverseAnimationCurve;
  final bool isDismissible;
  final bool dismissHint;
  final void Function(SnackbarStatus status)? onStatusChanged;
  final Widget child;

  static const kDismissHintDuration = Duration(milliseconds: 700);

  const NamSnackBar({
    super.key,
    this.top = true,
    this.margin = EdgeInsets.zero,
    this.alignment = Alignment.topCenter,
    this.duration = const Duration(seconds: 3),
    required this.animationDuration,
    this.animationreverseDuration,
    this.forwardAnimationCurve = Curves.linear,
    this.reverseAnimationCurve = Curves.linear,
    this.isDismissible = true,
    this.dismissHint = false,
    this.onStatusChanged,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: top ? EdgeInsets.only(top: MediaQuery.paddingOf(context).top) : EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      bottom: !top,
      top: top,
      child: Stack(
        children: [
          Padding(
            padding: margin,
            child: child,
          ),
        ],
      ),
    );
  }
}
