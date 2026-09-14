part of 'rx_map_base.dart';

extension RxMapExtensionsBase<K, V> on RxMapBase<K, V> {
  int get length => valueR.length;

  Iterable<K> get keys => valueR.keys;

  Iterable<V> get values => valueR.values;

  Iterable<MapEntry<K, V>> get entries => valueR.entries;

  bool get isEmpty => valueR.isEmpty;

  bool get isNotEmpty => valueR.isNotEmpty;

  void clear() {
    _value.clear();
    refresh();
  }

  V? remove(K key) {
    final removed = _value.remove(key);
    refresh();
    return removed;
  }

  void forEach(void Function(K key, V value) action) {
    _value.forEach(action);
    refresh();
  }

  Map<RK, RV> cast<RK, RV>() => _value.cast<RK, RV>();

  bool containsKey(K key) => _value.containsKey(key);

  bool containsValue(V value) => _value.containsValue(value);

  Map<K2, V2> map<K2, V2>(MapEntry<K2, V2> Function(K key, V value) convert) => _value.map(convert);

  void addAll(Map<K, V> other) {
    _value.addAll(other);
    refresh();
  }

  void addEntries(Iterable<MapEntry<K, V>> newEntries) {
    _value.addEntries(newEntries);
    refresh();
  }

  V update(K key, V Function(V value) update, {V Function()? ifAbsent}) {
    final res = _value.update(key, update);
    refresh();
    return res;
  }

  void updateAll(V Function(K key, V value) update) {
    _value.updateAll(update);
    refresh();
  }

  void removeWhere(bool Function(K key, V value) test) {
    _value.removeWhere(test);
    refresh();
  }

  V putIfAbsent(K key, V Function() ifAbsent) {
    final res = _value.putIfAbsent(key, ifAbsent);
    refresh();
    return res;
  }
}

extension RxMapExtensions<K, V> on RxMapBase<K, V> {
  void assign(K key, V value) {
    _value.assign(key, value);
    refresh();
  }

  void assignAll(Map<K, V> other) {
    _value.assignAll(other);
    refresh();
  }

  void assignAllEntries(Iterable<MapEntry<K, V>> newEntries) {
    _value.assignAllEntries(newEntries);
    refresh();
  }

  void sort([int Function(MapEntry<K, V> a, MapEntry<K, V> b)? compare]) {
    _value.sort(compare);
    refresh();
  }

  void sortBy(Comparable<dynamic> Function(MapEntry<K, V> e) key) {
    _value.sortBy(key);
    refresh();
  }

  void sortByReverse(Comparable<dynamic> Function(MapEntry<K, V> e) key) {
    _value.sortByReverse(key);
    refresh();
  }

  List<MapEntry<K, V>> sorted([int Function(MapEntry<K, V> a, MapEntry<K, V> b)? compare]) {
    return _value.sorted(compare);
  }

  List<MapEntry<K, V>> sortedBy(Comparable<dynamic> Function(MapEntry<K, V> e) key) {
    return _value.sortedBy(key);
  }

  List<MapEntry<K, V>> sortedByReverse(Comparable<dynamic> Function(MapEntry<K, V> e) key) {
    return _value.sortedByReverse(key);
  }

  void optimizedAdd(Iterable<MapEntry<K, V>> entries, int max) {
    _value.optimizedAdd(entries, max);
    refresh();
  }

  void reAssign(K oldKey, K newKey, {V? newValue}) {
    _value.reAssign(oldKey, newKey, newValue: newValue);
    refresh();
  }
}

extension RxMapUtilsNullable<K, V> on RxMapBase<K, V?> {
  void reAssignNullable(K oldKey, K newKey, {V? newValue}) {
    _value.reAssignNullable(oldKey, newKey, newValue: newValue);
    refresh();
  }
}

extension RxMapExtNull<K, E> on RxMapBase<K, List<E>?> {
  void addForce(K key, E item) {
    _value.addForce(key, item);
    refresh();
  }

  void insertForce(int index, K key, E item) {
    _value.insertForce(index, key, item);
    refresh();
  }

  void addNoDuplicatesForce(K key, E item, {bool preventDuplicates = true}) {
    _value.addNoDuplicatesForce(key, item, preventDuplicates: preventDuplicates);
    refresh();
  }

  void addAllNoDuplicatesForce(K key, Iterable<E> items, {bool preventDuplicates = true}) {
    _value.addAllNoDuplicatesForce(key, items, preventDuplicates: preventDuplicates);
    refresh();
  }
}
