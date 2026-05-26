import 'package:nampack/reactive/class/rx.dart';

/// An alias for `Rx<T?>` but with a fallback
///
/// {@macro nampack.reactive.rx_base}
class RxnF<T> extends Rx<T?> {
  final T fallback;

  /// {@template nampack.reactive.valueF}
  /// Returns [value] if non-null, otherwise [fallback].
  /// {@endtemplate}
  T get valueF => super.value ?? fallback;

  /// {@template nampack.reactive.valueRF}
  /// Returns [valueR] if non-null, otherwise [fallback].
  /// {@endtemplate}
  T get valueRF => super.valueR ?? fallback;

  RxnF({T? value, required this.fallback}) : super(value);
}

/// An alias for `RxO<T?>` but with a fallback
///
/// {@macro nampack.reactive.rx_base}
class RxnOF<T> extends RxO<T?> {
  final T fallback;

  /// {@macro nampack.reactive.valueF}
  T get valueF => super.value ?? fallback;

  /// {@macro nampack.reactive.valueRF}
  T get valueRF => super.valueR ?? fallback;

  RxnOF({T? value, required this.fallback}) : super(value);
}
