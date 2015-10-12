library lis.test.vector;

import 'dart:math';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:lis/dlis.dart';
import 'random.dart';

Float64List rarry() {
  int n = rint();
  var list = new Float64List(n);
  for (var i = 0; i < n; i++) {
    list[i] = rand();
  }
  return list;
}

vectorTest(LIS makeLIS()) {
  LIS lis;
  Vector v;

  setUp(() {
    lis = makeLIS();
    v = new Vector(lis);
  });

  tearDown(() {
    v.destroy();
    lis.finalize();
  });

  Vector rvec([Vector vdst]) {
    int n;
    if (vdst == null) {
      n = rint();
      vdst = new Vector(lis);
    } else if (vdst.isNull()) {
      n = rint();
      vdst.size = n;
    } else {
      n = vdst.size;
    }
    for (var i = 0; i < n; i++) {
      vdst[i] = rand();
    }
    return vdst;
  }
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
    v2.destroy();
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
  test('print', () {
    rvec(v);
    expect(() => v.print(), returnsNormally);
  });
  test('isNull', () {
    expect(v.isNull(), isTrue);
    v.size = rint();
    expect(v.isNull(), isFalse);
  });
  test('swap', () {
    rvec(v);
    var v0 = v.copy();
    var vdst = new Vector(lis);
    vdst.size = v.size;
    var vdst0 = vdst.copy();
    v.swap(vdst);
    expect(vdst.values(), equals(v0.values()));
    expect(v.values(), equals(vdst0.values()));
    v0.destroy();
    vdst.destroy();
  });
  test('copy', () {
    rvec(v);
    var v2 = v.copy();
    expect(v2.values(), equals(v.values()));
    v2.destroy();
  });
  test('axpy', () {
    rvec(v);
    var y = v.copy();
    rvec(y);
    var y0 = y.copy();
    var alpha = rand();
    y.axpy(v, alpha);
    for (var i = 0; i < v.size; i++) {
      expect(y[i], equals(alpha * v[i] + y0[i]));
    }
    y.destroy();
    y0.destroy();
  });
  test('xpay', () {
    rvec(v);
    var y = v.copy();
    rvec(y);
    var y0 = y.copy();
    var alpha = rand();
    y.xpay(v, alpha);
    for (var i = 0; i < v.size; i++) {
      expect(y[i], equals(v[i] + alpha * y0[i]));
    }
    y.destroy();
    y0.destroy();
  });
  test('axpyz', () {
    rvec(v);
    var y = v.copy();
    rvec(y);
    var alpha = rand();
    var z = y.axpyz(v, alpha);
    for (var i = 0; i < v.size; i++) {
      expect(z[i], equals(alpha * v[i] + y[i]));
    }
    y.destroy();
    z.destroy();
  });
  test('scale', () {
    rvec(v);
    var v0 = v.copy();
    var alpha = rand();
    v.scale(alpha);
    for (var i = 0; i < v.size; i++) {
      expect(v[i], equals(alpha * v0[i]));
    }
    v0.destroy();
  });
  test('pmul', () {
    rvec(v);
    var v0 = v.copy();
    var vx = v.copy();
    rvec(vx);
    v.pmul(vx);
    for (var i = 0; i < v.size; i++) {
      expect(v[i], equals(vx[i] * v0[i]));
    }
    v0.destroy();
    vx.destroy();
  });
  test('pdiv', () {
    rvec(v);
    var v0 = v.copy();
    var vx = v.copy();
    rvec(vx);
    v.pdiv(vx);
    for (var i = 0; i < v.size; i++) {
      expect(v[i], equals(vx[i] / v0[i]));
    }
    v0.destroy();
    vx.destroy();
  });
  test('fill', () {
    rvec(v);
    var alpha = rand();
    v.fill(alpha);
    for (var i = 0; i < v.size; i++) {
      expect(v[i], equals(alpha));
    }
  });
  test('abs', () {
    rvec(v);
    for (var i = 0; i < v.size; i++) {
      v[i] = -v[i];
    }
    v.abs();
    for (var i = 0; i < v.size; i++) {
      expect(v[i], greaterThan(0.0));
    }
  });
  test('reciprocal', () {
    rvec(v);
    var v0 = v.copy();
    v.reciprocal();
    for (var i = 0; i < v.size; i++) {
      expect(v[i], equals(1.0 / v0[i]));
    }
    v0.destroy();
  });
  test('shift', () {
    rvec(v);
    var v0 = v.copy();
    var alpha = rand();
    v.shift(alpha);
    for (var i = 0; i < v.size; i++) {
      expect(v[i], equals(v0[i] + alpha));
    }
    v0.destroy();
  });
  test('dot', () {
    rvec(v);
    var vx = v.copy();
    var val = v.dot(vx);
    var expected = 0.0;
    for (var i = 0; i < v.size; i++) {
      expected += v[i] * vx[i];
    }
    expect(val, equals(expected));
    vx.destroy();
  });
  test('nrmi', () {
    rvec(v);
    var val = v.nrmi();
    var expected = 0.0;
    for (var i = 0; i < v.size; i++) {
      expected = max(expected, v[i].abs());
    }
    expect(val, equals(expected));
  });
  test('sum', () {
    rvec(v);
    var val = v.sum();
    var expected = 0.0;
    for (var i = 0; i < v.size; i++) {
      expected += v[i];
    }
    expect(val, equals(expected));
  });
}
