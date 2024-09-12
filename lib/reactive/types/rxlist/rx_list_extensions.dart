part of 'rx_list_base.dart';

extension RxListExtensionsBase<E, Id> on RxListBase<E> {
  bool get isEmpty => valueR.isEmpty;

  bool get isNotEmpty => valueR.isNotEmpty;

  int get length => valueR.length;

  set length(int newLength) {
    _value.length = newLength;
    refresh();
  }

  void add(E element) {
    _value.add(element);
    refresh();
  }

  void addAll(Iterable<E> iterable) {
    _value.addAll(iterable);
    refresh();
  }

  void insert(int index, E element) {
    _value.insert(index, element);
    refresh();
  }

  void insertAll(int index, Iterable<E> iterable) {
    _value.insertAll(index, iterable);
    refresh();
  }

  bool remove(Object? element) {
    final removed = _value.remove(element);
    refresh();
    return removed;
  }

  void removeWhere(bool Function(E element) test) {
    _value.removeWhere(test);
    refresh();
  }

  void retainWhere(bool Function(E element) test) {
    _value.retainWhere(test);
    refresh();
  }

  E removeLast() {
    final res = _value.removeLast();
    refresh();
    return res;
  }

  E removeAt(int index) {
    final res = _value.removeAt(index);
    refresh();
    return res;
  }

  Iterable<E> where(bool Function(E element) test) => valueR.where(test);

  Iterable<T> whereType<T>() => valueR.whereType<T>();

  bool contains(Object? element) => valueR.contains(element);

  void sort([int Function(E a, E b)? compare]) {
    _value.sort(compare);
    refresh();
  }

  void clear() {
    _value.clear();
    refresh();
  }
}

extension RxListExtensions<E, Id> on RxListBase<E> {
  void assign(E element) {
    _value.assign(element);
    refresh();
  }

  void assignAll(Iterable<E> iterable) {
    _value.assignAll(iterable);
    refresh();
  }

  void loop(void Function(E item) action) {
    _value.loop(action);
    refresh();
  }

  void loopAdv(void Function(E item, int index) action) {
    _value.loopAdv(action);
    refresh();
  }

  void reverseLoop(void Function(E item) action) {
    _value.reverseLoop(action);
    refresh();
  }

  void reverseLoopAdv(void Function(E e, int index) function) {
    _value.reverseLoopAdv(function);
    refresh();
  }

  /// returns true if [item] was removed.
  bool addOrRemove(E item) {
    final removed = _value.addOrRemove(item);
    refresh();
    return removed;
  }

  void replaceWhere(bool Function(E e) test, E Function(E old) newElement, {void Function()? onMatch}) {
    _value.replaceWhere(test, newElement, onMatch: onMatch);
    refresh();
  }

  void replaceSingleWhere(bool Function(E e) test, E Function(E old) newElement, {void Function()? onMatch}) {
    _value.replaceSingleWhere(test, newElement, onMatch: onMatch);
    refresh();
  }

  void replaceItems(E oldElement, E newElement, {void Function()? onMatch}) {
    _value.replaceItems(oldElement, newElement, onMatch: onMatch);
    refresh();
  }

  void replaceItem(E oldElement, E newElement, {void Function()? onMatch}) {
    _value.replaceItem(oldElement, newElement, onMatch: onMatch);
    refresh();
  }

  void insertSafe(int index, E object) {
    _value.insertSafe(index, object);
    refresh();
  }

  void insertAllSafe(int index, Iterable<E> objects) {
    _value.insertAllSafe(index, objects);
    refresh();
  }

  void sortBy(Comparable Function(E e) key) {
    _value.sortBy(key);
    refresh();
  }

  void sortByReverse(Comparable Function(E e) key) {
    _value.sortByReverse(key);
    refresh();
  }

  void sortByAlt(Comparable Function(E e) key, Comparable Function(E e) alternative) {
    _value.sortByAlt(key, alternative);
    refresh();
  }

  void sortByReverseAlt(Comparable Function(E e) key, Comparable Function(E e) alternative) {
    _value.sortByReverseAlt(key, alternative);
    refresh();
  }

  void sortByAlts(List<Comparable Function(E e)> alternatives) {
    _value.sortByAlts(alternatives);
    refresh();
  }

  void sortByReverseAlts(List<Comparable Function(E e)> alternatives) {
    _value.sortByReverseAlts(alternatives);
    refresh();
  }

  int removeWhereWithDifference(bool Function(E element) test) {
    final res = _value.removeWhereWithDifference(test);
    refresh();
    return res;
  }

  bool isEqualTo(List<E> q2) {
    return valueR.isEqualTo(q2);
  }

  /// returns number of items removed.
  int removeDuplicates([Id Function(E element)? id]) {
    final res = _value.removeDuplicates(id);
    refresh();
    return res;
  }

  List<E> uniqued([Id Function(E element)? id]) {
    return _value.uniqued(id);
  }

  List<T> mapped<T>(T Function(E e) toElement) {
    return _value.mapped(toElement);
  }

  List<T> mappedUniqued<T>(T Function(E e) toElement) {
    return _value.mappedUniqued(toElement);
  }

  List<T> mappedUniquedList<T>(Iterable<T> Function(E e) toElements) {
    return _value.mappedUniquedList(toElements);
  }

  void addNoDuplicates(E item, {bool preventDuplicates = true}) {
    _value.addNoDuplicates(item, preventDuplicates: preventDuplicates);
    refresh();
  }

  void addAllNoDuplicates(Iterable<E> item, {bool preventDuplicates = true}) {
    _value.addAllNoDuplicates(item, preventDuplicates: preventDuplicates);
    refresh();
  }

  E? lastWhereEff(bool Function(E e) test, {E? fallback}) {
    return valueR.lastWhereEff(test, fallback: fallback);
  }

  E? firstWhereEff(bool Function(E e) test, {E? fallback}) {
    return valueR.firstWhereEff(test, fallback: fallback);
  }

  void retainWhereAdvanced(bool Function(E element, int index) test, {int? keepIndex}) {
    _value.retainWhereAdvanced(test, keepIndex: keepIndex);
    refresh();
  }
}
