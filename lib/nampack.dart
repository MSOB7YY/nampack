library nampack;

export 'extensions/extensions.dart';
export 'navigation/navigation.dart';
export 'reactive/reactive.dart';

export 'snackbar/snackbar.dart';

typedef NamCallback = void Function();

/// Used to ensure data is stale/non-important so that Throttle timer can automatically take a rest
typedef DataValidCallback<T> = bool Function(T data);

class NamPackDefaults {
  static var effectiveThrottleDuration = _kDefaultThrottleDuration;

  static const _kDefaultThrottleDuration = Duration(milliseconds: 20);
  static bool defaultIsDataValidList(List data) => data.isNotEmpty;
  static bool defaultIsDataValidMap(Map data) => data.isNotEmpty;
}
