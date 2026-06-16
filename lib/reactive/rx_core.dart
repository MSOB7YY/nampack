import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:nampack/nampack.dart';
import 'package:nampack/reactive/class/rx_updaters.dart';

class NotifyData {
  final NamCallback updater;
  final List<VoidCallback> disposers;

  const NotifyData({
    required this.updater,
    required this.disposers,
  });
}

class RxAutoManager {
  static NotifyData? _updaterData;
  static void pullObservers<T>(RxUpdaters updaters) {
    final updaterData = _updaterData;
    if (updaterData == null) return;
    if (!updaters.contains(updaterData.updater)) {
      updaters.add(updaterData.updater);
      updaterData.disposers.add(() => updaters.remove(updaterData.updater));
    }
  }

  static T append<T>(NotifyData updaterData, T Function() builder) {
    _updaterData = updaterData;
    final result = builder();
    assert(_checkImroper(updaterData));
    _updaterData = null;
    return result;
  }

  static bool _checkImroper(NotifyData updaterData) {
    if (updaterData.disposers.isEmpty) {
      throw const ObxError();
    }
    return true;
  }
}

class ObxError implements Exception {
  const ObxError();

  @override
  String toString() => "you forgot to use reactive variable under this widget.";
}
