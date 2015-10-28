part of lis.internal;

class EigenSolver<S> {
  final LIS<S> _lis;
  final int _p_solve;

  factory EigenSolver(LIS lis) {
    int p_solve = lis.esolverCreate();
    return new EigenSolver._(lis, p_solve);
  }

  EigenSolver._(this._lis, this._p_solve);

  void destroy() => _lis.esolverDestroy(_p_solve);

  void setOption(String text) => _lis.esolverSetOption(text, _p_solve);

  void setOptionC() => _lis.esolverSetOptionC(_p_solve);

  S solve(Matrix A, Vector x) => _lis.esolve(A._p_mat, x._p_vec, _p_solve);

  int iter() => _lis.esolverGetIter(_p_solve);

  Iter iterex() => _lis.esolverGetIterEx(_p_solve);

  double time() => _lis.esolverGetTime(_p_solve);

  Time timeex() => _lis.esolverGetTimeEx(_p_solve);

  double residualnorm() => _lis.esolverGetResidualNorm(_p_solve);

  int status() => _lis.esolverGetStatus(_p_solve);

  Vector rhistory([Vector v]) {
    if (v == null) {
      v = new Vector(_lis)..size = iter() + 1;
    }
    _lis.esolverGetRHistory(_p_solve, v._p_vec);
    return v;
  }

  Vector evalues([Vector v]) {
    if (v == null) {
      v = new Vector(_lis)..size = iter() + 1;
    }
    _lis.esolverGetEvalues(_p_solve, v._p_vec);
    return v;
  }

  Matrix evectors([Matrix m]) {
    if (m == null) {
      m = new Matrix(_lis)..size = iter() + 1;
    }
    _lis.esolverGetEvectors(_p_solve, m._p_mat);
    return m;
  }

  Vector residualnorms([Vector v]) {
    if (v == null) {
      v = new Vector(_lis)..size = iter() + 1;
    }
    _lis.esolverGetResidualNorms(_p_solve, v._p_vec);
    return v;
  }

  Vector iters([Vector v]) {
    if (v == null) {
      v = new Vector(_lis)..size = iter() + 1;
    }
    _lis.esolverGetIters(_p_solve, v._p_vec);
    return v;
  }

  EigenSolverType esolver() {
    int nesol = _lis.esolverGetEsolver(_p_solve);
    return EigenSolverType.values[nesol];
  }

  String output() => _lis.esolverOutputRHistory(_p_solve);
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
