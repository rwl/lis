library lis.test.vector;

import 'dart:math';
import 'package:test/test.dart';
import 'package:lis/lis.dart';

final Random _r = new Random();

int rint([int max = 9]) => _r.nextInt(max) + 1;

double rand() => _r.nextDouble();

testVector() {
  LIS lis;
  Vector v;

  setUp(() {
    lis = new LIS();
    v = new Vector(lis);
  });

  tearDown(() {
    v.destroy();
    lis.finalize();
  });

  test('size', () {
    int size = rint();
    v.size = size;
    expect(v.size, equals(size));
  });
}
