part of lis.internal;

class EigenSolver<S> {
  final _LIS _lis;
  final int _p_solve;

  factory EigenSolver(_LIS lis) {
    int pp_solver = lis.heapInt();
    int err = lis.callFunc('lis_esolver_create', [pp_solver]);
    lis._CHKERR(err);
    int p_solve = lis.derefInt(pp_solver);
    return new EigenSolver._(lis, p_solve);
  }

  EigenSolver._(this._lis, this._p_solve);

  void destroy() {
    int err = _lis.callFunc('lis_esolver_destroy', [_p_solve]);
    _lis._CHKERR(err);
  }

  void setOption(String text) {
    int p_text = _lis.heapString(text);
    int err = _lis.callFunc('lis_esolver_set_option', [p_text, _p_solve]);
    _lis._CHKERR(err);
    _lis.free(p_text);
  }

  void setOptionC() {
    int err = _lis.callFunc('lis_esolver_set_optionC', [_p_solve]);
    _lis._CHKERR(err);
  }

  S solve(Matrix A, Vector x) {
    int p_evalue = _lis.heapScalar();
    int err =
        _lis.callFunc('lis_esolve', [A._p_mat, x._p_vec, p_evalue, _p_solve]);
    _lis._CHKERR(err);
    return _lis.derefScalar(p_evalue);
  }

  int iter() {
    int p_iter = _lis.heapInt();
    int err = _lis.callFunc('lis_esolver_get_iter', [_p_solve, p_iter]);
    _lis._CHKERR(err);
    return _lis.derefInt(p_iter);
  }

  Iter iterex() {
    int p_iter = _lis.heapInt();
    int p_iter_double = _lis.heapInt();
    int p_iter_quad = _lis.heapInt();
    int err = _lis.callFunc('lis_esolver_get_iterex',
        [_p_solve, p_iter, p_iter_double, p_iter_quad]);
    _lis._CHKERR(err);
    return new Iter._(_lis.derefInt(p_iter), _lis.derefInt(p_iter_double),
        _lis.derefInt(p_iter_quad));
  }

  double time() {
    int p_time = _lis.heapDouble();
    int err = _lis.callFunc('lis_esolver_get_time', [_p_solve, p_time]);
    _lis._CHKERR(err);
    return _lis.derefDouble(p_time);
  }

  Time timeex() {
    int p_time = _lis.heapDouble();
    int p_itime = _lis.heapDouble();
    int p_ptime = _lis.heapDouble();
    int p_p_c_time = _lis.heapDouble();
    int p_p_i_time = _lis.heapDouble();
    int err = _lis.callFunc('lis_esolver_get_timeex',
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
    int err = _lis.callFunc('lis_esolver_get_residualnorm', [_p_solve, p_norm]);
    _lis._CHKERR(err);
    return _lis.derefDouble(p_norm);
  }

  int status() {
    int p_status = _lis.heapInt();
    int err = _lis.callFunc('lis_esolver_get_status', [_p_solve, p_status]);
    _lis._CHKERR(err);
    return _lis.derefInt(p_status);
  }

  Vector rhistory([Vector v]) {
    if (v == null) {
      v = new Vector(_lis)..size = iter() + 1;
    }
    int err = _lis.callFunc('lis_esolver_get_rhistory', [_p_solve, v._p_vec]);
    _lis._CHKERR(err);
    return v;
  }

  Vector evalues([Vector v]) {
    if (v == null) {
      v = new Vector(_lis)..size = iter() + 1;
    }
    int err = _lis.callFunc('lis_esolver_get_evalues', [_p_solve, v._p_vec]);
    _lis._CHKERR(err);
    return v;
  }

  Matrix evectors([Matrix m]) {
    if (m == null) {
      m = new Matrix(_lis)..size = iter() + 1;
    }
    int err = _lis.callFunc('lis_esolver_get_evectors', [_p_solve, m._p_mat]);
    _lis._CHKERR(err);
    return m;
  }

  Vector residualnorms([Vector v]) {
    if (v == null) {
      v = new Vector(_lis)..size = iter() + 1;
    }
    int err =
        _lis.callFunc('lis_esolver_get_residualnorms', [_p_solve, v._p_vec]);
    _lis._CHKERR(err);
    return v;
  }

  Vector iters([Vector v]) {
    if (v == null) {
      v = new Vector(_lis)..size = iter() + 1;
    }
    int err = _lis.callFunc('lis_esolver_get_iters', [_p_solve, v._p_vec]);
    _lis._CHKERR(err);
    return v;
  }

  EigenSolverType esolver() {
    int p_nesol = _lis.heapInt();
    int err = _lis.callFunc('lis_esolver_get_esolver', [_p_solve, p_nesol]);
    _lis._CHKERR(err);
    return EigenSolverType.values[_lis.derefInt(p_nesol)];
  }

  String output() {
    int p_path = _lis._heapPath();
    int err = _lis.callFunc('lis_esolver_output_rhistory', [_p_solve, p_path]);
    _lis._CHKERR(err);
    return _lis._readFile(p_path);
  }
}

class EigenSolverType {
  static const PI = const EigenSolverType._('Power', 1);
  static const II = const EigenSolverType._('Inverse', 2);
  static const AII = const EigenSolverType._('Approximate Inverse', 3);
  static const RQI = const EigenSolverType._('Rayleigh Quotient', 4);
  static const CG = const EigenSolverType._('CG', 5);
  static const CR = const EigenSolverType._('CR', 6);
  static const JD = const EigenSolverType._('JD', 7);
  static const SI = const EigenSolverType._('Subspace', 8);
  static const LI = const EigenSolverType._('Lanczos', 9);
  static const AI = const EigenSolverType._('Arnoldi', 10);

  static const List<EigenSolverType> values = const [
    null,
    PI,
    II,
    AII,
    RQI,
    CG,
    CR,
    JD,
    SI,
    LI,
    AI
  ];

  final String name;
  final int nesol;

  const EigenSolverType._(this.name, this.nesol);
}
