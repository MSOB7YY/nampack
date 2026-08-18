import 'package:nampack/reactive/class/rx_Throttler.dart';
import 'package:nampack/reactive/class/rx_base.dart';
import 'package:nampack/reactive/class/rx_updater_mixin.dart';

class Rx<T> = RxBase<T> with RxOUpdatersMixin<T>, RxUpdatersMixin<T>;
class RxO<T> = RxBase<T> with RxOUpdatersMixin<T>;

/// {@macro nampack.reactive.rx_throttler}
class RxD<T> = RxBase<T> with RxOUpdatersMixin<T>, RxUpdatersMixin<T>, RxThrottlerMixin<T>;

/// {@macro nampack.reactive.rx_throttler}
class RxOD<T> = RxBase<T> with RxOUpdatersMixin<T>, RxThrottlerMixin<T>;

class RxNotifier extends RxBase<Null> with RxOUpdatersMixin<Null> {
  RxNotifier() : super(null);
}
