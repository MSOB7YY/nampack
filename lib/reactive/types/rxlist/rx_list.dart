import 'package:nampack/nampack.dart';
import 'package:nampack/reactive/class/rx_Throttler.dart';
import 'package:nampack/reactive/class/rx_updater_mixin.dart';

/// {@macro nampack.reactive.rx_base}
class RxList<E> = RxListBase<E> with RxOUpdatersMixin<List<E>>, RxUpdatersMixin<List<E>>;

/// {@macro nampack.reactive.rx_base}
class RxOList<E> = RxListBase<E> with RxOUpdatersMixin<List<E>>;

/// {@macro nampack.reactive.rx_base}
///
/// {@macro nampack.reactive.rx_throttler}
class RxDList<E> = RxListBase<E> with RxOUpdatersMixin<List<E>>, RxUpdatersMixin<List<E>>, RxThrottlerMixin<List<E>>;

/// {@macro nampack.reactive.rx_base}
///
/// {@macro nampack.reactive.rx_throttler}
class RxODList<E> = RxListBase<E> with RxOUpdatersMixin<List<E>>, RxThrottlerMixin<List<E>>;

extension NPListExtensions<E> on List<E> {
  RxList<E> get obs => RxList<E>(this);
  RxOList<E> get obso => RxOList<E>(this);

  /// {@macro nampack.reactive.rx_throttler}
  RxDList<E> obsThrottle(Duration duration, {DataValidCallback<List<E>> isDataValid = NamPackDefaults.defaultIsDataValidList}) => RxDList<E>(this)
    ..duration = duration
    ..isDataValid = isDataValid;

  /// {@macro nampack.reactive.rx_throttler}
  RxODList<E> obsoThrottle(Duration duration, {DataValidCallback<List<E>> isDataValid = NamPackDefaults.defaultIsDataValidList}) => RxODList<E>(this)
    ..duration = duration
    ..isDataValid = isDataValid;
}
