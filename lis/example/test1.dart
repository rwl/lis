import 'package:lis/lis.dart';

main(List<String> args) {
//  Matrix A0, A;
//  Vector x, b, u;
//  Solver solver;
//  int nprocs, my_rank;
//  int int_nprocs, int_my_rank;
//  int nsol, rhs, len;
//  int err, iter, iter_double, iter_quad;
//  double time, itime, ptime, p_c_time, p_i_time;
//  double resid;
//  List<int> solvername = new List(128);

//  lis.LIS_DEBUG_FUNC_IN();

  final lis = new LIS(args);

  var nprocs = 1;
  var my_rank = 0;

  if (args.length < 5) {
    if (my_rank == 0) {
      print(
          "Usage: ${args.first} matrix_filename rhs_setting solution_filename rhistory_filename [options]");
    }
    lis.finalize();
    return;
  }

  var len = args[2].length;
  int rhs;
  if (len == 1) {
    if (args[2][0] == '0' || args[2][0] == '1' || args[2][0] == '2') {
      rhs = int.parse(args[2]);
    } else {
      rhs = -1;
    }
  } else {
    rhs = -1;
  }

  if (my_rank == 0) {
    print("");
    print("number of processes = $nprocs");
  }

//  int err;
  /* read matrix and vectors from file */
  var A = new Matrix(lis);
//  CHKERR(err);
  var b = new Vector(lis);
//  CHKERR(err);
  var x = new Vector(lis);
//  CHKERR(err);
  lis.input(A, b, x, args[1]);
//  CHKERR(err);

  var A0 = A.duplicate();
//  CHKERR(err);
  A0.set_type(LIS_MATRIX_CSR);
  err = lis.matrix_convert(A, A0);
  lis.CHKERR(err);
  A.destroy();
  A = A0;

  var u = lis.vector_duplicate(A);
//  CHKERR(err);
  if (lis.vector_is_null(b)) {
    b.destroy();
    b = lis.vector_duplicate(A);
//    CHKERR(err);
    if (rhs == 0) {
      lis.CHKERR(1);
    } else if (rhs == 1) {
      b.set_all(1.0);
    } else {
      u.set_all(1.0);
      lis.matvec(A, u, b);
    }
  }
  if (rhs == -1) {
    lis.input_vector(b, args[2]);
  }
  if (lis.vector_is_null(x)) {
    x.destroy();
    x = lis.vector_duplicate(A);
//    CHKERR(err);
  }

  var solver = new LinearSolver(lis);
//  CHKERR(err);
  solver.set_option("-print mem");
  solver.set_optionC();

  try {
    solver.solve(A, b, x);
  } catch (_) {}

//  CHKERR(err);
  solver.iterex(/*&*/ iter, /*&*/ iter_double, /*&*/ iter_quad);
  lis_solver_get_timeex(
      solver, /*&*/ time, /*&*/ itime, /*&*/ ptime, /*&*/ p_c_time, /*&*/ p_i_time);
  lis_solver_get_residualnorm(solver, /*&*/ resid);
  lis_solver_get_solver(solver, /*&*/ nsol);
  lis_solver_get_solvername(nsol, solvername);

  /* write results */
  if (my_rank == 0) {
    print(
        "$solvername: number of iterations = $iter (double = $iter_double, quad = $iter_quad)");
    print("$solvername: elapsed time         = $time sec.");
    print("$solvername:   preconditioner     = $ptime sec.");
    print("$solvername:     matrix creation  = $p_c_time sec.");
    print("$solvername:   linear solver      = $itime sec.");
    print("$solvername: relative residual    = $resid\n");
  }

  /* write solution */
  x.output(LIS_FMT_MM, args[3]);

  /* write residual history */
  solver.output_rhistory(args[4]);

  solver.destroy();
  x.destroy();
  u.destroy();
  b.destroy();
  A.destroy();

  lis.finalize();

  lis.LIS_DEBUG_FUNC_OUT;
}
