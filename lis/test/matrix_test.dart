library lis.test.matrix;

import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:lis/lis.dart';

import 'random.dart';

testMatrix() {
  group('matrix', () {
    LIS lis;
    Matrix m;

    setUp(() {
      lis = new LIS();
      m = new Matrix(lis);
    });

    tearDown(() {
      m.destroy();
      lis.finalize();
    });

    test('assemble', () {
      expect(m.assembled(), isTrue);
      m.size = rint();
      expect(m.assembled(), isFalse);
      m.setValue(0, 0, rand());
      expect(m.assembled(), isTrue);
      m.type = MatrixType.DENSE;
      expect(m.assembled(), isTrue);
      m.assemble();
      expect(m.assembled(), isTrue);
    });
    test('duplicate', () {
      var size = rint();
      m.size = size;
      m.setValue(0, 0, rand());
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
        m.setValue(i, i, rand());
      }
      m.assemble();
      expect(m.nnz, equals(size));
    });
    test('type', () {
      MatrixType.values.forEach((t) {
        if (t == MatrixType.ASSEMBLING) {
          return;
        }
        var m2 = new Matrix(lis);
        m2.size = rint();
        m2.setValue(0, 0, rand());
        m2.type = t;
        m2.assemble();
        expect(m2.type, equals(t));
        m2.destroy();
      });
    });
    test('setValue', () {
      m.size = rint();
      expect(() => m.setValue(0, 0, rand()), returnsNormally);
    });
    test('setValues', () {
      var size = rint();
      m.size = size;
      var vals = new Float64List(size * size);
      for (var i = 0; i < size * size; i++) {
        vals[i] - rint();
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
        m.setValue(0, 0, rand());
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
        m.setValue(0, 0, rand());
        m.assemble();
      });
    });
    test('diagonal', () {
      var size = rint();
      m.size = size;
      var vals = new Float64List(size);
      for (var i = 0; i < size; i++) {
        vals[i] = rand();
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
        m.setValue(i, i, rand());
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
        m.setValue(i, i, rand());
      }
      m.assemble();

      var m2 = m.copy();
      expect(m2.type, equals(m.type));
      expect(m2.diagonal().values(), equals(m.diagonal().values()));
    });
    test('csr', () {
      var n = 4, nnz = 8;
      var csr = new CSR(lis, n, nnz);

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

      var A = new Matrix.csr(lis, csr);
      expect(A.diagonal().values(), equals([11.0, 22.0, 33.0, 44.0]));
    });
  });
}
