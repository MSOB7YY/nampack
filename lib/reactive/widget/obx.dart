import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:nampack/nampack.dart';

class Obx extends StatelessWidget {
  final Widget Function(BuildContext context) builder;
  const Obx(this.builder, {super.key});

  @override
  StatelessElement createElement() => _RxObserver(this);

  @override
  Widget build(BuildContext context) => builder(context);
}

class _RxObserver extends StatelessElement {
  _RxObserver(super.widget);

  /// local builds only: `--dart-define=NAMPACK_HIGHLIGHT_NON_REACTIVE_OBX=true`
  static const _shouldHighlightNonReactive = bool.fromEnvironment('NAMPACK_HIGHLIGHT_NON_REACTIVE_OBX');

  List<VoidCallback>? disposers = [];

  void _updateWidget() {
    if (disposers != null) {
      markNeedsBuild();
    }
  }

  @override
  Widget build() {
    final disposers = this.disposers!;
    final notifyData = NotifyData(disposers: disposers, updater: _updateWidget);
    final child = RxAutoManager.append(notifyData, super.build);
    if (_shouldHighlightNonReactive && disposers.isEmpty) {
      return _NonReactiveHighlight(
        child: child,
      );
    }
    return child;
  }

  @override
  void unmount() {
    super.unmount();
    final disposers = this.disposers;
    if (disposers != null) {
      for (final disposer in disposers) {
        disposer();
      }
      disposers.clear();
      this.disposers = null;
    }
  }
}

class _NonReactiveHighlight extends StatelessWidget {
  final Widget child;

  const _NonReactiveHighlight({required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      alignment: Alignment.center,
      children: [
        child,
        const Positioned.fill(
          child: IgnorePointer(
            child: ColoredBox(
              color: Color(0x33F44336),
              child: Align(
                child: Text(
                  '!! NON-REACTIVE !!',
                  textDirection: TextDirection.ltr,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
