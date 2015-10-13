library lis.complex;

import 'dart:js' show JsObject;
import 'dart:typed_data';

import 'package:complex/complex.dart';
import 'package:emscripten/emscripten.dart' show SIZEOF_DBL;

import 'src/lis.dart' as internal;

//export 'src/lis.dart';

const int SIZEOF_CMPLX = Float64List.BYTES_PER_ELEMENT * 2;

class ZLIS extends internal.LIS<Complex> {
  ZLIS([List<String> options, JsObject context])
      : super('ZLIS', options, context);

  int heapScalars(List<Complex> list) {
    var clist = new Float64List(list.length * 2);
    for (var i = 0; i < list.length; i++) {
      clist[2 * i] = list[i].real;
      clist[2 * i + 1] = list[i].imaginary;
    }
    return heapDoubles(clist);
  }

  List<Complex> derefScalars(int ptr, int n, [bool free = true]) {
    var list = derefDoubles(ptr, 2 * n, free);
    var clist = new List<Complex>(n);
    for (var i = 0; i < n; i++) {
      var re = list[2 * i];
      var im = list[2 * i + 1];
      clist[i] = new Complex(re, im);
    }
    return clist;
  }

  int heapScalar([Complex val]) {
    var ptr = malloc(SIZEOF_CMPLX);
    if (val != null) {
      module.callMethod('setValue', [ptr, val.real, 'double']);
      module.callMethod(
          'setValue', [ptr + SIZEOF_DBL, val.imaginary, 'double']);
    }
    return ptr;
  }

  Complex derefScalar(int ptr, [bool free = true]) {
    if (ptr == null) {
      throw new ArgumentError.notNull('ptr');
    }
    var re = module.callMethod('getValue', [ptr, 'double']);
    var im = module.callMethod('getValue', [ptr + SIZEOF_DBL, 'double']);
    if (free) {
      this.free(ptr);
    }
    return new Complex(re.toDouble(), im.toDouble());
  }

  Complex scalarOne() => Complex.ONE;
  Complex scalarZero() => Complex.ZERO;
}
