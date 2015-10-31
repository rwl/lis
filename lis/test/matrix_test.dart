library lis.test.matrix;

import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:lis/lis.dart';
import 'package:complex/complex.dart';
import 'package:quiver/iterables.dart';

import 'random.dart' hide rand;

matrixTest(LIS lis, rscal(), toScalar(int i)) {
  Matrix m;

  setUp(() {
    m = new Matrix(lis);
  });
  tearDown(() {
    m.destroy();
  });

  test('assemble', () {
    expect(m.assembled(), isTrue);
    m.size = rint();
    expect(m.assembled(), isFalse);
    m.setValue(0, 0, rscal());
    expect(m.assembled(), isTrue);
    m.type = MatrixType.DENSE;
    expect(m.assembled(), isTrue);
    m.assemble();
    expect(m.assembled(), isTrue);
  });
  test('duplicate', () {
    var size = rint();
    m.size = size;
    m.setValue(0, 0, rscal());
    m.type = MatrixType.DENSE;
    m.assemble();
    var m2 = m.duplicate();
    expect(m2, isNotNull);
    expect(m2.size, equals(m.size));
    expect(m2.type, equals(MatrixType.CSR)); // TODO: DENSE?
    m2.destroy();
  });
  test('size', () {
    var size = rint();
    m.size = size;
    expect(m.size, equals(size));
  });
  test('nnz', () {
    var size = rint();
    m.size = size;
    for (var i = 0; i < size; i++) {
      m.setValue(i, i, rscal());
    }
    m.assemble();
    expect(m.nnz, equals(size));
  });
  test('type', () {
    MatrixType.values.forEach((t) {
      if (t == null) {
        return;
      }
      var m2 = new Matrix(lis);
      m2.size = rint();
      m2.setValue(0, 0, rscal());
      m2.type = t;
      m2.assemble();
      expect(m2.type, equals(t));
      m2.destroy();
    });
  });
  test('setValue', () {
    m.size = rint();
    expect(() => m.setValue(0, 0, rscal()), returnsNormally);
  });
  test('setValues', () {
    var size = rint();
    m.size = size;
    var vals = new List(size * size);
    for (var i = 0; i < size * size; i++) {
      vals[i] = rscal();
    }
    expect(() => m.setValues(vals), returnsNormally);
    m.assemble();
  });
  group('malloc', () {
    test('nnz_row', () {
      var size = rint();
      m.size = size;
      m.type = MatrixType.CSR;
      m.malloc(nnz_row: rint(size));
      m.setValue(0, 0, rscal());
      m.assemble();
    });
    test('nnz', () {
      var size = rint();
      m.size = size;
      var nnz = new Int32List(size);
      for (var i = 0; i < size; i++) {
        nnz[i] = rint(size);
      }
      m.malloc(nnz: nnz);
      m.setValue(0, 0, rscal());
      m.assemble();
    });
  });
  test('diagonal', () {
    var size = rint();
    m.size = size;
    var vals = new List(size);
    for (var i = 0; i < size; i++) {
      vals[i] = rscal();
      m.setValue(i, i, vals[i]);
    }
    m.assemble();
    var d = m.diagonal();
    expect(d.values(), equals(vals));
  });
  test('convert', () {
    var size = rint();
    m.size = size;
    m.type = MatrixType.COO;
    for (var i = 0; i < size; i++) {
      m.setValue(i, i, rscal());
    }
    m.assemble();

    var m2 = new Matrix.convert(lis, m, MatrixType.CSC);
    expect(m2.diagonal().values(), equals(m.diagonal().values()));
    m2.destroy();
  });
  test('copy', () {
    var size = rint();
    m.size = size;
    m.type = MatrixType.COO;
    for (var i = 0; i < size; i++) {
      m.setValue(i, i, rscal());
    }
    m.assemble();

    var m2 = m.copy();
    expect(m2.type, equals(m.type));
    expect(m2.diagonal().values(), equals(m.diagonal().values()));
  });
  group('transpose', () {
    Matrix A;
    Vector ones;
    setUp(() {
      int n = rint();
      var nnz = 2 * n;
      var row = new Int32List(nnz);
      var col = new Int32List(nnz);
      var value = new List(nnz);
      for (int i = 0; i < n; i++) {
        row[2 * i] = i;
        col[2 * i] = i;
        value[2 * i] = lis.one;

        row[2 * i + 1] = i;
        col[2 * i + 1] = n - 1 - i;
        value[2 * i + 1] = toScalar(i + 1);
      }
      A = new Matrix.coo(lis, n, nnz, row, col, value);
      ones = new Vector(lis, n)..fill(lis.one);
    });
    tearDown(() {
      A.destroy();
      ones.destroy();
    });
    for (var matrixType in [MatrixType.CSR, MatrixType.CSC]) {
      test(matrixType.toString(), () {
        var AA = new Matrix.convert(lis, A, matrixType);
        var At = AA.transpose();

        expect(At.type, equals(matrixType));
        expect(At.diagonal().values(), equals(AA.diagonal().values()));

        var Asum = AA * ones;
        var Atsum = At * ones;

        expect(Atsum.values().reversed, equals(Asum.values()));
      });
    }
  });
  group('csr', () {
    int n;
    Vector d0;
    Matrix A;
    setUp(() {
      n = rint();
      var value = new List.generate(n, (i) => rscal());
      var d = new Matrix.dia(lis, n, 1, [0], value);
      A = new Matrix.convert(lis, d, MatrixType.CSR);
      A.assemble();
      d0 = A.diagonal();
    });
    tearDown(() {
      d0.destroy();
      A.destroy();
    });
    test('real', () {
      var re = A.real();
      var d = re.diagonal().values();
      for (var i = 0; i < n; i++) {
        if (d[i] is Complex) {
          expect(d[i].real, closeTo(d0[i].real, 1e-12));
          expect(d[i].imaginary, equals(0.0));
        } else {
          expect(d[i], equals(d0[i]));
        }
      }
      re.destroy();
    });
    test('imag', () {
      var im = A.imag();
      var d = im.diagonal().values();
      for (var i = 0; i < n; i++) {
        if (d[i] is Complex) {
          expect(d[i].real, closeTo(d0[i].imaginary, 1e-12));
          expect(d[i].imaginary, equals(0.0));
        } else {
          expect(d[i], equals(0.0));
        }
      }
      im.destroy();
    });
    test('conj', () {
      var c = A.conj();
      var d = c.diagonal().values();
      for (var i = 0; i < n; i++) {
        if (d[i] is Complex) {
          expect(d[i], equals(d0[i].conjugate()));
        } else {
          expect(d[i], equals(d0[i]));
        }
      }
      c.destroy();
    });
    test('scale', () {
      var alpha = rscal();
      A.scale(alpha);
      var d = A.diagonal().values();
      for (var i = 0; i < n; i++) {
        expect(d[i], equals(alpha * d0[i]));
      }
    });
    test('*', () {
      var alpha = rscal();
      var Aout = A * alpha;
      var d = Aout.diagonal().values();
      for (var i = 0; i < n; i++) {
        expect(d[i], equals(alpha * d0[i]));
      }
      Aout.destroy();
    });
    test('+', () {
      var b = A.copy();
      b.assemble();
      var c = A + b;
      var d = c.diagonal().values();
      for (var i = 0; i < n; i++) {
        expect(d[i], equals(d0[i] + d0[i]));
      }
    });
    test('-', () {
      var b = A.copy();
      b.assemble();
      var c = A - b;
      var d = c.diagonal().values();
      for (var i = 0; i < n; i++) {
        expect(d[i], equals(d0[i] - d0[i]));
      }
    });
  });

  group('factory', () {
    bool complex = rscal() is Complex;

    cmplxify(List list) {
      for (var i = 0; i < list.length; i++) {
        list[i] = new Complex(list[i]);
      }
    }

    var diagonal = [11.0, 22.0, 33.0, 44.0];
    if (complex) {
      cmplxify(diagonal);
    }

    test('csr', () {
      var n = 4, nnz = 8;
      var ptr = new Int32List(n + 1);
      var index = new Int32List(nnz);
      var value = new List(nnz);

      ptr[0] = 0;
      ptr[1] = 1;
      ptr[2] = 3;
      ptr[3] = 5;
      ptr[4] = 8;
      index[0] = 0;
      index[1] = 0;
      index[2] = 1;
      index[3] = 1;
      index[4] = 2;
      index[5] = 0;
      index[6] = 2;
      index[7] = 3;
      value[0] = 11.0;
      value[1] = 21.0;
      value[2] = 22.0;
      value[3] = 32.0;
      value[4] = 33.0;
      value[5] = 41.0;
      value[6] = 43.0;
      value[7] = 44.0;

      if (complex) {
        cmplxify(value);
      }
      value = new Vector.from(lis, value);

      var A = new Matrix.csr(lis, n, nnz, ptr, index, value);
      expect(A.diagonal().values(), equals(diagonal));
    });
    test('csc', () {
      var n = 4, nnz = 8;
      var ptr = new Int32List(n + 1);
      var index = new Int32List(nnz);
      var value = new List(nnz);

      ptr[0] = 0;
      ptr[1] = 3;
      ptr[2] = 5;
      ptr[3] = 7;
      ptr[4] = 8;
      index[0] = 0;
      index[1] = 1;
      index[2] = 3;
      index[3] = 1;
      index[4] = 2;
      index[5] = 2;
      index[6] = 3;
      index[7] = 3;
      value[0] = 11.0;
      value[1] = 21.0;
      value[2] = 41.0;
      value[3] = 22.0;
      value[4] = 32.0;
      value[5] = 33.0;
      value[6] = 43.0;
      value[7] = 44.0;

      if (complex) {
        cmplxify(value);
      }
      value = new Vector.from(lis, value);

      var A = new Matrix.csc(lis, n, nnz, ptr, index, value);
      expect(A.diagonal().values(), equals(diagonal));
    });
    test('dia', () {
      var n = 4, nnd = 3;
      var index = new Int32List(nnd);
      var value = new List(n * nnd);

      index[0] = -3;
      index[1] = -1;
      index[2] = 0;
      value[0] = 0.0;
      value[1] = 0.0;
      value[2] = 0.0;
      value[3] = 41.0;
      value[4] = 0.0;
      value[5] = 21.0;
      value[6] = 32.0;
      value[7] = 43.0;
      value[8] = 11.0;
      value[9] = 22.0;
      value[10] = 33.0;
      value[11] = 44.0;

      if (complex) {
        cmplxify(value);
      }
      value = new Vector.from(lis, value);

      var A = new Matrix.dia(lis, n, nnd, index, value);
      expect(A.diagonal().values(), equals(diagonal));
    });
    test('coo', () {
      int n = 4, nnz = 8;
      var row = new Int32List(nnz);
      var col = new Int32List(nnz);
      var value = new List(nnz);

      row[0] = 0;
      row[1] = 1;
      row[2] = 3;
      row[3] = 1;
      row[4] = 2;
      row[5] = 2;
      row[6] = 3;
      row[7] = 3;
      col[0] = 0;
      col[1] = 0;
      col[2] = 0;
      col[3] = 1;
      col[4] = 1;
      col[5] = 2;
      col[6] = 2;
      col[7] = 3;
      value[0] = 11.0;
      value[1] = 21.0;
      value[2] = 41.0;
      value[3] = 22.0;
      value[4] = 32.0;
      value[5] = 33.0;
      value[6] = 43.0;
      value[7] = 44.0;

      if (complex) {
        cmplxify(value);
      }
      value = new Vector.from(lis, value);

      var A = new Matrix.coo(lis, n, nnz, row, col, value);
      expect(A.diagonal().values(), equals(diagonal));
    });

    test('dense', () {
      var n = 4;
      var value = new List(n * n);

      value[0] = 11.0;
      value[1] = 21.0;
      value[2] = 0.0;
      value[3] = 41.0;
      value[4] = 0.0;
      value[5] = 22.0;
      value[6] = 32.0;
      value[7] = 0.0;
      value[8] = 0.0;
      value[9] = 0.0;
      value[10] = 33.0;
      value[11] = 43.0;
      value[12] = 0.0;
      value[13] = 0.0;
      value[14] = 0.0;
      value[15] = 44.0;

      if (complex) {
        cmplxify(value);
      }
      value = new Vector.from(lis, value);

      var A = new Matrix.dense(lis, n, value);
      expect(A.diagonal().values(), equals(diagonal));
    });
  });

  group('mult', () {
    int n;
    Matrix A;
    Vector v;
    setUp(() {
      n = rint();
      var index = range(n).toList();
      var value = new List.generate(n, (i) => toScalar(i));

      v = new Vector.from(lis, value);

      // add duplicate
      var nnz = n; // + 1;
      nnz += 1;
      var j = n - 1;
      index.add(j);
      value[j] = toScalar(j) / 2;
      value.add(toScalar(j) / 2);

      var d = new Matrix.coo(lis, n, nnz, index, index, value);
      A = new Matrix.convert(lis, d, MatrixType.CSR);
      d.destroy();

      A.sortIndexes();
      A.sumDuplicates();

      A.assemble();
    });
    test('matvec', () {
      var vout = A.matvec(v);
      for (int i = 0; i < n; i++) {
        expect(vout[i], equals(toScalar(i) * toScalar(i)));
      }
    });
    test('matmat', () {
      var Aout = A.matmat(A);
      var d = Aout.diagonal();
      for (int i = 0; i < n; i++) {
        expect(d[i], equals(toScalar(i) * toScalar(i)));
      }
    });
  });

  group('compose', () {
    int n;
    Matrix A, B, C, D;
    setUp(() {
      n = rint();
      var value = new List.generate(n, (i) => toScalar(i + 1));
      A = new Matrix.dia(lis, n, 1, [0], value);
      B = new Matrix.dia(lis, n, 1, [0], value);
      C = new Matrix.dia(lis, n, 1, [0], value);
      D = new Matrix.dia(lis, n, 1, [0], value);
    });
    test('simple', () {
      var Y = new Matrix.compose(lis, A, B, C, D);
      expect(Y.size, equals(2 * n));
      expect(Y.nnz, equals(4 * n));
      var d = Y.diagonal().values();
      for (var i = 0; i < 2; i++) {
        for (var j = 0; j < n; j++) {
          expect(d[i * n + j], equals(toScalar(j + 1)));
        }
      }
    });
  });
}
