import 'package:nampack/nampack.dart';
import 'package:nampack/reactive/class/rx_updaters.dart';

mixin RxUpdatersMixin<T> on RxOUpdatersMixin<T> {
  @override
  T get valueR {
    RxAutoManager.pullObservers(_updaters!);
    return super.value;
  }
}

mixin RxOUpdatersMixin<T> on RxBase<T> {
  late RxUpdaters? _updaters = RxUpdaters();

  @override
  void addListener(NamCallback listener) {
    assert(_checkNotDisposed());
    _updaters!.add(listener);
  }

  @override
  void removeListener(NamCallback listener) {
    _updaters?.remove(listener);
  }

  @override
  void refresh() {
    _updaters?.notifyAll();
  }

  @override
  void close() {
    _updaters?.clear();
    _updaters = null;
  }

  @override
  void reInit() {
    _updaters = RxUpdaters();
  }

  bool _checkNotDisposed() {
    if (_updaters == null) throw const RxDisposedException();
    return true;
  }
}

class RxDisposedException implements Exception {
  const RxDisposedException();

  @override
  String toString() {
    return 'Rx is already disposed, call `reInit()` if you want to use it again. note that all previous listeners are no longer existing.';
  }
}
