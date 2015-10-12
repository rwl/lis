library lis.complex;

import 'dart:js' show JsObject;

import 'package:complex/complex.dart';

import 'src/lis.dart' as internal;

export 'src/lis.dart' hide LIS;

class ZLIS extends internal.LIS<Complex> {
  ZLIS([List<String> options, JsObject context])
      : super('ZLIS', options, context);

  int heapScalars(List<Complex> list) {
    return null;
  }

  List<Complex> derefScalars(int ptr, int n, [bool free = true]) {
    return null;
  }

  int heapScalar([Complex val]) {
    return null;
  }

  Complex derefScalar(int ptr, [bool free = true]) {
    return null;
  }

  Complex scalarOne() => Complex.ONE;
}
