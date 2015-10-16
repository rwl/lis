library lis.test1;

import 'package:test/test.dart';
import 'package:lis/lis.dart';

solverTest(LIS lis, String data, rscal()) {
  /*test('solve', () {
    var A = new Matrix.input(lis, data);

    var A0 = A.duplicate();
    A0.type = MatrixType.CSR;
    A.convert(A0);
    A.destroy();
    A = A0;

    var x0 = new Vector.fromMatrix(lis, A);
    x0.setAll(0, new List.generate(x0.size, (_) => rscal() * 10.0));
    var b0 = A * x0;

    var solver = new LinearSolver(lis);
    solver.setOption("-print mem");
    solver.setOptionC();

    var x = solver.solve(A, b0.copy());

    var iterx = solver.iterex();
    var timeex = solver.timeex();
    var resid = solver.residualnorm();
    var sol = solver.solver();

    // write results
    print("${sol.name}: number of iterations = ${iterx.iter} "
        "(double = ${iterx.iter_double}, quad = ${iterx.iter_quad})");
    print("${sol.name}: elapsed time         = ${timeex.time} sec.");
    print("${sol.name}:   preconditioner     = ${timeex.ptime} sec.");
    print("${sol.name}:     matrix creation  = ${timeex.p_c_time} sec.");
    print("${sol.name}:   linear solver      = ${timeex.itime} sec.");
    print("${sol.name}: relative residual    = $resid\n");

    expect(x.values(), equals(x0.values()));

    solver.destroy();
    x.destroy();
    x0.destroy();
    b0.destroy();
    A.destroy();
  });*/
  test('simple', () {
    var ptr = [0, 2, 5, 9, 10, 12];
    var index = [0, 1, 0, 2, 4, 1, 2, 3, 4, 2, 1, 4];
    var value = [2.0, 3.0, 3.0, -1.0, 4.0, 4.0, -3.0, 1.0, 2.0, 2.0, 6.0, 1.0];
    var b = new Vector.from(lis, [8.0, 45.0, -3.0, 3.0, 19.0]);
    var expected = [1.0, 2.0, 3.0, 4.0, 5.0];

    var n = 5;
    var nnz = 12;
    var csc = new CSC(n, nnz);

    csc.ptr.setAll(0, ptr);
    csc.index.setAll(0, index);
    csc.value.setAll(0, value);

    var A = new Matrix.csc(lis, csc);

    var B = A.copy();
    var b0 = B * new Vector.from(lis, expected);
    for (var i = 0; i < n; i++) {
      expect(b0[i], closeTo(b[i], 1e-9));
    }

    var solver = new LinearSolver(lis);
    solver.setOption("-print mem");
    solver.setOptionC();

    var x = solver.solve(A, b);

    var iterx = solver.iterex();
    var timeex = solver.timeex();
    var resid = solver.residualnorm();
    var sol = solver.solver();

    // write results
    print("${sol.name}: number of iterations = ${iterx.iter} "
        "(double = ${iterx.iter_double}, quad = ${iterx.iter_quad})");
    print("${sol.name}: elapsed time         = ${timeex.time} sec.");
    print("${sol.name}:   preconditioner     = ${timeex.ptime} sec.");
    print("${sol.name}:     matrix creation  = ${timeex.p_c_time} sec.");
    print("${sol.name}:   linear solver      = ${timeex.itime} sec.");
    print("${sol.name}: relative residual    = $resid\n");

    for (var i = 0; i < n; i++) {
      expect(x[i], closeTo(expected[i], 1e-9));
    }

    solver.destroy();
    x.destroy();
    b.destroy();
    A.destroy();
  });
}
