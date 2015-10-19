part of lis.internal;

class Matrix<S> {
  final LIS _lis;
  final int _p_mat;

  Matrix._(this._lis, this._p_mat);

  factory Matrix(LIS lis, [int size, MatrixType type]) {
    int p_mat = lis.matrixCreate();
    var m = new Matrix<S>._(lis, p_mat);
    if (size != null) {
      m.size = size;
    }
    if (type != null) {
      m.type = type;
    }
    return m;
  }

  factory Matrix.csr(LIS lis, CSR csr) {
    var m = new Matrix(lis)..size = csr.n;
    lis.matrixSetCsr(csr.nnz, csr.ptr, csr.index, csr.value, m._p_mat);
    m.assemble();
    return m;
  }

  factory Matrix.csc(LIS lis, CSC csc) {
    var m = new Matrix(lis)..size = csc.n;
    lis.matrixSetCsc(csc.nnz, csc.ptr, csc.index, csc.value, m._p_mat);
    m.assemble();
    return m;
  }

  factory Matrix.dia(LIS lis, Dia dia) {
    var m = new Matrix(lis)..size = dia.n;
    lis.matrixSetDia(dia.nnd, dia.index, dia.value, m._p_mat);
    m.assemble();
    return m;
  }

  factory Matrix.coo(LIS lis, Coo coo) {
    var m = new Matrix(lis)..size = coo.n;
    lis.matrixSetCoo(coo.nnz, coo.row, coo.col, coo.value, m._p_mat);
    m.assemble();
    return m;
  }

  factory Matrix.dense(LIS lis, Dense dense) {
    var m = new Matrix(lis)..size = dense.n;
    lis.matrixSetDns(dense.value, m._p_mat);
    m.assemble();
    return m;
  }

  factory Matrix.input(LIS lis, String data) {
    var A = new Matrix(lis);
    lis.inputMatrix(A._p_mat, data);
    return A;
  }

  String output() => _lis.outputMatrix(_p_mat, Format.MM.index);

  void destroy() => _lis.matrixDestroy(_p_mat);

  void assemble() => _lis.matrixAssemble(_p_mat);

  bool assembled() => _lis.matrixIsAssembled(_p_mat) != 0;

  Matrix<S> duplicate() {
    int p_Aout = _lis.matrixDuplicate(_p_mat);
    return new Matrix._(_lis, p_Aout);
  }

  void set size(int sz) => _lis.matrixSetSize(_p_mat, sz);

  int get size => _lis.matrixGetSize(_p_mat);

  int get nnz => _lis.matrixGetNnz(_p_mat);

  void set type(MatrixType t) => _lis.matrixSetType(_p_mat, t._index);

  MatrixType get type {
    int t = _lis.matrixGetType(_p_mat);
    return MatrixType.values[t];
  }

  void setValue(int i, int j, S value, [Flag flag = Flag.INSERT]) {
    _lis.matrixSetValue(flag.index, i, j, value, _p_mat);
  }

  void setValues(List<S> values, [Flag flag = Flag.INSERT]) {
    int n = size; //sqrt(values.length).toInt();
    if (values.length != n * n) {
      throw new ArgumentError.value(values);
    }
    _lis.matrixSetValues(flag.index, n, values, _p_mat);
  }

  /// Either [nnz_row] or [nnz] must be provided.
  void malloc({int nnz_row, List<int> nnz}) {
    if (nnz_row == null && nnz == null) {
      throw new ArgumentError("Either `nnz_row` or `nnz` must be provided");
    }
    _lis.matrixMalloc(_p_mat, nnz_row, nnz);
  }

  Vector<S> diagonal([Vector<S> d]) {
    if (d == null) {
      d = new Vector.fromMatrix(_lis, this);
    }
    _lis.matrixGetDiagonal(_p_mat, d._p_vec);
    return d;
  }

  void convert(Matrix<S> Aout) => _lis.matrixConvert(_p_mat, Aout._p_mat);

  Matrix<S> copy([Matrix<S> Aout]) {
    if (Aout == null) {
      Aout = duplicate();
    }
    _lis.matrixCopy(_p_mat, Aout._p_mat);
    return Aout;
  }

  Vector<S> mult(Vector<S> vx, [Vector<S> vy]) {
    if (vy == null) {
      vy = vx.duplicate();
    }
    _lis.matvec(_p_mat, vx._p_vec, vy._p_vec);
    return vy;
  }

  Vector<S> operator *(Vector<S> vx) => mult(vx);

  Vector<S> multT(Vector<S> vx, [Vector<S> vy]) {
    if (vy == null) {
      vy = vx.duplicate();
    }
    _lis.matvect(_p_mat, vx._p_vec, vy._p_vec);
    return vy;
  }

  Matrix<S> transpose([Matrix<S> Aout]) {
    if (Aout == null) {
      Aout = duplicate();
    }
    _lis.matrixTranspose(_p_mat, Aout._p_mat);
    return Aout;
  }
}

class CSR<S> {
  final int n;
  final int nnz;
  final List<int> ptr;
  final List<int> index;
  final List<S> value;

  CSR(int n_, int nnz_)
      : n = n_,
        nnz = nnz_,
        ptr = new List<int>(n_ + 1),
        index = new List<int>(nnz_),
        value = new List<S>(nnz_);

  CSR.from(this.n, this.nnz, this.ptr, this.index, this.value);
}

class CSC<S> {
  final int n;
  final int nnz;
  final List<int> ptr;
  final List<int> index;
  final List<S> value;

  CSC(int n_, int nnz_)
      : n = n_,
        nnz = nnz_,
        ptr = new List<int>(n_ + 1),
        index = new List<int>(nnz_),
        value = new List<S>(nnz_);

  CSC.from(this.n, this.nnz, this.ptr, this.index, this.value);
}

class Dia<S> {
  final int n;
  final int nnd;
  final List<int> index;
  final List<S> value;

  Dia(int n_, int nnd_)
      : n = n_,
        nnd = nnd_,
        index = new List<int>(nnd_), // TODO: n*nnd
        value = new List<S>(n_ * nnd_);

  Dia.from(this.n, this.nnd, this.index, this.value);
}

class Coo<S> {
  final int n;
  final int nnz;
  final List<int> row, col;
  final List<S> value;

  Coo(this.n, int nnz_)
      : nnz = nnz_,
        row = new List<int>(nnz_),
        col = new List<int>(nnz_),
        value = new List<S>(nnz_);

  Coo.from(this.n, this.nnz, this.row, this.col, this.value);
}

class Dense<S> {
  final int n;
  final int np;
  final List<S> value;

  Dense(int n_, [int np_])
      : n = n_,
        np = (np_ == null ? n_ : np_),
        value = new List<S>(n_ * (np_ == null ? n_ : np_));

  Dense.from(this.n, this.np, this.value);
}

class MatrixType {
  /// Compressed Sparse Row
  static const CSR = const MatrixType._('CSR', 1);

  /// Compressed Sparse Column
  static const CSC = const MatrixType._('CSC', 2);

  /// Modified Compressed Sparse Row
  static const MSR = const MatrixType._('MSR', 3);

  /// Diagonal
  static const DIA = const MatrixType._('DIA', 4);

  /// Ellpack-Itpack Generalized Diagonal
  static const ELL = const MatrixType._('ELL', 5);

  /// Jagged Diagonal
  static const JAD = const MatrixType._('JAD', 6);

  /// Block Sparse Row
  static const BSR = const MatrixType._('BSR', 7);

  /// Block Sparse Column
  static const BSC = const MatrixType._('BSC', 8);

  /// Variable Block Row
  static const VBR = const MatrixType._('VBR', 9);

  /// Coordinate
  static const COO = const MatrixType._('COO', 10);
  static const DENSE = const MatrixType._('DENSE', 11);

  static final List<MatrixType> values = [
    null,
    CSR,
    CSC,
    MSR,
    DIA,
    ELL,
    JAD,
    BSR,
    BSC,
    VBR,
    COO,
    DENSE
  ];

  final String _name;
  final int _index;

  const MatrixType._(this._name, this._index);

  String toString() => 'MatrixType.$_name';
}
