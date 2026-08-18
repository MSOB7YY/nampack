import 'package:nampack/nampack.dart';
import 'package:nampack/reactive/class/rx_Throttler.dart';
import 'package:nampack/reactive/class/rx_updater_mixin.dart';

/// {@macro nampack.reactive.rx_base}
class RxMap<K, V> = RxMapBase<K, V> with RxOUpdatersMixin<Map<K, V>>, RxUpdatersMixin<Map<K, V>>;

/// {@macro nampack.reactive.rx_base}
class RxOMap<K, V> = RxMapBase<K, V> with RxOUpdatersMixin<Map<K, V>>;

/// {@macro nampack.reactive.rx_base}
///
/// {@macro nampack.reactive.rx_throttler}
class RxDMap<K, V> = RxMapBase<K, V> with RxOUpdatersMixin<Map<K, V>>, RxUpdatersMixin<Map<K, V>>, RxThrottlerMixin<Map<K, V>>;

/// {@macro nampack.reactive.rx_base}
///
/// {@macro nampack.reactive.rx_throttler}
class RxODMap<K, V> = RxMapBase<K, V> with RxOUpdatersMixin<Map<K, V>>, RxThrottlerMixin<Map<K, V>>;

extension NPMapExtensions<K, V> on Map<K, V> {
  RxMap<K, V> get obs => RxMap<K, V>(this);
  RxOMap<K, V> get obso => RxOMap<K, V>(this);

  /// {@macro nampack.reactive.rx_throttler}
  RxDMap<K, V> obsThrottle(Duration duration, {DataValidCallback<Map<K, V>> isDataValid = NamPackDefaults.defaultIsDataValidMap}) => RxDMap<K, V>(this)
    ..duration = duration
    ..isDataValid = isDataValid;

  /// {@macro nampack.reactive.rx_throttler}
  RxODMap<K, V> obsoThrottle(Duration duration, {DataValidCallback<Map<K, V>> isDataValid = NamPackDefaults.defaultIsDataValidMap}) => RxODMap<K, V>(this)
    ..duration = duration
    ..isDataValid = isDataValid;
}
