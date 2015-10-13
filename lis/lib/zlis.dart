library lis.complex;

import 'dart:js' show JsObject;

import 'package:complex/complex.dart';

import 'src/lis.dart' as internal;

class ZLIS extends internal.LIS<Complex> {
  ZLIS([List<String> options, JsObject context])
      : super('ZLIS', options, context);

  int heapScalars(List<Complex> list) => heapComplexList(list);

  List<Complex> derefScalars(int ptr, int n, [bool free = true]) =>
      derefComplexList(ptr, n, free);

  int heapScalar([Complex val]) => heapComplex(val);

  Complex derefScalar(int ptr, [bool free = true]) => derefComplex(ptr, free);

  Complex scalarOne() => Complex.ONE;

  Complex scalarZero() => Complex.ZERO;
}
