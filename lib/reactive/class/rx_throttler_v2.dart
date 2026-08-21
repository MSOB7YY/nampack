import 'dart:async';

import 'package:nampack/nampack.dart';
import 'package:nampack/reactive/class/rx_updater_mixin.dart';

/// {@template nampack.reactive.rx_throttler}
/// Throttler mixin to prevent rapid updates.
/// A 20ms throttler can reduce \~3k refreshs down to \~250 (\~12x more efficient),
/// Preventing the ui from going crazy lagging.
/// {@endtemplate}
mixin RxThrottlerMixin<T> on RxOUpdatersMixin<T> {
  Duration _duration = NamPackDefaults.effectiveThrottleDuration;

  set duration(Duration value) {
    if (value == _duration) return;
    _duration = value;

    final wasActive = _refreshTimer != null;
    _ensureRefreshTimerCancelled();
    if (wasActive) _ensureRefreshTimerActive();
  }

  DataValidCallback<T>? isDataValid;

  bool _markedDirty = false;

  /// Throttler for refreshes.
  Timer? _refreshTimer;
  void _ensureRefreshTimerActive() {
    // ignore: prefer_conditional_assignment
    if (_refreshTimer == null) {
      // _refreshIfDirty(); // cuz usually has 1 item so looks weird
      _refreshTimer = Timer.periodic(
        _duration,
        (_) => _refreshIfDirty(),
      );
    }
  }

  void _ensureRefreshTimerCancelled() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    _refreshIfDirty();
  }

  void _refreshIfDirty() {
    if (_markedDirty) {
      super.refresh();
      _markedDirty = false;
    }
  }

  void _onRefreshAbsorb() {
    _markedDirty = true;

    if (isDataValid?.call(value) ?? true) {
      _ensureRefreshTimerActive();
    } else {
      _ensureRefreshTimerCancelled();
    }
  }

  @override
  void close() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    super.close();
  }

  @override
  void refresh() {
    _onRefreshAbsorb();
  }
}
