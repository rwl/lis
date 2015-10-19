library lis.test.matrix;

import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:lis/lis.dart';
import 'package:lis/web/zlis.dart' as zlis;
import 'package:complex/complex.dart';

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

    var m2 = new Matrix(lis);
    m2.size = size;
    m2.type = MatrixType.CSC;
    m.convert(m2);
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
      var coo = new Coo(n, 2 * n);
      for (int i = 0; i < n; i++) {
        coo.row[2 * i] = i;
        coo.col[2 * i] = i;
        coo.value[2 * i] = lis.one;

        coo.row[2 * i + 1] = i;
        coo.col[2 * i + 1] = n - 1 - i;
        coo.value[2 * i + 1] = toScalar(i + 1);
      }
      A = new Matrix.coo(lis, coo);
      ones = new Vector(lis, n)..fill(lis.one);
    });
    tearDown(() {
      A.destroy();
      ones.destroy();
    });
    for (var matrixType in [MatrixType.CSR, MatrixType.CSC]) {
      test(matrixType.toString(), () {
        var AA = new Matrix(lis, A.size, matrixType);
        A.convert(AA);
        var At = AA.transpose();

        expect(At.type, equals(matrixType));
        expect(At.diagonal().values(), equals(AA.diagonal().values()));

        var Asum = AA * ones;
        var Atsum = At * ones;

        expect(Atsum.values().reversed, equals(Asum.values()));
      });
    }
  });

  group('factory', () {
    cmplxify(List list) {
      for (var i = 0; i < list.length; i++) {
        list[i] = new Complex(list[i]);
      }
    }

    var diagonal = [11.0, 22.0, 33.0, 44.0];
    if (lis is zlis.ZLIS) {
      cmplxify(diagonal);
    }

    test('csr', () {
      var n = 4, nnz = 8;
      var csr = new CSR(n, nnz);

      csr.ptr[0] = 0;
      csr.ptr[1] = 1;
      csr.ptr[2] = 3;
      csr.ptr[3] = 5;
      csr.ptr[4] = 8;
      csr.index[0] = 0;
      csr.index[1] = 0;
      csr.index[2] = 1;
      csr.index[3] = 1;
      csr.index[4] = 2;
      csr.index[5] = 0;
      csr.index[6] = 2;
      csr.index[7] = 3;
      csr.value[0] = 11.0;
      csr.value[1] = 21.0;
      csr.value[2] = 22.0;
      csr.value[3] = 32.0;
      csr.value[4] = 33.0;
      csr.value[5] = 41.0;
      csr.value[6] = 43.0;
      csr.value[7] = 44.0;

      if (lis is zlis.ZLIS) {
        cmplxify(csr.value);
      }

      var A = new Matrix.csr(lis, csr);
      expect(A.diagonal().values(), equals(diagonal));
    });
    test('csc', () {
      var n = 4, nnz = 8;
      var csc = new CSC(n, nnz);

      csc.ptr[0] = 0;
      csc.ptr[1] = 3;
      csc.ptr[2] = 5;
      csc.ptr[3] = 7;
      csc.ptr[4] = 8;
      csc.index[0] = 0;
      csc.index[1] = 1;
      csc.index[2] = 3;
      csc.index[3] = 1;
      csc.index[4] = 2;
      csc.index[5] = 2;
      csc.index[6] = 3;
      csc.index[7] = 3;
      csc.value[0] = 11.0;
      csc.value[1] = 21.0;
      csc.value[2] = 41.0;
      csc.value[3] = 22.0;
      csc.value[4] = 32.0;
      csc.value[5] = 33.0;
      csc.value[6] = 43.0;
      csc.value[7] = 44.0;

      if (lis is zlis.ZLIS) {
        cmplxify(csc.value);
      }

      var A = new Matrix.csc(lis, csc);
      expect(A.diagonal().values(), equals(diagonal));
    });
    test('dia', () {
      var n = 4, nnd = 3;
      var dia = new Dia(n, nnd);

      dia.index[0] = -3;
      dia.index[1] = -1;
      dia.index[2] = 0;
      dia.value[0] = 0.0;
      dia.value[1] = 0.0;
      dia.value[2] = 0.0;
      dia.value[3] = 41.0;
      dia.value[4] = 0.0;
      dia.value[5] = 21.0;
      dia.value[6] = 32.0;
      dia.value[7] = 43.0;
      dia.value[8] = 11.0;
      dia.value[9] = 22.0;
      dia.value[10] = 33.0;
      dia.value[11] = 44.0;

      if (lis is zlis.ZLIS) {
        cmplxify(dia.value);
      }

      var A = new Matrix.dia(lis, dia);
      expect(A.diagonal().values(), equals(diagonal));
    });
    test('coo', () {
      int n = 4, nnz = 8;
      var coo = new Coo(n, nnz);

      coo.row[0] = 0;
      coo.row[1] = 1;
      coo.row[2] = 3;
      coo.row[3] = 1;
      coo.row[4] = 2;
      coo.row[5] = 2;
      coo.row[6] = 3;
      coo.row[7] = 3;
      coo.col[0] = 0;
      coo.col[1] = 0;
      coo.col[2] = 0;
      coo.col[3] = 1;
      coo.col[4] = 1;
      coo.col[5] = 2;
      coo.col[6] = 2;
      coo.col[7] = 3;
      coo.value[0] = 11.0;
      coo.value[1] = 21.0;
      coo.value[2] = 41.0;
      coo.value[3] = 22.0;
      coo.value[4] = 32.0;
      coo.value[5] = 33.0;
      coo.value[6] = 43.0;
      coo.value[7] = 44.0;

      if (lis is zlis.ZLIS) {
        cmplxify(coo.value);
      }

      var A = new Matrix.coo(lis, coo);
      expect(A.diagonal().values(), equals(diagonal));
    });

    test('dense', () {
      var n = 4;
      var dense = new Dense(n);

      dense.value[0] = 11.0;
      dense.value[1] = 21.0;
      dense.value[2] = 0.0;
      dense.value[3] = 41.0;
      dense.value[4] = 0.0;
      dense.value[5] = 22.0;
      dense.value[6] = 32.0;
      dense.value[7] = 0.0;
      dense.value[8] = 0.0;
      dense.value[9] = 0.0;
      dense.value[10] = 33.0;
      dense.value[11] = 43.0;
      dense.value[12] = 0.0;
      dense.value[13] = 0.0;
      dense.value[14] = 0.0;
      dense.value[15] = 44.0;

      if (lis is zlis.ZLIS) {
        cmplxify(dense.value);
      }

      var A = new Matrix.dense(lis, dense);
      expect(A.diagonal().values(), equals(diagonal));
    });
  });
}
