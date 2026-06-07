import 'package:flutter/material.dart';

import 'package:nampack/navigation/nampack_page_route.dart';
import 'package:nampack/navigation/transition_type.dart';

extension NavigatorUtils on NavigatorState {
  Future<T?> pushPage<T>(
    Widget page, {
    required NamPackPushPageParams params,
  }) async {
    return push(
      params.buildPageRoute(page),
    );
  }

  Future<T?> pushPageReplacement<T>(
    Widget page, {
    required NamPackPushPageParams params,
  }) async {
    return pushReplacement(
      params.buildPageRoute(page),
    );
  }

  Future<T?> pushPageReplacementAll<T>(
    Widget page, {
    required NamPackPushPageParams params,
  }) async {
    return pushAndRemoveUntil(
      params.buildPageRoute(page),
      (_) => false,
    );
  }
}

class NamPackPushPageParams {
  final Transition transition;
  final int durationInMs;
  final Curve curve;
  final bool opaque;
  final bool fullscreenDialog;
  final bool popGesture;
  final bool maintainState;

  const NamPackPushPageParams({
    this.transition = Transition.cupertino,
    this.durationInMs = 300,
    this.curve = Curves.easeOut,
    this.opaque = true,
    this.fullscreenDialog = false,
    this.popGesture = false,
    required this.maintainState,
  });

  NamPackPageRoute<T> buildPageRoute<T>(Widget page) {
    return NamPackPageRoute<T>(
      pageBuilder: (context) => page,
      maintainState: maintainState,
      transitionDuration: Duration(milliseconds: durationInMs),
      reverseTransitionDuration: Duration(milliseconds: (durationInMs * 0.8).round()),
      transition: transition,
      curve: curve,
      opaque: opaque,
      fullscreenDialog: fullscreenDialog,
      popGesture: popGesture,
    );
  }
}
