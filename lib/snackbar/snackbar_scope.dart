import 'package:flutter/widgets.dart';

import 'snackbar_controller.dart';

class SnackbarScope extends InheritedWidget {
  final SnackbarController controller;

  const SnackbarScope({
    super.key,
    required this.controller,
    required super.child,
  });

  static SnackbarController of(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<SnackbarScope>();
    return scope!.controller;
  }

  @override
  bool updateShouldNotify(SnackbarScope oldWidget) => controller != oldWidget.controller;
}
