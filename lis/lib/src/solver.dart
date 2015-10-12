part of lis.internal;

class LinearSolver<S> {
  final LIS _lis;
  final int _p_solve;

  factory LinearSolver(LIS lis) {
    int pp_solver = lis.heapInt();
    int err = lis.callFunc('lis_solver_create', [pp_solver]);
    lis._CHKERR(err);
    int p_solve = lis.derefInt(pp_solver);
    return new LinearSolver._(lis, p_solve);
  }

  LinearSolver._(this._lis, this._p_solve);

  void destroy() {
    int err = _lis.callFunc('lis_solver_destroy', [_p_solve]);
    _lis._CHKERR(err);
  }

  int iter() {
    int p_iter = _lis.heapInt();
    int err = _lis.callFunc('lis_solver_get_iter', [_p_solve, p_iter]);
    _lis._CHKERR(err);
    return _lis.derefInt(p_iter);
  }

  Iter iterex() {
    int p_iter = _lis.heapInt();
    int p_iter_double = _lis.heapInt();
    int p_iter_quad = _lis.heapInt();
    int err = _lis.callFunc('lis_solver_get_iterex',
        [_p_solve, p_iter, p_iter_double, p_iter_quad]);
    _lis._CHKERR(err);
    return new Iter._(_lis.derefInt(p_iter), _lis.derefInt(p_iter_double),
        _lis.derefInt(p_iter_quad));
  }

  double time() {
    int p_time = _lis.heapDouble();
    int err = _lis.callFunc('lis_solver_get_time', [_p_solve, p_time]);
    _lis._CHKERR(err);
    return _lis.derefDouble(p_time);
  }

  Time timeex() {
    int p_time = _lis.heapDouble();
    int p_itime = _lis.heapDouble();
    int p_ptime = _lis.heapDouble();
    int p_p_c_time = _lis.heapDouble();
    int p_p_i_time = _lis.heapDouble();
    int err = _lis.callFunc('lis_solver_get_timeex',
        [_p_solve, p_time, p_itime, p_ptime, p_p_c_time, p_p_i_time]);
    _lis._CHKERR(err);
    return new Time._(
        _lis.derefDouble(p_time),
        _lis.derefDouble(p_itime),
        _lis.derefDouble(p_ptime),
        _lis.derefDouble(p_p_c_time),
        _lis.derefDouble(p_p_i_time));
  }

  double residualnorm() {
    int p_norm = _lis.heapDouble();
    int err = _lis.callFunc('lis_solver_get_residualnorm', [_p_solve, p_norm]);
    _lis._CHKERR(err);
    return _lis.derefDouble(p_norm);
  }

  LinearSolverType solver() {
    int p_nsol = _lis.heapInt();
    int err = _lis.callFunc('lis_solver_get_solver', [_p_solve, p_nsol]);
    _lis._CHKERR(err);
    return LinearSolverType.values[_lis.derefInt(p_nsol)];
  }

  PreconType precon() {
    int p_precon = _lis.heapInt();
    int err = _lis.callFunc('lis_solver_get_precon', [_p_solve, p_precon]);
    _lis._CHKERR(err);
    return PreconType.values[_lis.derefInt(p_precon)];
  }

  int status() {
    int p_status = _lis.heapInt();
    int err = _lis.callFunc('lis_solver_get_status', [_p_solve, p_status]);
    _lis._CHKERR(err);
    return _lis.derefInt(p_status);
  }

  Vector rhistory([Vector v]) {
    if (v == null) {
      v = new Vector(_lis)..size = iter() + 1;
    }
    int err = _lis.callFunc('lis_solver_get_rhistory', [_p_solve, v._p_vec]);
    _lis._CHKERR(err);
    return v;
  }

  void setOption(String text) {
    int p_text = _lis.heapString(text);
    int err = _lis.callFunc('lis_solver_set_option', [p_text, _p_solve]);
    _lis._CHKERR(err);
    _lis.free(p_text);
  }

  void setOptionC() {
    int err = _lis.callFunc('lis_solver_set_optionC', [_p_solve]);
    _lis._CHKERR(err);
  }

  Vector<S> solve(Matrix<S> A, Vector<S> b, [Vector<S> x]) {
    if (x == null) {
      x = new Vector.fromMatrix(_lis, A);
    }
    int err =
        _lis.callFunc('lis_solve', [A._p_mat, b._p_vec, x._p_vec, _p_solve]);
    _lis._CHKERR(err);
    return x;
  }

  //LIS_INT lis_solve_kernel(LIS_MATRIX A, LIS_VECTOR b, LIS_VECTOR x, LIS_SOLVER solver, LIS_PRECON precon);
  //LIS_PRECON_REGISTER *precon_register_top;
  //LIS_INT precon_register_type;
  //LIS_INT lis_precon_register(char *name, LIS_PRECON_CREATE_XXX pcreate, LIS_PSOLVE_XXX psolve, LIS_PSOLVET_XXX psolvet);
  //LIS_INT lis_precon_register_free(void);

  //LIS_INT lis_solver_get_solvername(LIS_INT solver, char *solvername);
  //LIS_INT lis_solver_get_preconname(LIS_INT precon_type, char *preconname);

  String output() {
    int p_path = _lis._heapPath();
    int err = _lis.callFunc('lis_solver_output_rhistory', [_p_solve, p_path]);
    _lis._CHKERR(err);
    return _lis._readFile(p_path);
  }
}

class Iter {
  final int iter, iter_double, iter_quad;
  Iter._(this.iter, this.iter_double, this.iter_quad);
}

class Time {
  final double time, itime, ptime, p_c_time, p_i_time;
  Time._(this.time, this.itime, this.ptime, this.p_c_time, this.p_i_time);
}

class LinearSolverType {
  static const CG = const LinearSolverType._('CG', 1);
  static const BICG = const LinearSolverType._('BiCG', 2);
  static const CGS = const LinearSolverType._('CGS', 3);
  static const BICGSTAB = const LinearSolverType._('BiCGSTAB', 4);
  static const BICGSTABL = const LinearSolverType._('BICGSTAB(l)', 5);
  static const GPBICG = const LinearSolverType._('GPBICG', 6);
  static const TFQMR = const LinearSolverType._('TFQMR', 7);
  static const ORTHOMIN = const LinearSolverType._('Orthomin', 8);
  static const GMRES = const LinearSolverType._('GMRES', 9);
  static const JACOBI = const LinearSolverType._('Jacobi', 10);
  static const GS = const LinearSolverType._('Gauss-Seidel', 11);
  static const SOR = const LinearSolverType._('SOR', 12);
  static const BICGSAFE = const LinearSolverType._('BiCGSafe', 13);
  static const CR = const LinearSolverType._('CR', 14);
  static const BICR = const LinearSolverType._('BiCR', 15);
  static const CRS = const LinearSolverType._('CRS', 16);
  static const BICRSTAB = const LinearSolverType._('BiCRSTAB', 17);
  static const GPBICR = const LinearSolverType._('GPBiCR', 18);
  static const BICRSAFE = const LinearSolverType._('BiCRSafe', 19);
  static const FGMRES = const LinearSolverType._('FGMRES', 20);
  static const IDRS = const LinearSolverType._('IDR(s)', 21);
  static const MINRES = const LinearSolverType._('CG', 22);
  static const IDR1 = const LinearSolverType._('IDR(1)', 23);

  static const List<LinearSolverType> values = const [
    null,
    CG,
    BICG,
    CGS,
    BICGSTAB,
    BICGSTABL,
    GPBICG,
    TFQMR,
    ORTHOMIN,
    GMRES,
    JACOBI,
    GS,
    SOR,
    BICGSAFE,
    CR,
    BICR,
    CRS,
    BICRSTAB,
    GPBICR,
    BICRSAFE,
    FGMRES,
    IDRS,
    MINRES,
    IDR1
  ];

  final String name;
  final int nsol;

  const LinearSolverType._(this.name, this.nsol);
}

class PreconType {
  static const NONE = const PreconType._('none', 0);
  static const JACOBI = const PreconType._('Jacobi', 1);
  static const ILU = const PreconType._('ILU', 2);
  static const SSOR = const PreconType._('SSOR', 3);
  static const HYBRID = const PreconType._('Hybrid', 4);
  static const IS = const PreconType._('I+S', 5);
  static const SAI = const PreconType._('SAINV', 6);
  static const SAAMG = const PreconType._('SAAMG', 7);
  static const ILUC = const PreconType._('Crout ILU', 8);
  static const ILUT = const PreconType._('ILUT', 9);
  static const BJACOBI = const PreconType._('Block Jacobi', 10);

  static const List<PreconType> values = const [
    NONE,
    JACOBI,
    ILU,
    SSOR,
    HYBRID,
    IS,
    SAI,
    SAAMG,
    ILUC,
    ILUT,
    BJACOBI
  ];

  final String name;
  final int _index;

  const PreconType._(this.name, this._index);
}
