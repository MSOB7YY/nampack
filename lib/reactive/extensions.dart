import 'package:nampack/nampack.dart';

extension NamReactiveUtils<T> on T {
  Rx<T> get obs => Rx<T>(this);
  RxO<T> get obso => RxO<T>(this);

  RxD<T> obsThrottle(Duration duration, DataValidCallback<T>? isDataValid) => RxD<T>(this)
    ..duration = duration
    ..isDataValid = isDataValid;

  RxOD<T> obsoThrottle(Duration duration, DataValidCallback<T>? isDataValid) => RxOD<T>(this)
    ..duration = duration
    ..isDataValid = isDataValid;
}

extension RxBoolUtils<T> on RxBase<bool> {
  bool toggle() => value = !value;
}
