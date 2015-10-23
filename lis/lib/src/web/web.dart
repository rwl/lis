library lis.internal.web;

import 'package:complex/complex.dart';

import 'module.dart' as module;
import '../lis.dart' as lis;

abstract class WebLIS<S> implements lis.LIS<S> {
  final module.LisModule _lis;

  WebLIS(this._lis, List<String> args) {
    initialize(args);
  }

  // Vector Operations
  int vectorCreate() {
    int pp_vec = _lis.heapInt();
    int err = _lis.callFunc('lis_vector_create', [lis.COMM_WORLD, pp_vec]);
    CHKERR(err);
    return _lis.derefInt(pp_vec);
  }

  void vectorSetSize(int vec, int n) {
    int err = _lis.callFunc('lis_vector_set_size', [vec, 0, n]);
    CHKERR(err);
  }

  void vectorDestroy(int vec) {
    int err = _lis.callFunc('lis_vector_destroy', [vec]);
    CHKERR(err);
  }

  int vectorDuplicate(int vin) {
    int pp_vout = _lis.heapInt();
    var err = _lis.callFunc('lis_vector_duplicate', [vin, pp_vout]);
    CHKERR(err);
    return _lis.derefInt(pp_vout);
  }

  int vectorGetSize(int v) {
    int p_local_n = _lis.heapInt();
    int p_global_n = _lis.heapInt();
    int err = _lis.callFunc('lis_vector_get_size', [v, p_local_n, p_global_n]);
    CHKERR(err);
    _lis.free(p_local_n);
    return _lis.derefInt(p_global_n);
  }

  S vectorGetValue(int v, int i) {
    int p_value = _lis.heapScalar();
    int err = _lis.callFunc('lis_vector_get_value', [v, i, p_value]);
    CHKERR(err);
    return _lis.derefScalar(p_value);
  }

  List<S> vectorGetValues(int v, int start, int count) {
    var vals = new List.generate(count, (_) => zero);
    int p_value = _lis.heapScalars(vals);
    int err =
        _lis.callFunc('lis_vector_get_values', [v, start, count, p_value]);
    CHKERR(err);
    return _lis.derefScalars(p_value, count);
  }

  void vectorSetValue(int flag, int i, S value, int v) {
    int err;
    if (value is Complex) {
      var cval = value as Complex;
      err = _lis.callFunc(
          'zlis_vector_set_value', [flag, i, cval.real, cval.imaginary, v]);
    } else {
      err = _lis.callFunc('lis_vector_set_value', [flag, i, value, v]);
    }
    CHKERR(err);
  }

  void vectorSetValues(
      int flag, int count, List<int> index, List<S> value, int v) {
    int count = index.length;
    int p_index = _lis.heapInts(index);
    int p_value = _lis.heapScalars(value);
    int err = _lis.callFunc(
        'lis_vector_set_values', [flag, count, p_index, p_value, v]);
    CHKERR(err);
    _lis.free(p_index);
    _lis.free(p_value);
  }

  void vectorSetValues2(int flag, int start, int count, List<S> value, int v) {
    int count = value.length;
    int p_value = _lis.heapScalars(value);
    int err = _lis.callFunc(
        'lis_vector_set_values2', [flag, start, count, p_value, v]);
    CHKERR(err);
    _lis.free(p_value);
  }

  void vectorPrint(int x) {
    int err = _lis.callFunc('lis_vector_print', [x]);
    CHKERR(err);
  }

  int vectorIsNull(int v) {
    return _lis.callFunc('lis_vector_is_null', [v]);
  }

  void vectorSwap(int vsrc, int vdst) {
    int err = _lis.callFunc('lis_vector_swap', [vsrc, vdst]);
    CHKERR(err);
  }

  void vectorCopy(int vsrc, int vdst) {
    int err = _lis.callFunc('lis_vector_copy', [vsrc, vdst]);
    CHKERR(err);
  }

  void vectorAxpy(S alpha, int vx, int vy) {
    if (alpha == null) {
      alpha = one;
    }
    int err;
    if (alpha is Complex) {
      var calpha = alpha as Complex;
      err = _lis.callFunc(
          'zlis_vector_axpy', [calpha.real, calpha.imaginary, vx, vy]);
    } else {
      err = _lis.callFunc('lis_vector_axpy', [alpha, vx, vy]);
    }
    CHKERR(err);
  }

  void vectorXpay(int vx, S alpha, int vy) {
    if (alpha == null) {
      alpha = one;
    }
    int err;
    if (alpha is Complex) {
      var calpha = alpha as Complex;
      err = _lis.callFunc(
          'zlis_vector_xpay', [vx, calpha.real, calpha.imaginary, vy]);
    } else {
      err = _lis.callFunc('lis_vector_xpay', [vx, alpha, vy]);
    }
    CHKERR(err);
  }

  void vectorAxpyz(S alpha, int vx, int vy, int vz) {
    if (alpha == null) {
      alpha = one;
    }
    int err;
    if (alpha is Complex) {
      var calpha = alpha as Complex;
      err = _lis.callFunc(
          'zlis_vector_axpyz', [calpha.real, calpha.imaginary, vx, vy, vz]);
    } else {
      err = _lis.callFunc('lis_vector_axpyz', [alpha, vx, vy, vz]);
    }
    CHKERR(err);
  }

  void vectorScale(S alpha, int vx) {
    int err;
    if (alpha is Complex) {
      var calpha = alpha as Complex;
      err = _lis.callFunc(
          'zlis_vector_scale', [calpha.real, calpha.imaginary, vx]);
    } else {
      err = _lis.callFunc('lis_vector_scale', [alpha, vx]);
    }
    CHKERR(err);
  }

  void vectorPmul(int vx, int vy, int vz) {
    int err = _lis.callFunc('lis_vector_pmul', [vx, vy, vz]);
    CHKERR(err);
  }

  void vectorPdiv(int vx, int vy, int vz) {
    int err = _lis.callFunc('lis_vector_pdiv', [vx, vy, vz]);
    CHKERR(err);
  }

  void vectorSetAll(S alpha, int vx) {
    int err;
    if (alpha is Complex) {
      var calpha = alpha as Complex;
      err = _lis.callFunc(
          'zlis_vector_set_all', [calpha.real, calpha.imaginary, vx]);
    } else {
      err = _lis.callFunc('lis_vector_set_all', [alpha, vx]);
    }
    CHKERR(err);
  }

  void vectorAbs(int vx) {
    int err = _lis.callFunc('lis_vector_abs', [vx]);
    CHKERR(err);
  }

  void vectorReciprocal(int vx) {
    int err = _lis.callFunc('lis_vector_reciprocal', [vx]);
    CHKERR(err);
  }

  void vectorShift(S alpha, int vx) {
    int err;
    if (alpha is Complex) {
      var calpha = alpha as Complex;
      err = _lis.callFunc(
          'zlis_vector_shift', [calpha.real, calpha.imaginary, vx]);
    } else {
      err = _lis.callFunc('lis_vector_shift', [alpha, vx]);
    }
    CHKERR(err);
  }

  S vectorDot(int vx, int vy) {
    int p_value = _lis.heapScalar();
    int err = _lis.callFunc('lis_vector_dot', [vx, vy, p_value]);
    CHKERR(err);
    return _lis.derefScalar(p_value);
  }

  double vectorNrm1(int vx) {
    int p_value = _lis.heapDouble();
    int err = _lis.callFunc('lis_vector_nrm1', [vx, p_value]);
    CHKERR(err);
    return _lis.derefDouble(p_value);
  }

  double vectorNrm2(int vx) {
    int p_value = _lis.heapDouble();
    int err = _lis.callFunc('lis_vector_nrm2', [vx, p_value]);
    CHKERR(err);
    return _lis.derefDouble(p_value);
  }

  double vectorNrmi(int vx) {
    int p_value = _lis.heapDouble();
    int err = _lis.callFunc('lis_vector_nrmi', [vx, p_value]);
    CHKERR(err);
    return _lis.derefDouble(p_value);
  }

  S vectorSum(int vx) {
    int p_value = _lis.heapScalar();
    int err = _lis.callFunc('lis_vector_sum', [vx, p_value]);
    CHKERR(err);
    return _lis.derefScalar(p_value);
  }

  void vectorReal(int vx) {
    int err = _lis.callFunc('lis_vector_real', [vx]);
    CHKERR(err);
  }

  void vectorImaginary(int vx) {
    int err = _lis.callFunc('lis_vector_imaginary', [vx]);
    CHKERR(err);
  }

  void vectorArgument(int vx) {
    int err = _lis.callFunc('lis_vector_argument', [vx]);
    CHKERR(err);
  }

  void vectorConjugate(int vx) {
    int err = _lis.callFunc('lis_vector_conjugate', [vx]);
    CHKERR(err);
  }

  // Matrix Operations
  int matrixCreate() {
    int pp_mat = _lis.heapInt();
    int err = _lis.callFunc('lis_matrix_create', [lis.COMM_WORLD, pp_mat]);
    CHKERR(err);
    return _lis.derefInt(pp_mat);
  }

  void matrixDestroy(int Amat) {
    int err = _lis.callFunc('lis_matrix_destroy', [Amat]);
    CHKERR(err);
  }

  void matrixAssemble(int A) {
    int err = _lis.callFunc('lis_matrix_assemble', [A]);
    CHKERR(err);
  }

  int matrixIsAssembled(int A) {
    return _lis.callFunc('lis_matrix_is_assembled', [A]);
  }

  int matrixDuplicate(int Ain) {
    int pp_Aout = _lis.heapInt();
    int err = _lis.callFunc('lis_matrix_duplicate', [Ain, pp_Aout]);
    CHKERR(err);
    return _lis.derefInt(pp_Aout);
  }

  void matrixSetSize(int A, int n) {
    int err = _lis.callFunc('lis_matrix_set_size', [A, 0, n]);
    CHKERR(err);
  }

  int matrixGetSize(int A) {
    int p_local_n = _lis.heapInt();
    int p_global_n = _lis.heapInt();
    int err = _lis.callFunc('lis_matrix_get_size', [A, p_local_n, p_global_n]);
    CHKERR(err);
    _lis.free(p_local_n);
    return _lis.derefInt(p_global_n);
  }

  int matrixGetNnz(int A) {
    int p_nnz = _lis.heapInt();
    int err = _lis.callFunc('lis_matrix_get_nnz', [A, p_nnz]);
    CHKERR(err);
    return _lis.derefInt(p_nnz);
  }

  void matrixSetType(int A, int matrix_type) {
    int err = _lis.callFunc('lis_matrix_set_type', [A, matrix_type]);
    CHKERR(err);
  }

  int matrixGetType(int A) {
    int p_type = _lis.heapInt();
    int err = _lis.callFunc('lis_matrix_get_type', [A, p_type]);
    CHKERR(err);
    return _lis.derefInt(p_type);
  }

  void matrixSetValue(int flag, int i, int j, S value, int A) {
    int err;
    if (value is Complex) {
      var cval = value as Complex;
      err = _lis.callFunc(
          'zlis_matrix_set_value', [flag, i, j, cval.real, cval.imaginary, A]);
    } else {
      err = _lis.callFunc('lis_matrix_set_value', [flag, i, j, value, A]);
    }
    CHKERR(err);
  }

  void matrixSetValues(int flag, int n, List<S> value, int A) {
    int p_values = _lis.heapScalars(value);
    int err = _lis.callFunc('lis_matrix_set_values', [flag, n, p_values, A]);
    CHKERR(err);
    _lis.free(p_values);
  }

  void matrixMalloc(int A, int nnz_row, List<int> nnz) {
    int p_nnz = _lis.heapInts(nnz);
    int err = _lis.callFunc('lis_matrix_malloc', [A, nnz_row, p_nnz]);
    CHKERR(err);
    if (p_nnz != 0) {
      _lis.free(p_nnz);
    }
  }

  void matrixGetDiagonal(int A, int d) {
    int err = _lis.callFunc('lis_matrix_get_diagonal', [A, d]);
    CHKERR(err);
  }

  void matrixConvert(int Ain, int Aout) {
    int err = _lis.callFunc('lis_matrix_convert', [Ain, Aout]);
    CHKERR(err);
  }

  void matrixCopy(int Ain, int Aout) {
    int err = _lis.callFunc('lis_matrix_copy', [Ain, Aout]);
    CHKERR(err);
  }

  void matrixTranspose(int Ain, int Aout) {
    int err = _lis.callFunc('lis_matrix_transpose', [Ain, Aout]);
    CHKERR(err);
  }

  void matrixSetCsr(
      int nnz, List<int> row, List<int> index, List<S> value, int A) {
    var p_ptr = _lis.heapInts(row);
    var p_index = _lis.heapInts(index);
    var p_value = _lis.heapScalars(value);
    int err =
        _lis.callFunc('lis_matrix_set_csr', [nnz, p_ptr, p_index, p_value, A]);
    CHKERR(err);
  }

  void matrixSetCsc(
      int nnz, List<int> row, List<int> index, List<S> value, int A) {
    var p_ptr = _lis.heapInts(row);
    var p_index = _lis.heapInts(index);
    var p_value = _lis.heapScalars(value);
    int err =
        _lis.callFunc('lis_matrix_set_csc', [nnz, p_ptr, p_index, p_value, A]);
    CHKERR(err);
  }

  void matrixSetBsr(int bnr, int bnc, int bnnz, List<int> bptr,
      List<int> bindex, List<S> value, int A) {}

  void matrixSetMsr(int nnz, int ndz, List<int> index, List<S> value, int A) {}

  void matrixSetEll(int maxnzr, List<int> index, List<S> value, int A) {}

  void matrixSetJad(int nnz, int maxnzr, List<int> perm, List<int> ptr,
      List<int> index, List<S> value, int A) {}

  void matrixSetDia(int nnd, List<int> index, List<S> value, int A) {
    var p_index = _lis.heapInts(index);
    var p_value = _lis.heapScalars(value);
    int err = _lis.callFunc('lis_matrix_set_dia', [nnd, p_index, p_value, A]);
    CHKERR(err);
  }

  void matrixSetBsc(int bnr, int bnc, int bnnz, List<int> bptr,
      List<int> bindex, List<S> value, int A) {}

  void matrixSetVbr(
      int nnz,
      int nr,
      int nc,
      int bnnz,
      List<int> row,
      List<int> col,
      List<int> ptr,
      List<int> bptr,
      List<int> bindex,
      List<S> value,
      int A) {}

  void matrixSetCoo(
      int nnz, List<int> row, List<int> col, List<S> value, int A) {
    var p_row = _lis.heapInts(row);
    var p_col = _lis.heapInts(col);
    var p_value = _lis.heapScalars(value);
    int err =
        _lis.callFunc('lis_matrix_set_coo', [nnz, p_row, p_col, p_value, A]);
    CHKERR(err);
  }

  void matrixSetDns(List<S> value, int A) {
    var p_value = _lis.heapScalars(value);
    int err = _lis.callFunc('lis_matrix_set_dns', [p_value, A]);
    CHKERR(err);
  }

  // Matrix-Vector Operations
  void matvec(int A, int x, int y) {
    int err = _lis.callFunc('lis_matvec', [A, x, y]);
    CHKERR(err);
  }

  void matvect(int A, int x, int y) {
    int err = _lis.callFunc('lis_matvect', [A, x, y]);
    CHKERR(err);
  }

  // Linear Solvers

  int solverCreate() {
    int pp_solver = _lis.heapInt();
    int err = _lis.callFunc('lis_solver_create', [pp_solver]);
    CHKERR(err);
    return _lis.derefInt(pp_solver);
  }

  void solverDestroy(int solver) {
    int err = _lis.callFunc('lis_solver_destroy', [solver]);
    CHKERR(err);
  }

  int solverGetIter(int solver) {
    int p_iter = _lis.heapInt();
    int err = _lis.callFunc('lis_solver_get_iter', [solver, p_iter]);
    CHKERR(err);
    return _lis.derefInt(p_iter);
  }

  lis.Iter solverGetIterEx(int solver) {
    int p_iter = _lis.heapInt();
    int p_iter_double = _lis.heapInt();
    int p_iter_quad = _lis.heapInt();
    int err = _lis.callFunc(
        'lis_solver_get_iterex', [solver, p_iter, p_iter_double, p_iter_quad]);
    CHKERR(err);
    return new lis.Iter(_lis.derefInt(p_iter), _lis.derefInt(p_iter_double),
        _lis.derefInt(p_iter_quad));
  }

  double solverGetTime(int solver) {
    int p_time = _lis.heapDouble();
    int err = _lis.callFunc('lis_solver_get_time', [solver, p_time]);
    CHKERR(err);
    return _lis.derefDouble(p_time);
  }

  lis.Time solverGetTimeEx(int solver) {
    int p_time = _lis.heapDouble();
    int p_itime = _lis.heapDouble();
    int p_ptime = _lis.heapDouble();
    int p_p_c_time = _lis.heapDouble();
    int p_p_i_time = _lis.heapDouble();
    int err = _lis.callFunc('lis_solver_get_timeex',
        [solver, p_time, p_itime, p_ptime, p_p_c_time, p_p_i_time]);
    CHKERR(err);
    return new lis.Time(
        _lis.derefDouble(p_time),
        _lis.derefDouble(p_itime),
        _lis.derefDouble(p_ptime),
        _lis.derefDouble(p_p_c_time),
        _lis.derefDouble(p_p_i_time));
  }

  double solverGetResidualNorm(int solver) {
    int p_norm = _lis.heapDouble();
    int err = _lis.callFunc('lis_solver_get_residualnorm', [solver, p_norm]);
    CHKERR(err);
    return _lis.derefDouble(p_norm);
  }

  int solverGetSolver(int solver) {
    int p_nsol = _lis.heapInt();
    int err = _lis.callFunc('lis_solver_get_solver', [solver, p_nsol]);
    CHKERR(err);
    return _lis.derefInt(p_nsol);
  }

  int solverGetPrecon(int solver) {
    int p_precon = _lis.heapInt();
    int err = _lis.callFunc('lis_solver_get_precon', [solver, p_precon]);
    CHKERR(err);
    return _lis.derefInt(p_precon);
  }

  int solverGetStatus(int solver) {
    int p_status = _lis.heapInt();
    int err = _lis.callFunc('lis_solver_get_status', [solver, p_status]);
    CHKERR(err);
    return _lis.derefInt(p_status);
  }

  void solverGetRHistory(int solver, int v) {
    int err = _lis.callFunc('lis_solver_get_rhistory', [solver, v]);
    CHKERR(err);
  }

  void solverSetOption(String text, int solver) {
    int p_text = _lis.heapString(text);
    int err = _lis.callFunc('lis_solver_set_option', [p_text, solver]);
    CHKERR(err);
    _lis.free(p_text);
  }

  void solverSetOptionC(int solver) {
    int err = _lis.callFunc('lis_solver_set_optionC', [solver]);
    CHKERR(err);
  }

  void solve(int A, int b, int x, int solver) {
    int err = _lis.callFunc('lis_solve', [A, b, x, solver]);
    CHKERR(err);
  }

  // Eigensolvers

  int esolverCreate() {
    int pp_solver = _lis.heapInt();
    int err = _lis.callFunc('lis_esolver_create', [pp_solver]);
    CHKERR(err);
    return _lis.derefInt(pp_solver);
  }

  void esolverDestroy(int esolver) {
    int err = _lis.callFunc('lis_esolver_destroy', [esolver]);
    CHKERR(err);
  }

  void esolverSetOption(String text, int esolver) {
    int p_text = _lis.heapString(text);
    int err = _lis.callFunc('lis_esolver_set_option', [p_text, esolver]);
    CHKERR(err);
    _lis.free(p_text);
  }

  void esolverSetOptionC(int esolver) {
    int err = _lis.callFunc('lis_esolver_set_optionC', [esolver]);
    CHKERR(err);
  }

  S esolve(int A, int x, int esolver) {
    int p_evalue = _lis.heapScalar();
    int err = _lis.callFunc('lis_esolve', [A, x, p_evalue, esolver]);
    CHKERR(err);
    return _lis.derefScalar(p_evalue);
  }

  int esolverGetIter(int esolver) {
    int p_iter = _lis.heapInt();
    int err = _lis.callFunc('lis_esolver_get_iter', [esolver, p_iter]);
    CHKERR(err);
    return _lis.derefInt(p_iter);
  }

  lis.Iter esolverGetIterEx(int esolver) {
    int p_iter = _lis.heapInt();
    int p_iter_double = _lis.heapInt();
    int p_iter_quad = _lis.heapInt();
    int err = _lis.callFunc('lis_esolver_get_iterex',
        [esolver, p_iter, p_iter_double, p_iter_quad]);
    CHKERR(err);
    return new lis.Iter(_lis.derefInt(p_iter), _lis.derefInt(p_iter_double),
        _lis.derefInt(p_iter_quad));
  }

  double esolverGetTime(int esolver) {
    int p_time = _lis.heapDouble();
    int err = _lis.callFunc('lis_esolver_get_time', [esolver, p_time]);
    CHKERR(err);
    return _lis.derefDouble(p_time);
  }

  lis.Time esolverGetTimeEx(int esolver) {
    int p_time = _lis.heapDouble();
    int p_itime = _lis.heapDouble();
    int p_ptime = _lis.heapDouble();
    int p_p_c_time = _lis.heapDouble();
    int p_p_i_time = _lis.heapDouble();
    int err = _lis.callFunc('lis_esolver_get_timeex',
        [esolver, p_time, p_itime, p_ptime, p_p_c_time, p_p_i_time]);
    CHKERR(err);
    return new lis.Time(
        _lis.derefDouble(p_time),
        _lis.derefDouble(p_itime),
        _lis.derefDouble(p_ptime),
        _lis.derefDouble(p_p_c_time),
        _lis.derefDouble(p_p_i_time));
  }

  double esolverGetResidualNorm(int esolver) {
    int p_norm = _lis.heapDouble();
    int err = _lis.callFunc('lis_esolver_get_residualnorm', [esolver, p_norm]);
    CHKERR(err);
    return _lis.derefDouble(p_norm);
  }

  int esolverGetStatus(int esolver) {
    int p_status = _lis.heapInt();
    int err = _lis.callFunc('lis_esolver_get_status', [esolver, p_status]);
    CHKERR(err);
    return _lis.derefInt(p_status);
  }

  void esolverGetRHistory(int esolver, int v) {
    int err = _lis.callFunc('lis_esolver_get_rhistory', [esolver, v]);
    CHKERR(err);
  }

  void esolverGetEvalues(int esolver, int v) {
    int err = _lis.callFunc('lis_esolver_get_evalues', [esolver, v]);
    CHKERR(err);
  }

  void esolverGetEvectors(int esolver, int M) {
    int err = _lis.callFunc('lis_esolver_get_evectors', [esolver, M]);
    CHKERR(err);
  }

  void esolverGetResidualNorms(int esolver, int v) {
    int err = _lis.callFunc('lis_esolver_get_residualnorms', [esolver, v]);
    CHKERR(err);
  }

  void esolverGetIters(int esolver, int v) {
    int err = _lis.callFunc('lis_esolver_get_iters', [esolver, v]);
    CHKERR(err);
  }

  int esolverGetEsolver(int esolver) {
    int p_nesol = _lis.heapInt();
    int err = _lis.callFunc('lis_esolver_get_esolver', [esolver, p_nesol]);
    CHKERR(err);
    return _lis.derefInt(p_nesol);
  }

  // I/O Functions
  void input(int A, int b, int x, String s) {
    int p_path = _lis.writeFile(s);
    int err = _lis.callFunc('lis_input', [A, b, x, p_path]);
    CHKERR(err);
    _lis.removeFile(p_path);
  }

  void inputMatrix(int A, String s) {
    int p_path = _lis.writeFile(s);
    int err = _lis.callFunc('lis_input_matrix', [A, p_path]);
    CHKERR(err);
    _lis.removeFile(p_path);
  }

  void inputVector(int v, String s) {
    int p_path = _lis.writeFile(s);
    int err = _lis.callFunc('lis_input_vector', [v, p_path]);
    CHKERR(err);
    _lis.removeFile(p_path);
  }

  String output(int A, int b, int x, int mode) {
    int p_path = _lis.heapPath();
    int err = _lis.callFunc('lis_output', [A, b, x, mode, p_path]);
    CHKERR(err);
    return _lis.readFile(p_path);
  }

  String outputMatrix(int A, int mode) {
    int p_path = _lis.heapPath();
    int err = _lis.callFunc('lis_output_matrix', [A, mode, p_path]);
    CHKERR(err);
    return _lis.readFile(p_path);
  }

  String outputVector(int v, int format) {
    int p_path = _lis.heapPath();
    int err = _lis.callFunc('lis_output_vector', [v, format, p_path]);
    CHKERR(err);
    return _lis.readFile(p_path);
  }

  String solverOutputRHistory(int solver) {
    int p_path = _lis.heapPath();
    int err = _lis.callFunc('lis_solver_output_rhistory', [solver, p_path]);
    CHKERR(err);
    return _lis.readFile(p_path);
  }

  String esolverOutputRHistory(int esolver) {
    int p_path = _lis.heapPath();
    int err = _lis.callFunc('lis_esolver_output_rhistory', [esolver, p_path]);
    CHKERR(err);
    return _lis.readFile(p_path);
  }

  // Utilities
  void initialize(List<String> options) {
    if (options == null) {
      options = [];
    }
    options = ['lis']..addAll(options);
    int argc = _lis.heapInt(options.length);
    int p_args = _lis.heapStrings(options);
    int argv = _lis.heapInt(p_args);
    int err = _lis.callFunc('lis_initialize', [argc, argv]);
    CHKERR(err);
  }

  void finalize() {
    _lis.callFunc('lis_finalize');
  }

  void CHKERR(int err) {
    if (err != 0) {
      finalize();
      throw err; // TODO: LisError
    }
  }
}
