library lis.test1;

import 'package:lis/lis.dart';
import '../testmat.dart';

main([List<String> args]) {
  var lis = new LIS(args);

  // create matrix and vectors
  var A = new Matrix.input(lis, testmat);
  var x = new Vector.fromMatrix(lis, A);

  var esolver = new EigenSolver(lis);
  esolver.setOption("-eprint mem");
  esolver.setOptionC();
  var evalue0 = esolver.solve(A, x);

  var sol = esolver.esolver();
  var residual = esolver.residualnorm();
  var iter = esolver.iter();
  var iterex = esolver.timeex();

  print("${sol.name}: eigenvalue           = $evalue0");
  print("${sol.name}: number of iterations = $iter");
  print("${sol.name}: elapsed time         = ${iterex.time} sec.");
  print("${sol.name}:   preconditioner     = ${iterex.ptime} sec.");
  print("${sol.name}:     matrix creation  = ${iterex.p_c_time} sec.");
  print("${sol.name}:   linear solver      = ${iterex.itime} sec.");
  print("${sol.name}: relative residual    = $residual\n");

  // write eigenvector
  print(x.output(Format.MM));

  // write residual history
  print(esolver.output());

  esolver.destroy();
  A.destroy();
  x.destroy();

  lis.finalize();
}
