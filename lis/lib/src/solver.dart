part of lis.internal;

class LinearSolver<S> {
  final LIS<S> _lis;
  final int _p_solve;

  factory LinearSolver(LIS lis) {
    int p_solve = lis.solverCreate();
    return new LinearSolver._(lis, p_solve);
  }

  LinearSolver._(this._lis, this._p_solve);

  void destroy() => _lis.solverDestroy(_p_solve);

  int iter() => _lis.solverGetIter(_p_solve);

  Iter iterex() => _lis.solverGetIterEx(_p_solve);

  double time() => _lis.solverGetTime(_p_solve);

  Time timeex() => _lis.solverGetTimeEx(_p_solve);

  double residualnorm() => _lis.solverGetResidualNorm(_p_solve);

  LinearSolverType solver() {
    int nsol = _lis.solverGetSolver(_p_solve);
    return LinearSolverType.values[nsol];
  }

  PreconType precon() {
    int precon = _lis.solverGetPrecon(_p_solve);
    return PreconType.values[precon];
  }

  int status() => _lis.solverGetStatus(_p_solve);

  Vector rhistory([Vector v]) {
    if (v == null) {
      v = new Vector(_lis)..size = iter() + 1;
    }
    _lis.solverGetRHistory(_p_solve, v._p_vec);
    return v;
  }

  void setOption(String text) => _lis.solverSetOption(text, _p_solve);

  void setOptionC() => _lis.solverSetOptionC(_p_solve);

  Vector<S> solve(Matrix<S> A, Vector<S> b, [Vector<S> x]) {
    if (x == null) {
      x = new Vector.fromMatrix(_lis, A);
    }
    _lis.solve(A._p_mat, b._p_vec, x._p_vec, _p_solve);
    return x;
  }

  String output() => _lis.solverOutputRHistory(_p_solve);
}

class Iter {
  final int iter, iter_double, iter_quad;
  Iter(this.iter, this.iter_double, this.iter_quad);
}

class Time {
  final double time, itime, ptime, p_c_time, p_i_time;
  Time(this.time, this.itime, this.ptime, this.p_c_time, this.p_i_time);
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
