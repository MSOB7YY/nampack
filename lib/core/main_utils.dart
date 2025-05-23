import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:nampack/extensions/build_context_ext.dart';
import 'package:nampack/snackbar/snackbars_manager.dart';

final nampack = _NamPackUtils();

class _NamPackUtils {
  final rootNavigatorKey = GlobalKey<NavigatorState>();

  void closeAllSnackbars() => SnackbarManager.closeAll();

  BuildContext? get context => rootNavigatorKey.currentContext;
  BuildContext? get overlayContext => rootNavigatorKey.currentState?.overlay?.context;

  ThemeData get theme => context == null ? ThemeData.fallback() : context!.theme;
  TextTheme get textTheme => theme.textTheme;
  Brightness get brightness => context == null ? Brightness.light : Theme.brightnessOf(context!);
  bool get isDarkMode => brightness == Brightness.dark;

  EdgeInsets? get padding => context == null ? null : MediaQuery.paddingOf(context!);
  EdgeInsets? get viewPadding => context == null ? null : MediaQuery.viewPaddingOf(context!);
  EdgeInsets? get viewInsets => context == null ? null : MediaQuery.viewInsetsOf(context!);

  ui.PlatformDispatcher get platform => WidgetsFlutterBinding.ensureInitialized().platformDispatcher;
  ui.FlutterView? get platformView => platform.implicitView;

  Locale? get deviceLocale => platform.locale;
  double get pixelRatio => platformView!.devicePixelRatio;
  Size get size => platformView!.physicalSize / pixelRatio;
  double get width => size.width;
  double get height => size.height;
  double get statusBarHeight => platformView!.padding.top;
  double get bottomBarHeight => platformView!.padding.bottom;

  /// Android Q+
  bool get isPlatformDarkMode => (platform.platformBrightness == Brightness.dark);
}
