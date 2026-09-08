import 'package:nampack/nampack.dart';

class RxUpdaters {
  RxUpdaters();

  late final _updaters = <NamCallback>{};

  /// snapshot iterated by [notifyAll], so listeners can (un)subscribe mid-notify.
  /// rebuilt lazily only after the set changes.
  List<NamCallback>? _snapshot;

  void add(NamCallback updater) {
    if (_updaters.add(updater)) _snapshot = null;
  }

  bool contains(NamCallback updater) => _updaters.contains(updater);

  bool remove(NamCallback updater) {
    final removed = _updaters.remove(updater);
    if (removed) _snapshot = null;
    return removed;
  }

  void notifyAll() {
    final updaters = _snapshot ??= _updaters.toList(growable: false);
    final int length = updaters.length;
    for (int i = 0; i < length; i++) {
      updaters[i]();
    }
  }

  void clear() {
    _updaters.clear();
    _snapshot = null;
  }
}
