abstract class Widget {
  const Widget();
}

class BuildContext {}

class Text extends Widget {
  final String data;
  const Text(this.data);
}

class GestureDetector extends Widget {
  final void Function()? onTap;
  final Widget child;
  const GestureDetector({this.onTap, required this.child});
}

class Obx extends Widget {
  final Widget Function(BuildContext context) builder;
  const Obx(this.builder);
}

abstract class RxBaseCore<T> {
  T _value;
  RxBaseCore(this._value);

  T get value => _value;
  T get valueR => _value;
}

abstract class RxBase<T> extends RxBaseCore<T> {
  RxBase(super.value);

  set value(T other) => _value = other;
}

mixin RxOUpdatersMixin<T> on RxBase<T> {}

mixin RxUpdatersMixin<T> on RxOUpdatersMixin<T> {}

class Rx<T> = RxBase<T> with RxOUpdatersMixin<T>, RxUpdatersMixin<T>;

class RxO<T> = RxBase<T> with RxOUpdatersMixin<T>;

extension RxBoolUtils on RxBase<bool> {
  bool toggle() => value = !value;
}
