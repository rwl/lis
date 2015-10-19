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

  Vector<Complex> real(List<double> re) {
    var n = re.length;
    var l = new List.generate(n, (i) => new Complex(re[i]));
    return new Vector<Complex>(this, n)..setAll(0, l);
  }

  Vector<Complex> imag(List<double> im) {
    var n = im.length;
    var l = new List.generate(n, (i) => new Complex(0.0, im[i]));
    return new Vector<Complex>(this, n)..setAll(0, l);
  }

  Vector<Complex> parts(List<double> re, List<double> im) {
    if (re.length != im.length) {
      throw new ArgumentError('re.length != im.length');
    }
    var n = re.length;
    var l = new List<Complex>.generate(n, (i) => new Complex(re[i], im[i]));
    return new Vector<Complex>(this, n)..setAll(0, l);
  }

  Vector<Complex> polar(List<double> r, List<double> theta,
      [bool radians = true]) {
    if (r.length != theta.length) {
      throw new ArgumentError('r.length != theta.length');
    }
    var n = r.length;
    var vals = new List<Complex>(n);
    enumerate(theta).forEach((iv) {
      double th = radians ? iv.value : iv.value * (PI / 180.0);
      vals[iv.index] = new Complex.polar(r[iv.index], th);
    });
    return new Vector<Complex>(this, n)..setAll(0, vals);
  }
}
