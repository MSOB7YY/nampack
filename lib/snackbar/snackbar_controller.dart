import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:nampack/core/main_utils.dart';
import 'package:nampack/snackbar/snackbars_manager.dart';

import 'snackbar_enum.dart';
import 'snackbar_widget.dart';

class SnackbarController {
  final NamSnackBar snackbar;
  SnackbarController(this.snackbar);

  final _transitionCompleter = Completer();
  Future<void> get future => _transitionCompleter.future;

  Timer? _closeTimer;

  late final AnimationController _controller;

  OverlayEntry? _overlayEntry;

  OverlayState _overlayState = OverlayState();

  Future<void> show() {
    final c = nampack.overlayContext;
    if (c == null) {
      WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback(
        (timeStamp) {
          if (nampack.overlayContext != null) _showOverlay(nampack.overlayContext!);
        },
      );
    } else {
      _showOverlay(c);
    }
    return future;
  }

  void _showOverlay(BuildContext? overlayContext) {
    if (overlayContext != null) _overlayState = Overlay.of(overlayContext);

    _controller = _createAnimationController();
    final animation = _createAnimation(snackbar.top);
    animation.addStatusListener(_handleStatusChanged);

    _overlayEntry = _createOverlayEntry(snackbar, animation);
    _overlayState.insert(_overlayEntry!);

    _controller.forward();
    _initTimer();
    SnackbarManager.add(close);
  }

  void _cancelTimer() => _closeTimer?.cancel();

  void _initTimer() {
    _cancelTimer();
    _closeTimer = Timer(snackbar.duration, close);
  }

  Animation<Alignment> _createAnimation(bool top) {
    assert(!_transitionCompleter.isCompleted, 'Cannot create a animation from a disposed snackbar');
    Alignment begin;
    Alignment end;
    if (top) {
      begin = const Alignment(-1.0, -2.0);
      end = const Alignment(-1.0, -1.0);
    } else {
      begin = const Alignment(-1.0, 2.0);
      end = const Alignment(-1.0, 1.0);
    }
    return AlignmentTween(begin: begin, end: end).animate(
      CurvedAnimation(
        parent: _controller,
        curve: snackbar.forwardAnimationCurve,
        reverseCurve: snackbar.reverseAnimationCurve,
      ),
    );
  }

  AnimationController _createAnimationController() {
    assert(!_transitionCompleter.isCompleted, 'Cannot create a animationController from a disposed snackbar');
    return AnimationController(
      duration: snackbar.animationDuration,
      reverseDuration: snackbar.animationreverseDuration,
      debugLabel: '$runtimeType',
      vsync: _overlayState,
    );
  }

  OverlayEntry _createOverlayEntry(Widget child, Animation<Alignment> animation) {
    return OverlayEntry(
      builder: (context) => Semantics(
        focused: false,
        container: true,
        explicitChildNodes: true,
        child: AlignTransition(
          alignment: animation,
          child: Builder(
            builder: (_) => Listener(
              onPointerDown: (_) => _cancelTimer(),
              onPointerUp: (_) => _initTimer(),
              onPointerCancel: (_) => _initTimer(),
              child: snackbar.isDismissible ? _getDismissibleSnack(child) : child,
            ),
          ),
        ),
      ),
      maintainState: false,
      opaque: false,
    );
  }

  Widget _getDismissibleSnack(Widget child) {
    final direction = snackbar.top ? DismissDirection.up : DismissDirection.down;
    return Dismissible(
      direction: direction,
      movementDuration: Duration.zero,
      resizeDuration: null,
      key: const Key('dismissible'),
      onDismissed: (_) => _close(withAnimations: false, dismissedBySwipe: true),
      child: Dismissible(
        direction: DismissDirection.horizontal,
        movementDuration: Duration.zero,
        resizeDuration: null,
        key: const Key('dismissible_horizontal'),
        onDismissed: (_) => _close(withAnimations: false, dismissedBySwipe: true),
        child: child,
      ),
    );
  }

  void _handleStatusChanged(AnimationStatus status) {
    SnackbarStatus currentStatus;

    switch (status) {
      case AnimationStatus.completed:
        currentStatus = SnackbarStatus.open;
        _overlayEntry?.opaque = false;
        break;

      case AnimationStatus.forward:
        currentStatus = SnackbarStatus.opening;
        break;

      case AnimationStatus.reverse:
        currentStatus = SnackbarStatus.closing;
        _overlayEntry?.opaque = false;
        break;

      case AnimationStatus.dismissed:
        assert(_overlayEntry?.opaque == false);
        currentStatus = SnackbarStatus.closed;
        _close(withAnimations: false, dismissedBySwipe: false);
        break;
    }

    if (snackbar.onStatusChanged != null) snackbar.onStatusChanged!(currentStatus);
  }

  Future<void> close({bool withAnimations = true}) async {
    return _close(withAnimations: withAnimations, dismissedBySwipe: false);
  }

  Future<void> _close({bool withAnimations = true, required bool dismissedBySwipe}) async {
    if (_transitionCompleter.isCompleted) return;
    _transitionCompleter.complete();
    SnackbarManager.remove(close);

    if (withAnimations) {
      _closeTimer?.cancel();

      if (dismissedBySwipe) {
        await Future.delayed(const Duration(milliseconds: 200), _controller.reset);
      } else {
        await _controller.reverse();
      }
    }

    _overlayEntry?.remove();
    SchedulerBinding.instance.addPostFrameCallback((_) => _overlayEntry?.dispose());
    _overlayEntry = null;
    _controller.dispose();
  }
}
