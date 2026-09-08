import 'package:flutter/material.dart';

import 'package:nampack/reactive/class/rx_base.dart';
import 'package:nampack/reactive/class/rxn_fallback.dart';

/// Listens to a reactive class and callback builder with the main listenable.
class ObxOClass<C extends RxBaseCore<T>, T> extends StatelessWidget {
  final C rx;
  final Widget Function(BuildContext context, C object) builder;

  const ObxOClass({super.key, required this.rx, required this.builder});

  @override
  StatelessElement createElement() => _RxOListenerBuilder(rx, this);

  @override
  Widget build(BuildContext context) => builder(context, rx);
}

/// Listens to a reactive class and callback builder with the value inside.
class ObxORaw<T> extends StatelessWidget {
  final RxBaseCore<T> rx;
  final Widget Function(T value) builder;

  const ObxORaw({super.key, required this.rx, required this.builder});

  @override
  StatelessElement createElement() => _RxOListenerBuilder(rx, this);

  @override
  Widget build(BuildContext context) => builder(rx.value);
}

/// Same as [ObxORaw] with additional context parameter in the callback.
///
/// equivalent to:
/// ```dart
/// Builder(
///   builder: (context) => ObxORaw(
///     rx: rx,
///     builder: (value) => child,
///   ),
/// );
/// ```
class ObxO<T> extends StatelessWidget {
  final RxBaseCore<T> rx;
  final Widget Function(BuildContext context, T value) builder;

  const ObxO({super.key, required this.rx, required this.builder});

  @override
  StatelessElement createElement() => _RxOListenerBuilder(rx, this);

  @override
  Widget build(BuildContext context) => builder(context, rx.value);
}

/// Listens to a reactive class and callback builder with the value inside and a fallback.
class ObxOFRaw<T> extends StatelessWidget {
  final RxnF<T> rx;
  final Widget Function(T? value, T fallback) builder;

  const ObxOFRaw({super.key, required this.rx, required this.builder});

  @override
  StatelessElement createElement() => _RxOListenerBuilder(rx, this);

  @override
  Widget build(BuildContext context) => builder(rx.value, rx.fallback);
}

/// Same as [ObxOFRaw] with additional context parameter in the callback and a fallback.
class ObxOF<T> extends StatelessWidget {
  final RxnF<T> rx;
  final Widget Function(BuildContext context, T? valuevalue, T fallback) builder;

  const ObxOF({super.key, required this.rx, required this.builder});

  @override
  StatelessElement createElement() => _RxOListenerBuilder(rx, this);

  @override
  Widget build(BuildContext context) => builder(context, rx.value, rx.fallback);
}

/// Listens to [rx] but rebuilds only when [selector] yields a different value.
class ObxOSelect<T, S> extends StatelessWidget {
  final RxBaseCore<T> rx;
  final S Function(T value) selector;
  final Widget Function(BuildContext context, S selected) builder;

  const ObxOSelect({super.key, required this.rx, required this.selector, required this.builder});

  @override
  StatelessElement createElement() => _RxOSelectListenerBuilder<T, S>(rx, this);

  @override
  Widget build(BuildContext context) => builder(context, selector(rx.value));
}

class _RxOSelectListenerBuilder<T, S> extends StatelessElement {
  final RxBaseCore<T> rx;
  late S _selected;

  _RxOSelectListenerBuilder(this.rx, ObxOSelect<T, S> super.widget);

  @override
  ObxOSelect<T, S> get widget => super.widget as ObxOSelect<T, S>;

  @override
  Widget build() => widget.builder(this, _selected);

  void _updateWidget() {
    if (!mounted) return;
    final newSelected = widget.selector(rx.value);
    if (newSelected == _selected) return;
    _selected = newSelected;
    markNeedsBuild();
  }

  @override
  void mount(Element? parent, Object? newSlot) {
    _selected = widget.selector(rx.value);
    rx.addListener(_updateWidget);
    super.mount(parent, newSlot);
  }

  @override
  void update(ObxOSelect<T, S> newWidget) {
    _selected = newWidget.selector(rx.value);
    super.update(newWidget);
  }

  @override
  void unmount() {
    super.unmount();
    rx.removeListener(_updateWidget);
  }
}

class _RxOListenerBuilder<T> extends StatelessElement {
  final RxBaseCore<T> rx;
  _RxOListenerBuilder(this.rx, super.widget);

  void _updateWidget() {
    if (mounted) {
      markNeedsBuild();
    }
  }

  @override
  void mount(Element? parent, Object? newSlot) {
    rx.addListener(_updateWidget);
    super.mount(parent, newSlot);
  }

  @override
  void unmount() {
    super.unmount();
    rx.removeListener(_updateWidget);
  }
}
