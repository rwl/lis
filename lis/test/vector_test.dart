library lis.test.vector;

import 'dart:math';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:lis/lis.dart';

final Random _r = new Random();

int rint([int max = 9]) => _r.nextInt(max) + 1;

double rand() => _r.nextDouble();

Float64List rarry() {
  int n = rint();
  var list = new Float64List(n);
  for (var i = 0; i < n; i++) {
    list[i] = rand();
  }
  return list;
}

testVector() {
  group('vector', () {
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
    test('duplicate', () {
      int size = rint();
      v.size = size;
      var v2 = v.duplicate();
      expect(v2, isNotNull);
      expect(v2.size, equals(size));
    });
    test('[]', () {
      v.size = rint();
      var val = rand();
      v[0] = val;
      expect(v[0], equals(val));
    });
    test('values', () {
      var vals = rarry();
      var count = vals.length;
      v.size = count;
      for (var i = 0; i < count; i++) {
        v[i] = vals[i];
      }
      expect(v.values(), equals(vals));
      expect(v.values(1, count - 1), equals(vals.sublist(1)));
    });
    test('setValues', () {
      var vals = rarry();
      var count = vals.length;
      v.size = count;
      var idxs = new Int32List(count);
      for (var i = 0; i < count; i++) {
        idxs[i] = count - i - 1;
      }
      v.setValues(idxs, vals);
      for (var i = 0; i < count; i++) {
        expect(v[idxs[i]], equals(vals[i]));
      }
    });
    test('setAll', () {
      var vals = rarry();
      var count = vals.length;
      v.size = count;
      v.setAll(0, vals);
      expect(v.values(), equals(vals));
    });
  });
}
