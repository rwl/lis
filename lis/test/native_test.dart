library lis.test;

import 'package:test/test.dart';
import 'package:lis/native/dlis.dart';
//import 'package:lis/native/zlis.dart';
//import 'package:complex/complex.dart';

import 'vector_test.dart';
//import 'matrix_test.dart';
//import 'solver_test.dart';

import 'random.dart';

main() {
  group('lis', () {
    group('double', () {
      var lis = new DLIS();
      group('vector', () => vectorTest(lis, rand));
//      group('matrix', () => matrixTest(lis, rand, (i) => i.toDouble()));
//      group('solver', () => solverTest(lis, rand));
      lis.finalize();
    });
//    group('complex', () {
//      rcmplx() => new Complex(rand(), rand());
//      var lis = new ZLIS();
//      group('vector', () => vectorTest(lis, rcmplx));
//      group('matrix', () => matrixTest(lis, rcmplx, (i) => new Complex(i)));
////      group('solver', () => solverTest(lis, rcmplx));
//      lis.finalize();
//    });
  });
}
