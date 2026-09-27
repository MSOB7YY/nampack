import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:nampack/core/main_utils.dart';
import 'package:nampack/snackbar/snackbars_manager.dart';

import 'snackbar_enum.dart';
import 'snackbar_scope.dart';
import 'snackbar_widget.dart';

class SnackbarController {
  final NamSnackBar snackbar;
  SnackbarController(this.snackbar);

  final _transitionCompleter = Completer();
  Future<void> get future => _transitionCompleter.future;

  late final AnimationController _controller;

  late final AnimationController _countdownController;

  Animation<double> get remainingTimeFraction => _countdownController;

  AnimationController? _dismissHintController;

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

    _countdownController = _createCountdownController();
    if (snackbar.isDismissible && snackbar.dismissHint) _dismissHintController = _createDismissHintController();

    _overlayEntry = _createOverlayEntry(snackbar, animation);
    _overlayState.insert(_overlayEntry!);

    _controller.forward();
    _restartCountdown(snackbar.duration);
    SnackbarManager.add(close);
  }

  void _pauseCountdown() => _countdownController.stop();

  void _restartCountdown(Duration duration) {
    if (_transitionCompleter.isCompleted) return;
    _countdownController.duration = duration;
    _countdownController.reverse(from: 1.0);
  }

  void restartDuration() => _restartCountdown(snackbar.duration);

  void addDuration(Duration extraDuration) {
    final totalDuration = _countdownController.duration!;
    final remainingDuration = totalDuration * _countdownController.value;
    _restartCountdown(remainingDuration + extraDuration);
  }

  void _handleCountdownStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.dismissed) close();
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

  AnimationController _createCountdownController() {
    final countdownController = AnimationController(
      value: 1.0,
      debugLabel: '$runtimeType.countdown',
      vsync: _overlayState,
    );
    countdownController.addStatusListener(_handleCountdownStatusChanged);
    return countdownController;
  }

  AnimationController _createDismissHintController() {
    return AnimationController(
      duration: NamSnackBar.kDismissHintDuration,
      debugLabel: '$runtimeType.dismissHint',
      vsync: _overlayState,
    );
  }

  OverlayEntry _createOverlayEntry(Widget child, Animation<Alignment> animation) {
    final scopedChild = SnackbarScope(
      controller: this,
      child: child,
    );
    final snack = snackbar.isDismissible ? _getDismissibleSnack(scopedChild) : scopedChild;
    final dismissHintController = _dismissHintController;
    final dismissHintAnimation = dismissHintController == null ? null : _dismissHintTween.animate(dismissHintController);
    final snackWithHint = dismissHintAnimation == null
        ? snack
        : _SnackbarDismissHint(
            animation: dismissHintAnimation,
            top: snackbar.top,
            child: snack,
          );
    return OverlayEntry(
      builder: (context) => Semantics(
        focused: false,
        container: true,
        explicitChildNodes: true,
        child: AlignTransition(
          alignment: animation,
          child: Builder(
            builder: (_) => Listener(
              onPointerDown: (_) => _pauseCountdown(),
              onPointerUp: (_) => _restartCountdown(snackbar.duration),
              onPointerCancel: (_) => _restartCountdown(snackbar.duration),
              child: snackWithHint,
            ),
          ),
        ),
      ),
      maintainState: false,
      opaque: false,
    );
  }

  static final _dismissHintPushCurve = CurveTween(curve: Curves.easeOutCubic);
  static final _dismissHintReturnCurve = CurveTween(curve: Curves.easeOutBack);
  static final _dismissHintPushTween = Tween(begin: 0.0, end: 1.0).chain(_dismissHintPushCurve);
  static final _dismissHintReturnTween = Tween(begin: 1.0, end: 0.0).chain(_dismissHintReturnCurve);
  static final _dismissHintTween = TweenSequence<double>([
    TweenSequenceItem(tween: ConstantTween(0.0), weight: 15.0),
    TweenSequenceItem(tween: _dismissHintPushTween, weight: 35.0),
    TweenSequenceItem(tween: _dismissHintReturnTween, weight: 50.0),
  ]);

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
        _dismissHintController?.forward();
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
    _pauseCountdown();

    if (withAnimations) {
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
    _countdownController.dispose();
    _dismissHintController?.dispose();
  }
}

// by claude
class _SnackbarDismissHint extends AnimatedWidget {
  final Animation<double> animation;
  final bool top;
  final Widget child;

  const _SnackbarDismissHint({
    required this.animation,
    required this.top,
    required this.child,
  }) : super(listenable: animation);

  static const _kDistance = 10.0;

  @override
  Widget build(BuildContext context) {
    final distance = animation.value * _kDistance;
    final dy = top ? -distance : distance;
    return Transform.translate(
      offset: Offset(0.0, dy),
      child: child,
    );
  }
}
