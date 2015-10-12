library lis.complex;

import 'package:complex/complex.dart';

import 'src/lis.dart' as internal;

export 'src/lis.dart' hide LIS;

class ZLIS extends internal.LIS<Complex> {
  ZLIS([List<String> options = const []])
      : super(moduleName: 'ZLIS', options: options);

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
