library lis.internal.web.complex;

import 'dart:math' show PI, cos, sin;
import 'dart:js' show JsObject;

import 'package:complex/complex.dart';
import 'package:quiver/iterables.dart' show enumerate;

import '../lis.dart';

import 'module.dart';
import 'web.dart';

class ZLISModule extends LisModule<Complex> {
  ZLISModule([List<String> options, JsObject context])
      : super('ZLIS', options, context);

  int heapScalars(List<Complex> list) => heapComplexList(list);

  List<Complex> derefScalars(int ptr, int n, [bool free = true]) =>
      derefComplexList(ptr, n, free);

  int heapScalar([Complex val]) => heapComplex(val);

  Complex derefScalar(int ptr, [bool free = true]) => derefComplex(ptr, free);
}

class ZLIS extends WebLIS<Complex> {
  ZLIS([List<String> options]) : super(new ZLISModule(), options);

  Complex get one => Complex.ONE;

  Complex get zero => Complex.ZERO;
}
