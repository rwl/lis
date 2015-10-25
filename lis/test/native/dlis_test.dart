library lis.test;

import 'package:test/test.dart';
import 'package:lis/native/dlis.dart';

import '../vector_test.dart';
import '../matrix_test.dart';
import '../solver_test.dart';
import '../esolver_test.dart';

import '../random.dart';

main() {
  group('lis', () {
    group('double', () {
      var lis = new DLIS();
      group('vector', () => vectorTest(lis, rand));
      group('matrix', () => matrixTest(lis, rand, (i) => i.toDouble()));
      group('solver', () => solverTest(lis, rand));
//      group('esolver', () => esolverTest(lis));
      lis.finalize();
    });
  });
}
