library lis.test;

import 'package:test/test.dart';
import 'package:lis/lis.dart';
import 'package:lis/dlis.dart' as dlis;
import 'package:lis/zlis.dart' as zlis;
import 'package:complex/complex.dart';

import 'vector_test.dart';
import 'matrix_test.dart';

import 'random.dart';

testLIS(LIS lis, rscal()) {
  test('scalar', () {
    var c = rscal();
    int ptr = lis.heapScalar(c);
    expect(ptr, isNonZero);
    var c2 = lis.derefScalar(ptr);
    expect(c2, equals(c));
  });
  test('scalars', () {
    int n = rint();
    var l = new List.generate(n, (_) => rscal());
    int ptr = lis.heapScalars(l);
    expect(ptr, isNonZero);
    var l2 = lis.derefScalars(ptr, n);
    expect(l2, equals(l));
  });
  test('one', () {
    var one = lis.scalarOne();
    expect(one, isNotNull);
    expect(one, equals(one));
  });
}

main() {
  group('lis', () {
    group('double', () {
      var lis = new dlis.DLIS();
      group('module', () => testLIS(lis, rand));
      group('vector', () => vectorTest(lis, rand));
      group('matrix', () => matrixTest(lis, rand));
      lis.finalize();
    });
    group('complex', () {
      var lis = new zlis.ZLIS();
      rcmplx() => new Complex(rand(), rand());
      group('module', () => testLIS(lis, rcmplx));
      group('vector', () => vectorTest(lis, rcmplx));
      group('matrix', () => matrixTest(lis, rcmplx));
      lis.finalize();
    });
  });
}
