part of lis.internal;

class Matrix<S> {
  final LIS<S> _lis;
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

  factory Matrix.compose(
      LIS lis, Matrix<S> A, Matrix<S> B, Matrix<S> C, Matrix<S> D) {
    var Y = new Matrix(lis);
    lis.matrixCompose(A._p_mat, B._p_mat, C._p_mat, D._p_mat, Y._p_mat);
    return Y;
  }

  factory Matrix.csr(LIS lis, int n, int nnz, Iterable<int> ptr,
      Iterable<int> index, Iterable<S> value) {
    if (ptr.length != n + 1) {
      throw new ArgumentError('ptr.length != n + 1');
    }
    if (index.length != nnz) {
      throw new ArgumentError('index.length != nnz');
    }
    if (value.length != nnz) {
      throw new ArgumentError('value.length != nnz');
    }
    Vector<S> v = value is Vector ? value : new Vector<S>.from(lis, value);

    var m = new Matrix(lis, n);
    lis.matrixSetCsr(nnz, ptr.toList(growable: true),
        index.toList(growable: true), v._p_vec, m._p_mat);
    m.assemble();
    return m;
  }

  factory Matrix.csc(LIS lis, int n, int nnz, Iterable<int> ptr,
      Iterable<int> index, Iterable<S> value) {
    if (ptr.length != n + 1) {
      throw new ArgumentError('ptr.length != n + 1');
    }
    if (index.length != nnz) {
      throw new ArgumentError('index.length != nnz');
    }
    if (value.length != nnz) {
      throw new ArgumentError('value.length != nnz');
    }
    Vector<S> v = value is Vector ? value : new Vector<S>.from(lis, value);

    var m = new Matrix(lis, n);
    lis.matrixSetCsc(nnz, ptr.toList(growable: false),
        index.toList(growable: false), v._p_vec, m._p_mat);
    m.assemble();
    return m;
  }

  factory Matrix.dia(
      LIS lis, int n, int nnd, Iterable<int> index, Iterable<S> value) {
    if (index.length != nnd) {
      throw new ArgumentError('index.length != nnd');
    }
    if (value.length != n * nnd) {
      throw new ArgumentError('value.length != n*nnd');
    }
    Vector<S> v = value is Vector ? value : new Vector<S>.from(lis, value);

    var m = new Matrix(lis, n);
    lis.matrixSetDia(nnd, index.toList(growable: false), v._p_vec, m._p_mat);
    m.assemble();
    return m;
  }

  factory Matrix.coo(LIS lis, int n, int nnz, Iterable<int> row,
      Iterable<int> col, Iterable<S> value) {
    if (row.length != nnz) {
      throw new ArgumentError('row.length != nnz');
    }
    if (col.length != nnz) {
      throw new ArgumentError('col.length != nnz');
    }
    if (value.length != nnz) {
      throw new ArgumentError('value.length != nnz');
    }
    Vector<S> v = value is Vector ? value : new Vector<S>.from(lis, value);

    var m = new Matrix(lis, n);
    lis.matrixSetCoo(nnz, row.toList(growable: false),
        col.toList(growable: false), v._p_vec, m._p_mat);
    m.assemble();
    return m;
  }

  factory Matrix.dense(LIS lis, int n, Iterable<S> value, [int np]) {
    if (np == null) {
      np = n;
    }
    if (value.length != n * np) {
      throw new ArgumentError('value.length != n * np');
    }
    Vector<S> v = value is Vector ? value : new Vector<S>.from(lis, value);

    var m = new Matrix(lis, n);
    lis.matrixSetDns(v._p_vec, m._p_mat);
    m.assemble();
    return m;
  }

  factory Matrix.convert(LIS lis, Matrix<S> Ain, MatrixType matrixType) {
    var Aout = new Matrix<S>(lis, Ain.size, matrixType);
    lis.matrixConvert(Ain._p_mat, Aout._p_mat);
    return Aout;
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

  void setValues(Iterable<S> values, [Flag flag = Flag.INSERT]) {
    int n = size; //sqrt(values.length).toInt();
    if (values.length != n * n) {
      throw new ArgumentError.value(values);
    }
    _lis.matrixSetValues(flag.index, n, values.toList(growable: false), _p_mat);
  }

  /// Either [nnz_row] or [nnz] must be provided.
  void malloc({int nnz_row, Iterable<int> nnz}) {
    if (nnz_row == null && nnz == null) {
      throw new ArgumentError("Either `nnz_row` or `nnz` must be provided");
    } else if (nnz_row == null) {
      nnz_row = 0;
      nnz = nnz.toList(growable: false);
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

  Matrix<S> copy([Matrix<S> Aout]) {
    if (Aout == null) {
      Aout = duplicate();
    }
    _lis.matrixCopy(_p_mat, Aout._p_mat);
    return Aout;
  }

  Vector<S> matvec(Vector<S> vx, [Vector<S> vy]) {
    if (vy == null) {
      vy = vx.duplicate();
    }
    _lis.matvec(_p_mat, vx._p_vec, vy._p_vec);
    return vy;
  }

  Vector<S> matvect(Vector<S> vx, [Vector<S> vy]) {
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

  void sumDuplicates() => _lis.matrixSumDuplicates(_p_mat);

  void sortIndexes() => _lis.matrixSortIndexes(_p_mat);

  Matrix<S> real() {
    var re = copy();
    _lis.matrixReal(re._p_mat);
    return re;
  }

  Matrix<S> imag() {
    var im = copy();
    _lis.matrixImaginary(im._p_mat);
    return im;
  }

  Matrix<S> conj() {
    var c = copy();
    _lis.matrixConjugate(c._p_mat);
    return c;
  }

  void scale(S alpha) => _lis.matrixScaleValues(_p_mat, alpha);

  Matrix<S> add(Matrix<S> B, [Matrix<S> C]) {
    if (C == null) {
      C = duplicate();
    }
    _lis.matrixAdd(_p_mat, B._p_mat, C._p_mat);
    return C;
  }

  Matrix<S> matmat(Matrix<S> B, [Matrix<S> C]) {
    if (C == null) {
      C = duplicate();
    }
    _lis.matmat(_p_mat, B._p_mat, C._p_mat);
    return C;
  }

  operator *(x) {
    if (x is Vector) {
      return matvec(x);
    } else if (x is Matrix) {
      return matmat(x);
    } else if (_lis.zero is Complex) {
      if (x is num) {
        x = new Complex(x);
      }
      if (x is Complex) {
        return copy()..scale(x as S);
      } else {
        throw new ArgumentError('expected Vector, Matrix or S type');
      }
    } else if (x is num) {
      return copy()..scale(x.toDouble() as S);
    } else {
      throw new ArgumentError('expected Vector, Matrix or S type');
    }
  }

  Matrix<S> operator +(Matrix<S> B) => add(B);

  Matrix<S> operator -(Matrix<S> B) {
    var Bneg = B.copy()..scale(-(_lis.one as dynamic));
    return add(Bneg);
  }

  Matrix<S> get T {
    var A = copy();
    _lis.matrixConjugate(A._p_mat);
    transpose(A);
    return A;
  }

  Matrix<S> get H => copy()
    ..conj()
    ..transpose();

  Matrix<S> toCsr([bool sortIndexes = true, bool sumDuplicates = true]) {
    var csr = new Matrix<S>.convert(_lis, this, MatrixType.CSR);
    if (sortIndexes) {
      csr.sortIndexes();
    }
    if (sumDuplicates) {
      csr.sumDuplicates();
    }
    return csr;
  }

  Matrix<S> toCsc() => new Matrix<S>.convert(_lis, this, MatrixType.CSC);

  Matrix<S> toMsr() => new Matrix<S>.convert(_lis, this, MatrixType.MSR);

  Matrix<S> toDia() => new Matrix<S>.convert(_lis, this, MatrixType.DIA);

  Matrix<S> toEll() => new Matrix<S>.convert(_lis, this, MatrixType.ELL);

  Matrix<S> toJad() => new Matrix<S>.convert(_lis, this, MatrixType.JAD);

  Matrix<S> toBsr() => new Matrix<S>.convert(_lis, this, MatrixType.BSR);

  Matrix<S> toBsc() => new Matrix<S>.convert(_lis, this, MatrixType.BSC);

  Matrix<S> toVbr() => new Matrix<S>.convert(_lis, this, MatrixType.VBR);

  Matrix<S> toCoo() => new Matrix<S>.convert(_lis, this, MatrixType.COO);

  Matrix<S> toDense() => new Matrix<S>.convert(_lis, this, MatrixType.DENSE);
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
