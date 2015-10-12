part of lis.internal;

class Matrix<S> {
  final LIS _lis;
  final int _p_mat;
  Matrix._(this._lis, this._p_mat);

  factory Matrix(LIS lis) {
    int pp_mat = lis.heapInt();
    int err = lis.callFunc('lis_matrix_create', [COMM_WORLD, pp_mat]);
    lis._CHKERR(err);
    int p_mat = lis.derefInt(pp_mat);
    return new Matrix<S>._(lis, p_mat);
  }

  factory Matrix.csr(LIS lis, CSR csr) {
    var p_ptr = lis.heapInts(csr.ptr);
    var p_index = lis.heapInts(csr.index);
    var p_value = lis.heapScalars(csr.value);
    var m = new Matrix(lis)..size = csr.n;
    int err = lis.callFunc(
        'lis_matrix_set_csr', [csr.nnz, p_ptr, p_index, p_value, m._p_mat]);
    lis._CHKERR(err);
    m.assemble();
    return m;
  }

  factory Matrix.csc(LIS lis, CSC csc) {
    var p_ptr = lis.heapInts(csc.ptr);
    var p_index = lis.heapInts(csc.index);
    var p_value = lis.heapScalars(csc.value);
    var m = new Matrix(lis)..size = csc.n;
    int err = lis.callFunc(
        'lis_matrix_set_csc', [csc.nnz, p_ptr, p_index, p_value, m._p_mat]);
    lis._CHKERR(err);
    m.assemble();
    return m;
  }

  factory Matrix.dia(LIS lis, Dia dia) {
    var p_index = lis.heapInts(dia.index);
    var p_value = lis.heapScalars(dia.value);
    var m = new Matrix(lis)..size = dia.n;
    int err = lis.callFunc(
        'lis_matrix_set_dia', [dia.nnd, p_index, p_value, m._p_mat]);
    lis._CHKERR(err);
    m.assemble();
    return m;
  }

  factory Matrix.coo(LIS lis, Coo coo) {
    var p_row = lis.heapInts(coo.row);
    var p_col = lis.heapInts(coo.col);
    var p_value = lis.heapScalars(coo.value);
    var m = new Matrix(lis)..size = coo.n;
    int err = lis.callFunc(
        'lis_matrix_set_coo', [coo.nnz, p_row, p_col, p_value, m._p_mat]);
    lis._CHKERR(err);
    m.assemble();
    return m;
  }

  factory Matrix.dense(LIS lis, Dense dense) {
    var p_value = lis.heapScalars(dense.value);
    var m = new Matrix(lis)..size = dense.n;
    int err = lis.callFunc('lis_matrix_set_dns', [p_value, m._p_mat]);
    lis._CHKERR(err);
    m.assemble();
    return m;
  }

  factory Matrix.input(LIS lis, String data) {
    var A = new Matrix(lis);
    int p_path = lis._writeFile(data);
    int err = lis.callFunc('lis_input_matrix', [A._p_mat, p_path]);
    lis._CHKERR(err);
    lis._removeFile(p_path);
    return A;
  }

  String output() {
    int p_path = _lis._heapPath();
    int err =
        _lis.callFunc('lis_output_matrix', [_p_mat, Format.MM.index, p_path]);
    _lis._CHKERR(err);
    return _lis._readFile(p_path);
  }

  void destroy() {
    int err = _lis.callFunc('lis_matrix_destroy', [_p_mat]);
    _lis._CHKERR(err);
  }

  void assemble() {
    int err = _lis.callFunc('lis_matrix_assemble', [_p_mat]);
    _lis._CHKERR(err);
  }

  bool assembled() => _lis.callFunc('lis_matrix_is_assembled', [_p_mat]) != 0;

  Matrix<S> duplicate() {
    int pp_Aout = _lis.heapInt();
    int err = _lis.callFunc('lis_matrix_duplicate', [_p_mat, pp_Aout]);
    _lis._CHKERR(err);
    int p_Aout = _lis.derefInt(pp_Aout);
    return new Matrix._(_lis, p_Aout);
  }

  void set size(int sz) {
    int err = _lis.callFunc('lis_matrix_set_size', [_p_mat, 0, sz]);
    _lis._CHKERR(err);
  }

  int get size {
    int p_local_n = _lis.heapInt();
    int p_global_n = _lis.heapInt();
    int err =
        _lis.callFunc('lis_matrix_get_size', [_p_mat, p_local_n, p_global_n]);
    _lis._CHKERR(err);
    _lis.free(p_local_n);
    return _lis.derefInt(p_global_n);
  }

  int get nnz {
    int p_nnz = _lis.heapInt();
    int err = _lis.callFunc('lis_matrix_get_nnz', [_p_mat, p_nnz]);
    _lis._CHKERR(err);
    return _lis.derefInt(p_nnz);
  }

  void set type(MatrixType t) {
    int err = _lis.callFunc('lis_matrix_set_type', [_p_mat, t._index]);
    _lis._CHKERR(err);
  }

  MatrixType get type {
    int p_type = _lis.heapInt();
    int err = _lis.callFunc('lis_matrix_get_type', [_p_mat, p_type]);
    _lis._CHKERR(err);
    int t = _lis.derefInt(p_type);
    return MatrixType.values[t];
  }

  void setValue(int i, int j, S value) {
    int err = _lis.callFunc(
        'lis_matrix_set_value', [LIS_INS_VALUE, i, j, value, _p_mat]);
    _lis._CHKERR(err);
  }

  void setValues(List<S> values) {
    int n = size; //sqrt(values.length).toInt();
    if (values.length != n * n) {
      throw new ArgumentError.value(values);
    }
    int p_values = _lis.heapScalars(values);
    int err = _lis.callFunc(
        'lis_matrix_set_values', [LIS_INS_VALUE, n, p_values, _p_mat]);
    _lis._CHKERR(err);
    _lis.free(p_values);
  }

  /// Either [nnz_row] or [nnz] must be provided.
  void malloc({int nnz_row, Int32List nnz}) {
    int p_nnz = 0;
    if (nnz_row == null && nnz == null) {
      throw new ArgumentError("Either `nnz_row` or `nnz` must be provided");
    }
    if (nnz != null) {
      p_nnz = _lis.heapInts(nnz);
    }
    int err = _lis.callFunc('lis_matrix_malloc', [_p_mat, nnz_row, p_nnz]);
    _lis._CHKERR(err);
    if (nnz != null) {
      _lis.free(p_nnz);
    }
  }

  Vector<S> diagonal([Vector<S> d]) {
    if (d == null) {
      d = new Vector(_lis); // TODO: duplicate_vector?
      d.size = size;
    }
    int err = _lis.callFunc('lis_matrix_get_diagonal', [_p_mat, d._p_vec]);
    _lis._CHKERR(err);
    return d;
  }

  // LIS_INT lis_matrix_scale(LIS_MATRIX A, LIS_VECTOR B, LIS_VECTOR D, LIS_INT action);

  void convert(Matrix<S> Aout) {
    int err = _lis.callFunc('lis_matrix_convert', [_p_mat, Aout._p_mat]);
    _lis._CHKERR(err);
  }

  Matrix<S> copy([Matrix<S> Aout]) {
    if (Aout == null) {
      Aout = new Matrix(_lis);
      Aout.size = size;
    }
    int err = _lis.callFunc('lis_matrix_copy', [_p_mat, Aout._p_mat]);
    _lis._CHKERR(err);
    return Aout;
  }

  // LIS_INT lis_matrix_set_blocksize(LIS_MATRIX A, LIS_INT bnr, LIS_INT bnc, LIS_INT row[], LIS_INT col[]);

  void unset() {
    int err = _lis.callFunc('lis_matrix_unset', [_p_mat]);
    _lis._CHKERR(err);
  }

  Vector<S> mult(Vector<S> vx, [Vector<S> vy]) {
    if (vy == null) {
      vy = vx.duplicate();
    }
    int err = _lis.callFunc('lis_matvec', [_p_mat, vx._p_vec, vy._p_vec]);
    _lis._CHKERR(err);
    return vy;
  }

  Vector<S> operator *(Vector<S> vx) => mult(vx);

  Vector<S> multT(Vector<S> vx, [Vector<S> vy]) {
    if (vy == null) {
      vy = vx.duplicate();
    }
    int err = _lis.callFunc('lis_matvect', [_p_mat, vx._p_vec, vy._p_vec]);
    _lis._CHKERR(err);
    return vy;
  }
}

class CSR<S> {
  final int n;
  final int nnz;
  final Int32List ptr;
  final Int32List index;
  final List<S> value;

  CSR(int n_, int nnz_)
      : n = n_,
        nnz = nnz_,
        ptr = new Int32List(n_ + 1),
        index = new Int32List(nnz_),
        value = new List<S>(nnz_);

  CSR.from(this.n, this.nnz, this.ptr, this.index, this.value);
}

class CSC<S> {
  final int n;
  final int nnz;
  final Int32List ptr;
  final Int32List index;
  final List<S> value;

  CSC(int n_, int nnz_)
      : n = n_,
        nnz = nnz_,
        ptr = new Int32List(n_ + 1),
        index = new Int32List(nnz_),
        value = new List<S>(nnz_);

  CSC.from(this.n, this.nnz, this.ptr, this.index, this.value);
}

class Dia<S> {
  final int n;
  final int nnd;
  final Int32List index;
  final List<S> value;

  Dia(int n_, int nnd_)
      : n = n_,
        nnd = nnd_,
        index = new Int32List(nnd_), // TODO: n*nnd
        value = new List<S>(n_ * nnd_);

  Dia.from(this.n, this.nnd, this.index, this.value);
}

class Coo<S> {
  final int n;
  final int nnz;
  final Int32List row, col;
  final List<S> value;

  Coo(this.n, int nnz_)
      : nnz = nnz_,
        row = new Int32List(nnz_),
        col = new Int32List(nnz_),
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
