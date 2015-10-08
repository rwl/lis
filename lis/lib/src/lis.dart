library lis.wrap;

import 'dart:math';
import 'dart:typed_data';
import 'dart:js' as js;
import 'package:emscripten/emscripten.dart';

const int LIS_INS_VALUE = 0;

const int COMM_WORLD = 0x1;

abstract class _LIS<S> extends Module {
  _LIS(
      {String moduleName: 'Module',
      js.JsObject context,
      List<String> options: const []})
      : super(moduleName: moduleName, context: context) {
    int argc = heapInt(options.length + 1);
    options = ['lis']..addAll(options);
    int p_args = heapStrings(options);
    int argv = heapInt(p_args);
    int err = callFunc('lis_initialize', [argc, argv]);
    _CHKERR(err);
  }

  int heapScalars(List<S> list);

  List<S> derefScalars(int ptr, int n, [bool free = true]);

  int heapScalar([S value]);

  S derefScalar(int ptr, [bool free = true]);

  finalize() => callFunc('lis_finalize');

  input(A, b, x, String name) => null;

  void _CHKERR(int err) {
    if (err != 0) {
      finalize();
      throw err; // TODO: LisError
    }
  }
}

class LIS extends _LIS {
  LIS([List<String> options = const []]);

  int heapScalars(List list) => heapDoubles(list);

  List derefScalars(int ptr, int n, [bool free = true]) =>
      derefDoubles(ptr, n, free);

  heapScalar([val]) => heapDouble(val);

  derefScalar(int ptr, [bool free = true]) => derefDouble(ptr, free);
}

class Vector<S> {
  final _LIS _lis;

  final int _p_vec;

  factory Vector(_LIS lis, [int size]) {
    int pp_vec = lis.heapInt();
    int err = lis.callFunc('lis_vector_create', [COMM_WORLD, pp_vec]);
    lis._CHKERR(err);
    var p_vec = lis.derefInt(pp_vec);
    var v = new Vector._(lis, p_vec);
    if (size != null) {
      v.size = size;
    }
    return v;
  }

  Vector._(this._lis, this._p_vec);

  void destroy() {
    int err = _lis.callFunc('lis_vector_destroy', [_p_vec]);
    _lis._CHKERR(err);
  }

  void set size(int sz) {
    int err = _lis.callFunc('lis_vector_set_size', [_p_vec, 0, sz]);
    _lis._CHKERR(err);
  }

  int get size {
    int p_local_n = _lis.heapInt();
    int p_global_n = _lis.heapInt();
    int err =
        _lis.callFunc('lis_vector_get_size', [_p_vec, p_local_n, p_global_n]);
    _lis.free(p_local_n);
    return _lis.derefInt(p_global_n);
  }

  Vector<S> duplicate() {
    int pp_vout = _lis.heapInt();
    var err = _lis.callFunc('lis_vector_duplicate', [_p_vec, pp_vout]);
    _lis._CHKERR(err);
    var p_vout = _lis.derefInt(pp_vout);
    return new Vector._(_lis, p_vout);
  }

  S operator [](int i) {
    int p_value = _lis.heapScalar();
    int err = _lis.callFunc('lis_vector_get_value', [_p_vec, i, p_value]);
    _lis._CHKERR(err);
    return _lis.derefScalar(p_value);
  }

  void operator []=(int i, S value) {
    int err = _lis.callFunc(
        'lis_vector_set_value', [LIS_INS_VALUE, i, value, _p_vec]);
  }

  List<S> values([int start = 0, int count]) {
    if (count == null) {
      count = size;
    }
    var vals = new Float64List(count);
    int p_value = _lis.heapScalars(vals);
    int err =
        _lis.callFunc('lis_vector_get_values', [_p_vec, start, count, p_value]);
    _lis._CHKERR(err);
    return _lis.derefScalars(p_value, count);
  }

  void setValues(Int32List index, List<S> value) {
    int count = index.length;
    int p_index = _lis.heapInts(index);
    int p_value = _lis.heapScalars(value);
    int err = _lis.callFunc('lis_vector_set_values',
        [LIS_INS_VALUE, count, p_index, p_value, _p_vec]);
    _lis._CHKERR(err);
    _lis.free(p_index);
    _lis.free(p_value);
  }

  void setAll(int start, Iterable<S> value) {
    int count = value.length;
    int p_value = _lis.heapScalars(value);
    int err = _lis.callFunc('lis_vector_set_values2',
        [LIS_INS_VALUE, start, count, p_value, _p_vec]);
    _lis._CHKERR(err);
    _lis.free(p_value);
  }

  void print() {
    int err = _lis.callFunc('lis_vector_print', [_p_vec]);
    _lis._CHKERR(err);
  }

  bool isNull() => _lis.callFunc('lis_vector_is_null', [_p_vec]) != 0;

  void swap(Vector<S> vdst) {
    int err = _lis.callFunc('lis_vector_swap', [_p_vec, vdst._p_vec]);
    _lis._CHKERR(err);
  }

  Vector<S> copy([Vector<S> vdst]) {
    if (vdst == null) {
      vdst = duplicate();
    }
    int err = _lis.callFunc('lis_vector_copy', [_p_vec, vdst._p_vec]);
    _lis._CHKERR(err);
    return vdst;
  }

  /// Calculate the sum of the vectors `y = ax + y`.
  void axpy(Vector<S> vx, [S alpha = 1.0]) {
    int err = _lis.callFunc('lis_vector_axpy', [alpha, vx._p_vec, _p_vec]);
    _lis._CHKERR(err);
  }

  /// Calculate the sum of the vectors `y = x + ay`.
  void xpay(Vector<S> vx, [S alpha = 1.0]) {
    int err = _lis.callFunc('lis_vector_xpay', [vx._p_vec, alpha, _p_vec]);
    _lis._CHKERR(err);
  }

  /// Calculate the sum of the vectors `z = ax + y`.
  Vector<S> axpyz(Vector<S> vx, [S alpha = 1.0, Vector<S> vz]) {
    if (vz == null) {
      vz = duplicate();
    }
    int err = _lis.callFunc(
        'lis_vector_axpyz', [alpha, vx._p_vec, _p_vec, vz._p_vec]);
    _lis._CHKERR(err);
    return vz;
  }

  /// Multiply vector x by scalar a.
  void scale(S alpha) {
    int err = _lis.callFunc('lis_vector_scale', [alpha, _p_vec]);
    _lis._CHKERR(err);
  }

  /// Multiply each element of vector x by the corresponding element of y.
  void pmul(Vector<S> vx) {
    int err = _lis.callFunc('lis_vector_pmul', [vx._p_vec, _p_vec, _p_vec]);
    _lis._CHKERR(err);
  }

  /// Divide each element of vector x by the corresponding element of y.
  void pdiv(Vector<S> vx) {
    int err = _lis.callFunc('lis_vector_pdiv', [vx._p_vec, _p_vec, _p_vec]);
    _lis._CHKERR(err);
  }

  /// Assign the scalar value to the elements of vector x.
  void fill(S alpha) {
//    int p_alpha = _lis.heapScalar(alpha);
    int err = _lis.callFunc('lis_vector_set_all', [alpha, _p_vec]);
    _lis._CHKERR(err);
  }

  /// Get the absolute values of the elements of vector x.
  void abs() {
    int err = _lis.callFunc('lis_vector_abs', [_p_vec]);
    _lis._CHKERR(err);
  }

  /// Get the reciprocal values of the elements of vector x.
  void reciprocal() {
    int err = _lis.callFunc('lis_vector_reciprocal', [_p_vec]);
    _lis._CHKERR(err);
  }

  void shift(S alpha) {
    int err = _lis.callFunc('lis_vector_shift', [alpha, _p_vec]);
    _lis._CHKERR(err);
  }

  double dot(Vector<S> vx) {
    int p_value = _lis.heapDouble();
    int err = _lis.callFunc('lis_vector_dot', [vx._p_vec, _p_vec, p_value]);
    _lis._CHKERR(err);
    return _lis.derefDouble(p_value);
  }

  double nrm1() {
    int p_value = _lis.heapDouble();
    int err = _lis.callFunc('lis_vector_nrm1', [_p_vec, p_value]);
    _lis._CHKERR(err);
    return _lis.derefDouble(p_value);
  }

  double nrm2() {
    int p_value = _lis.heapDouble();
    int err = _lis.callFunc('lis_vector_nrm2', [_p_vec, p_value]);
    _lis._CHKERR(err);
    return _lis.derefDouble(p_value);
  }

  double nrmi() {
    int p_value = _lis.heapDouble();
    int err = _lis.callFunc('lis_vector_nrmi', [_p_vec, p_value]);
    _lis._CHKERR(err);
    return _lis.derefDouble(p_value);
  }

  S sum() {
    int p_value = _lis.heapScalar();
    int err = _lis.callFunc('lis_vector_sum', [_p_vec, p_value]);
    _lis._CHKERR(err);
    return _lis.derefScalar(p_value);
  }
}

class Matrix<S> {
  final _LIS _lis;
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
    var p_value = lis.heapDoubles(csr.value);
    var m = new Matrix(lis);
    m.size = csr.n;
    int err = lis.callFunc(
        'lis_matrix_set_csr', [csr.nnz, p_ptr, p_index, p_value, m._p_mat]);
    lis._CHKERR(err);
    m.assemble();
    return m;
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
    return Aout;
  }

  // LIS_INT lis_matrix_set_blocksize(LIS_MATRIX A, LIS_INT bnr, LIS_INT bnc, LIS_INT row[], LIS_INT col[]);
  // LIS_INT lis_matrix_unset(LIS_MATRIX A);
}

class CSR<S> {
  final int n;
  final int nnz;
  final Int32List ptr;
  final Int32List index;
  final List<S> value;
  factory CSR(_LIS lis, int n, nnz) {
    int p_ptr = lis.heapInt();
    int p_index = lis.heapInt();
    int p_value = lis.heapInt();
    int err = lis.callFunc(
        'lis_matrix_malloc_csr', [n, nnz, p_ptr, p_index, p_value]);
    lis._CHKERR(err);
    var ptr = lis.derefInts(p_ptr, n + 1);
    var index = lis.derefInts(p_index, nnz);
    var value = lis.derefDoubles(p_value, nnz);
    return new CSR.from(n, nnz, ptr, index, value);
  }
  CSR.from(this.n, this.nnz, this.ptr, this.index, this.value);
}

class MatrixType {
  static const ASSEMBLING = const MatrixType._('ASSEMBLING', 0);

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
    ASSEMBLING,
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

class Solver<S> {
  final _LIS _lis;
  Solver(this._lis) {
    int pp_solver = _lis.heapInt();
  }
}
