library lis.test;

import 'package:test/test.dart';
import 'package:lis/web/dlis.dart';
import 'package:lis/web/zlis.dart';
import 'package:complex/complex.dart';

import 'package:lis/src/web/dlis.dart';
import 'package:lis/src/web/zlis.dart';

import 'vector_test.dart';
import 'matrix_test.dart';
import 'module_test.dart';
import 'solver_test.dart';
import 'esolver_test.dart';

import 'random.dart';

main() {
  group('lis', () {
    group('double', () {
      var module = new DLISModule();
      group('module', () => moduleTest(module, rand));

      var lis = new DLIS();
      group('vector', () => vectorTest(lis, rand));
      group('matrix', () => matrixTest(lis, rand, (i) => i.toDouble()));
      group('solver', () => solverTest(lis, rand));
      group('esolver', () => esolverTest(lis));
      lis.finalize();
    });
    group('complex', () {
      rcmplx() => new Complex(rand(), rand());
      var module = new ZLISModule();
      group('module', () => moduleTest(module, rcmplx));

      var lis = new ZLIS();
      group('vector', () => vectorTest(lis, rcmplx));
      group('matrix', () => matrixTest(lis, rcmplx, (i) => new Complex(i)));
//      group('solver', () => solverTest(lis, rcmplx));
      lis.finalize();
    });
  });
}
