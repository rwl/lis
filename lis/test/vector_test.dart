library lis.test.vector;

import 'dart:math';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:complex/complex.dart';
import 'package:lis/lis.dart';
import 'random.dart' hide rand;

vectorTest(LIS lis, rscal()) {
  List rarry() {
    int n = rint();
    var list = new List(n);
    for (var i = 0; i < n; i++) {
      list[i] = rscal();
    }
    return list;
  }

  Vector rvec([Vector vdst]) {
    int n;
    if (vdst == null) {
      n = rint();
      vdst = new Vector(lis);
    } else if (vdst.isNull()) {
      n = rint();
      vdst.length = n;
    } else {
      n = vdst.length;
    }
    for (var i = 0; i < n; i++) {
      vdst[i] = rscal();
    }
    return vdst;
  }

  Vector v;
  setUp(() {
    v = new Vector(lis);
  });
  tearDown(() {
    v.destroy();
  });
  test('list', () {
    expect(v is List, isTrue);
  });
  test('length', () {
    int size = rint();
    v.length = size;
    expect(v.length, equals(size));
  });
  test('duplicate', () {
    int size = rint();
    v.length = size;
    var v2 = v.duplicate();
    expect(v2, isNotNull);
    expect(v2.length, equals(size));
    v2.destroy();
  });
  test('[]', () {
    v.length = rint();
    var val = rscal();
    v[0] = val;
    expect(v[0], equals(val));
  });
  test('values', () {
    var vals = rarry();
    var count = vals.length;
    v.length = count;
    for (var i = 0; i < count; i++) {
      v[i] = vals[i];
    }
    expect(v.values(), equals(vals));
    expect(v.values(1, count - 1), equals(vals.sublist(1)));
  });
  test('setValues', () {
    var vals = rarry();
    var count = vals.length;
    v.length = count;
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
    v.length = count;
    v.setAll(0, vals); // TODO: test nonzero start
    expect(v.values(), equals(vals));
  });
  test('print', () {
    rvec(v);
    expect(() => v.print(), returnsNormally);
  });
  test('isNull', () {
    expect(v.isNull(), isTrue);
    v.length = rint();
    expect(v.isNull(), isFalse);
  });
  test('swap', () {
    rvec(v);
    var v0 = v.copy();
    var vdst = new Vector(lis);
    vdst.length = v.length;
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
    v[0] = rscal();
    v2[1] = rscal();
    expect(v2.values().sublist(2), equals(v.values().sublist(2)));
    expect(v2.values()[0], isNot(equals(v.values()[0])));
    expect(v2.values()[1], isNot(equals(v.values()[1])));
    v2.destroy();
  });
  test('axpy', () {
    rvec(v);
    var y = v.copy();
    rvec(y);
    var y0 = y.copy();
    var alpha = rscal();
    y.axpy(v, alpha);
    for (var i = 0; i < v.length; i++) {
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
    var alpha = rscal();
    y.xpay(v, alpha);
    for (var i = 0; i < v.length; i++) {
      expect(y[i], equals(v[i] + alpha * y0[i]));
    }
    y.destroy();
    y0.destroy();
  });
  test('axpyz', () {
    rvec(v);
    var y = v.copy();
    rvec(y);
    var alpha = rscal();
    var z = y.axpyz(v, alpha);
    for (var i = 0; i < v.length; i++) {
      expect(z[i], equals(alpha * v[i] + y[i]));
    }
    y.destroy();
    z.destroy();
  });
  test('scale', () {
    rvec(v);
    var v0 = v.copy();
    var alpha = rscal();
    v.scale(alpha);
    for (var i = 0; i < v.length; i++) {
      expect(v[i], equals(alpha * v0[i]));
    }
    v0.destroy();
  });
  test('pmul', () {
    rvec(v);
    var v0 = v.copy();
    var vy = v.copy();
    rvec(vy);
    v.pmul(vy);
    for (var i = 0; i < v.length; i++) {
      expect(v[i], equals(v0[i] * vy[i]));
    }
    v0.destroy();
    vy.destroy();
  });
  test('pdiv', () {
    rvec(v);
    var v0 = v.copy();
    var vy = v.copy();
    rvec(vy);
    v.pdiv(vy);
    for (var i = 0; i < v.length; i++) {
      if (v[i] is Complex) {
        expect(v[i].abs(), closeTo((v0[i] / vy[i]).abs(), 1e-12));
      } else {
        expect(v[i], equals(v0[i] / vy[i]));
      }
    }
    v0.destroy();
    vy.destroy();
  });
  test('fill', () {
    rvec(v);
    var alpha = rscal();
    v.fill(alpha);
    for (var i = 0; i < v.length; i++) {
      expect(v[i], equals(alpha));
    }
  });
  test('abs', () {
    rvec(v);
    for (var i = 0; i < v.length; i++) {
      v[i] = -v[i];
    }
    var v2 = v.copy()..abs();
    for (var i = 0; i < v.length; i++) {
      if (v[i] is Complex) {
        expect(v2[i].re, closeTo(v[i].abs(), 1e-12));
      } else {
        expect(v2[i], equals(v[i].abs()));
      }
    }
    v2.destroy();
  });
  test('reciprocal', () {
    rvec(v);
    var v2 = v.copy()..reciprocal();
    for (var i = 0; i < v.length; i++) {
      if (v[i] is Complex) {
        expect(v2[i].abs(), closeTo(v[i].reciprocal().abs(), 1e-12));
      } else {
        expect(v2[i], equals(1.0 / v[i]));
      }
    }
    v2.destroy();
  });
  test('shift', () {
    rvec(v);
    var v0 = v.copy();
    var alpha = rscal();
    v.shift(alpha);
    for (var i = 0; i < v.length; i++) {
      expect(v[i], equals(v0[i] + alpha));
    }
    v0.destroy();
  });
  test('dot', () {
    rvec(v);
    var vx = v.copy();
    var val = v.dot(vx);
    var expected = lis.zero;
    for (var i = 0; i < v.length; i++) {
      expected += v[i] * vx[i];
    }
    expect(val, equals(expected));
    vx.destroy();
  });
  test('nrmi', () {
    rvec(v);
    var val = v.nrmi();
    var expected = 0.0;
    for (var i = 0; i < v.length; i++) {
      expected = max(expected, v[i].abs());
    }
    expect(val, closeTo(expected, 1e-12));
  });
  test('sum', () {
    rvec(v);
    var val = v.sum();
    var expected = lis.zero;
    for (var i = 0; i < v.length; i++) {
      expected += v[i];
    }
    expect(val, equals(expected));
  });
  test('real', () {
    rvec(v);
    var v2 = v.copy()..real();
    for (var i = 0; i < v.length; i++) {
      if (v[i] is Complex) {
        expect(v2[i].re, closeTo(v[i].re, 1e-12));
        expect(v2[i].imaginary, equals(0.0));
      } else {
        expect(v2[i], equals(v[i]));
      }
    }
  });
  test('imag', () {
    rvec(v);
    var v2 = v.copy()..imag();
    for (var i = 0; i < v.length; i++) {
      if (v[i] is Complex) {
        expect(v2[i].re, closeTo(v[i].imaginary, 1e-12));
        expect(v2[i].imaginary, equals(0.0));
      } else {
        expect(v2[i], equals(0.0));
      }
    }
  });
  test('arg', () {
    rvec(v);
    for (var i = 0; i < v.length; i++) {
      if (rint() % 2 == 0) {
        v[i] = -v[i];
      }
    }
    var v2 = v.copy()..arg();
    for (var i = 0; i < v.length; i++) {
      if (v[i] is Complex) {
        expect(v2[i].re, closeTo(v[i].argument(), 1e-12));
        expect(v2[i].imaginary, equals(0.0));
      } else {
        expect(v2[i], equals(v[i] >= 0 ? 0.0 : PI));
      }
    }
  });
  test('conj', () {
    rvec(v);
    for (var i = 0; i < v.length; i++) {
      if (rint() % 2 == 0) {
        if (v[i] is Complex) {
          v[i] = v[i].conjugate();
        }
      }
    }
    var v2 = v.copy()..conj();
    for (var i = 0; i < v.length; i++) {
      if (v[i] is Complex) {
        expect(v2[i], equals(v[i].conjugate()));
      } else {
        expect(v2[i], equals(v[i]));
      }
    }
  });
  test('concat', () {
    var nvec = rint();
    var vecs = new List<Vector>(nvec);
    int totlen = 0;
    for (var i = 0; i < nvec; i++) {
      var l = rint();
      vecs[i] = new Vector(lis, l);
      rvec(vecs[i]);
      totlen += l;
    }
    var vcat = new Vector.concat(lis, vecs);
    expect(vcat.length, equals(totlen));
    var start = 0;
    vecs.forEach((vec) {
      expect(vcat.values(start, vec.length), equals(vec.values()));
      start += vec.length;
    });
  });
  group('operator', () {
    group('*', () {
      test('vector', () {
        rvec(v);
        var v0 = v.copy();
        var v2 = v.copy();
        rvec(v2);
        var v3 = v * v2;
        for (var i = 0; i < v.length; i++) {
          expect(v[i], equals(v0[i]));
        }
        for (var i = 0; i < v.length; i++) {
          expect(v3[i], equals(v[i] * v2[i]));
        }
      });
      test('scalar', () {
        rvec(v);
        var v0 = v.copy();
        var alpha = rscal();
        var v2 = v * alpha;
        for (var i = 0; i < v.length; i++) {
          expect(v[i], equals(v0[i]));
        }
        for (var i = 0; i < v.length; i++) {
          expect(v2[i], equals(alpha * v0[i]));
        }
        v0.destroy();
      });
      test('other', () {
        rvec(v);
        expect(() => v * "abc", throwsArgumentError);
      });
    });
    group('/', () {
      test('vector', () {
        rvec(v);
        var v0 = v.copy();
        var v2 = v.copy();
        rvec(v2);
        var v3 = v / v2;
        for (var i = 0; i < v.length; i++) {
          expect(v[i], equals(v0[i]));
        }
        for (var i = 0; i < v.length; i++) {
          if (v[i] is Complex) {
            expect(v3[i].abs(), closeTo((v[i] / v2[i]).abs(), 1e-12));
          } else {
            expect(v3[i], equals(v[i] / v2[i]));
          }
        }
      });
      test('scalar', () {
        rvec(v);
        var v0 = v.copy();
        var alpha = rscal();
        var v2 = v / alpha;
        for (var i = 0; i < v.length; i++) {
          expect(v[i], equals(v0[i]));
        }
        for (var i = 0; i < v.length; i++) {
          if (v[i] is Complex) {
            expect(v2[i].abs(), closeTo((v0[i] / alpha).abs(), 1e-12));
          } else {
            expect(v2[i], closeTo(v0[i] / alpha, 1e-12));
          }
        }
        v0.destroy();
      });
      test('other', () {
        rvec(v);
        expect(() => v / "abc", throwsArgumentError);
      });
    });
    group('+', () {
      test('vector', () {
        rvec(v);
        var v0 = v.copy();
        var v2 = v.copy();
        rvec(v2);
        var v3 = v + v2;
        for (var i = 0; i < v.length; i++) {
          expect(v[i], equals(v0[i]));
        }
        for (var i = 0; i < v.length; i++) {
          expect(v3[i], equals(v[i] + v2[i]));
        }
      });
      test('scalar', () {
        rvec(v);
        var v0 = v.copy();
        var alpha = rscal();
        var v2 = v + alpha;
        for (var i = 0; i < v.length; i++) {
          expect(v[i], equals(v0[i]));
        }
        for (var i = 0; i < v.length; i++) {
          expect(v2[i], equals(v0[i] + alpha));
        }
        v0.destroy();
      });
      test('other', () {
        rvec(v);
        expect(() => v + "abc", throwsArgumentError);
      });
    });
    group('-', () {
      test('vector', () {
        rvec(v);
        var v0 = v.copy();
        var v2 = v.copy();
        rvec(v2);
        var v3 = v - v2;
        for (var i = 0; i < v.length; i++) {
          expect(v[i], equals(v0[i]));
        }
        for (var i = 0; i < v.length; i++) {
          expect(v3[i], equals(v[i] - v2[i]));
        }
      });
      test('scalar', () {
        rvec(v);
        var v0 = v.copy();
        var alpha = rscal();
        var v2 = v - alpha;
        for (var i = 0; i < v.length; i++) {
          expect(v[i], equals(v0[i]));
        }
        for (var i = 0; i < v.length; i++) {
          expect(v2[i], equals(v0[i] - alpha));
        }
        v0.destroy();
      });
      test('other', () {
        rvec(v);
        expect(() => v - "abc", throwsArgumentError);
      });
    });
  });
}
