library lis.test1;

import 'package:lis/lis.dart';
import 'package:lis/web/dlis.dart';

import '../testmat.dart';

main([List<String> args]) {
  var lis = new DLIS(args);

  bool flat = true;

  // read matrix and vectors
  var lp = new LinearProblem(lis, testmat);
  Matrix A = lp.A;
  Vector b = lp.b, x = lp.x;

  var A0 = A.duplicate();
  A0.type = MatrixType.CSR;
  A.convert(A0);
  A.destroy();
  A = A0;

  var u = new Vector.fromMatrix(lis, A);
  if (b.isNull()) {
    b.destroy();
    if (flat) {
      b = new Vector.fromMatrix(lis, A);
      b.fill(1.0);
    } else {
      u.fill(1.0);
      b = A * u;
    }
  }
  if (x.isNull()) {
    x.destroy();
    x = new Vector.fromMatrix(lis, A);
  }

  var solver = new LinearSolver(lis);
  solver.setOption("-print mem");
  solver.setOptionC();

  solver.solve(A, b, x);

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

  // write solution
  print(x.output(Format.MM));

  // write residual history
  print(solver.output());

  solver.destroy();
  x.destroy();
  u.destroy();
  b.destroy();
  A.destroy();

  lis.finalize();
}
