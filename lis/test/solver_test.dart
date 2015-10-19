library lis.test1;

import 'package:test/test.dart';
import 'package:lis/lis.dart';
import 'package:lis/web/zlis.dart';

import 'random.dart' show rand;
import 'testmat.dart';

solverTest(LIS lis, rscal()) {
  test('basic', () {
    var n = 30;
    var row = <int>[];
    var col = <int>[];
    var value = [];
    for (var r = 0; r < n; r++) {
      for (var c = 0; c < n; c++) {
        if (r == c) {
          row.add(r);
          col.add(c);
          value.add(rscal() * 4.0); // dominant diagonal (non-singular)
        } else if (rand() > 0.9) {
          row.add(r);
          col.add(c);
          value.add(rscal());
        }
      }
    }

    var coo = new Coo(n, value.length)
      ..value.setAll(0, value)
      ..row.setAll(0, row)
      ..col.setAll(0, col);

    var A = new Matrix.coo(lis, coo);
    var b = new Vector(lis, n)..fill(lis.one);

    var solver = new LinearSolver(lis);
    var x = solver.solve(A, b);

    var b2 = A * x;
    for (var i = 0; i < n; i++) {
      expect(b2[i], closeTo(b[i], 1e-9));
    }

    A.destroy();
    b.destroy();
    x.destroy();
    b2.destroy();
    solver.destroy();
  });

  test('solve', () {
    if (lis is ZLIS) {
      return;
    }

    // read matrix and vectors
    var lp = new LinearProblem(lis, testmat);
    Matrix A = lp.A;
    Vector b = lp.b; //, x = lp.x;

    var A0 = A.duplicate();
    A0.type = MatrixType.CSR;
    A.convert(A0);
    A.destroy();
    A = A0;

    var solver = new LinearSolver(lis);

    var x = solver.solve(A, b);

    var b2 = A.mult(x);
    for (var i = 0; i < b2.size; i++) {
      expect(b2[i], closeTo(b[i], 1e-9));
    }

    solver.destroy();
    x.destroy();
    b.destroy();
    b2.destroy();
    A.destroy();
  });

  test('duplicate', () {
    if (lis is ZLIS) {
      return;
    }

    var n = 5;
    var nnz = 12;
    var row = [0, 1, 0, 2, 4, 1, 2, 3, 4, 2, 1, 4];
    var col = [0, 0, 1, 1, 1, 2, 2, 2, 2, 3, 4, 4];
    var value = [2.0, 3.0, 3.0, -1.0, 4.0, 4.0, -3.0, 1.0, 2.0, 2.0, 6.0, 1.0];
    var b = new Vector.from(lis, [8.0, 45.0, -3.0, 3.0, 19.0]);
    var expected = [1.0, 2.0, 3.0, 4.0, 5.0];

    // add a duplicate entry
    nnz += 1;
    row.add(0);
    col.add(0);
    value.add(value[0] / 2);
    value[0] /= 2;

    var coo = new Coo(n, nnz);
    coo.value.setAll(0, value);
    coo.row.setAll(0, row);
    coo.col.setAll(0, col);

    var A = new Matrix.coo(lis, coo);

    var B = A.copy();
    var b0 = B * new Vector.from(lis, expected);
    for (var i = 0; i < n; i++) {
      expect(b0[i], closeTo(b[i], 1e-9));
    }

    var solver = new LinearSolver(lis);

    var x = solver.solve(A, b);

    for (var i = 0; i < n; i++) {
      expect(x[i], closeTo(expected[i], 1e-9));
    }

    solver.destroy();
    x.destroy();
    b.destroy();
    A.destroy();
  });
}
