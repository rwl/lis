library lis;

import 'dart:js' show JsObject;
import 'dart:typed_data';

import 'src/lis.dart' as internal;

export 'src/lis.dart';

class DLIS extends internal.LIS<double> {
  DLIS([List<String> options, JsObject context])
      : super('DLIS', options, context);

  int heapScalars(List<double> list) {
    if (list is! Float64List) {
      list = new Float64List.fromList(list);
    }
    return heapDoubles(list);
  }

  Float64List derefScalars(int ptr, int n, [bool free = true]) =>
      derefDoubles(ptr, n, free);

  heapScalar([double val]) => heapDouble(val);

  double derefScalar(int ptr, [bool free = true]) => derefDouble(ptr, free);

  double scalarOne() => 1.0;
}
