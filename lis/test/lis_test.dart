import 'package:test/test.dart';
import 'package:lis/lis.dart';
import 'package:lis/dlis.dart' as dlis;
import 'package:lis/zlis.dart' as zlis;
import 'package:complex/complex.dart';

import 'vector_test.dart';
import 'matrix_test.dart';

import 'random.dart';

testLIS(LIS makeLIS(), makeScalar()) {
  LIS lis;

  setUp(() {
    lis = makeLIS();
  });

  tearDown(() {
    lis.finalize();
  });

  test('scalar', () {
    var c = makeScalar();
    int ptr = lis.heapScalar(c);
    expect(ptr, isNonZero);
    var c2 = lis.derefScalar(ptr);
    expect(c2, equals(c));
  });

  test('scalars', () {
    int n = rint();
    var l = new List.generate(n, (_) => makeScalar());
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
      makeLIS() => new dlis.DLIS();
      makeScalar() => rand();
      group('module', () => testLIS(makeLIS, makeScalar));
      group('vector', () => vectorTest(makeLIS, makeScalar));
      group('matrix', () => matrixTest(makeLIS, makeScalar));
    });
    group('complex', () {
      makeLIS() => new zlis.ZLIS();
      makeScalar() => new Complex(rand(), rand());
      group('module', () => testLIS(makeLIS, makeScalar));
//      group('vector', () => vectorTest(makeLIS, makeScalar));
//      group('matrix', () => matrixTest(makeLIS, makeScalar));
    });
  });
}
