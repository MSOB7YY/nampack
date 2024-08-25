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

  List<VoidCallback>? disposers = [];

  void _updateWidget() {
    if (disposers != null) {
      markNeedsBuild();
    }
  }

  @override
  Widget build() => RxNotifier.append(NotifyData(disposers: disposers!, updater: _updateWidget), super.build);

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
