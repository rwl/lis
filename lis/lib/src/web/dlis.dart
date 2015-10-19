library lis.internal.web.double;

import 'dart:js' show JsObject;
import 'dart:typed_data';

import 'module.dart';
import 'web.dart';

class DLISModule extends LisModule<double> {
  DLISModule([List<String> options, JsObject context])
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
}

class DLIS extends WebLIS<double> {
  DLIS([List<String> options]) : super(new DLISModule(), options);

  double get one => 1.0;

  double get zero => 0.0;
}
