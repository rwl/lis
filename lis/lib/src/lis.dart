library lis.wrap;

import 'dart:typed_data';
import 'dart:js' as js;

int _COMM_WORLD = 1;

class LIS {
  final js.JsObject _module;

  LIS() : _module = js.context['LIS'] {
    int argc = heapInt(0);
    int argv = 0;
    int err = _module.callMethod('_lis_initialize', [argc, argv]);
    _CHKERR(err);
  }

  js.JsObject get module => _module;

//  int _malloc(TypedData data) {
//    var ptr = _module.callMethod('_malloc', [data.lengthInBytes]);
//    _module.callMethod('setTypedData', [data, ptr]);
//    return ptr;
//  }

  _free(int ptr) => _module.callMethod('_free', [ptr]);

  int heapInt(int value) {
    var p_int = _module.callMethod('_malloc', [Int32List.BYTES_PER_ELEMENT]);
    _module.callMethod('setValue', [p_int, value, 'i32']);
    return p_int;
  }

  int derefInt(int ptr) => _module.callMethod('getValue', [ptr, 'i32']);

  finalize() => _module.callMethod('_lis_finalize');

//  Vector vector_create(int n) => new Vector._(this, n);
//
//  Matrix matrix_create() => new Matrix._(this, null, null);

  input(A, b, x, String name) => null;

  void _CHKERR(int err) {
    if (err != 0) {
      finalize();
      throw err; // TODO: LisError
    }
  }
}

class Vector<S> {
  final LIS _lis;

  int _p_vec;

  factory Vector(LIS lis) {
    int pp_vec = lis.heapInt(0);
    lis.module.callMethod('_lis_vector_create', [_COMM_WORLD, pp_vec]);
    var p_vec = lis.module.callMethod('getValue', [pp_vec, 'i32']);
    lis._free(pp_vec);
    return new Vector._(lis, p_vec);
  }

  Vector._(this._lis, this._p_vec);

  destroy() {
    int err = _lis.module.callMethod('_lis_vector_destroy', [_p_vec]);
    _lis._CHKERR(err);
  }

  void set size(int sz) {
    int err = _lis.module.callMethod('_lis_vector_set_size', [_p_vec, 0, sz]);
    _lis._CHKERR(err);
  }

  int get size {
    int p_local_n = _lis.heapInt(0);
    int p_global_n = _lis.heapInt(0);
    int err = _lis.module
        .callMethod('_lis_vector_get_size', [_p_vec, p_local_n, p_global_n]);
    int sz = _lis.derefInt(p_global_n);
    _lis._free(p_local_n);
    _lis._free(p_global_n);
    return sz;
  }

  Vector<S> duplicate() {
    int pp_vout = _lis.heapInt(0);
	   var err = _lis.module.callMethod('_lis_vector_duplicate', [_p_vec, pp_vout]);
     _lis._CHKERR(err);
     var p_vout = _lis.module.callMethod('getValue', [pp_vout, 'i32']);
     _lis._free(pp_vout);
     return new Vector._(_lis, p_vout);
  }

  S operator [](int i) {
    int p_value = _lis.heapScalar(0.0);
    int err = _lis.module.callMethod('_lis_vector_get_value', [_p_vec, i, p_value]);
    _lis._CHKERR(err);
    var value = _lis.derefScalar(p_value);
    _lis._free(p_value);
    return value;
  }

  List<S> values(int start, int count) {
    _lis.module.callMethod('_lis_vector_get_values', [_p_vec, start, count, p_value]);
  }

  void operator []=(int i, S value) {
    int err = _lis.module.callMethod('_lis_vector_set_value', [LIS_INS_VALUE, i, value, LIS_VECTOR v);
  }

  void setValues(List<int> index, List<S> value) {
    int count = index.length;
    int err = _lis.module.callMethod('_lis_vector_set_values', [LIS_INS_VALUE, count, p_index, p_value, _p_vec]);
    _lis._CHKERR(err);
  }

  void setAll(int start, Iterable<S> value) {
    int count = value.length;
    int err = _lis.module.callMethod('_lis_vector_set_values2', [LIS_INS_VALUE, start, count, p_value, _p_vec]);
    _lis._CHKERR(err);
  }

  void print() {
    int err = _lis.module.callMethod('_lis_vector_print', [_p_vec]);
    _lis._CHKERR(err);
  }

  bool isNull() => _lis.module.callMethod('_lis_vector_is_null', [_p_vec]) != 0;

  void swap(Vector<S> vdst) {
    int err = _lis.module.callMethod('_lis_vector_swap', [_p_vec, vdst._p_vec]);
    _lis._CHKERR(err);
  }

  void copy(Vector<S> vdst) {
    int err = _lis.module.callMethod('_lis_vector_copy', [_p_vec, vdst._p_vec]);
    _lis._CHKERR(err);
  }

  /// Calculate the sum of the vectors `y = ax + y`.
  void axpy(Vector<S> vx, [S alpha = 1.0]) {
    int err = _lis.module.callMethod('_lis_vector_axpy', [alpha, vx._p_vec, _p_vec]);
    _lis._CHKERR(err);
  }

  /// Calculate the sum of the vectors `y = x + ay`.
  void xpay(Vector<S> vx, [S alpha = 0.0]) {
    int err = _lis.module.callMethod('_lis_vector_xpay', [vx._p_vec, alpha, _p_vec]);
    _lis._CHKERR(err);
  }

  /// Calculate the sum of the vectors `z = ax + y`.
  Vector<S> axpyz(Vector<S> vx, [S alpha = 0.0]) {
    var vz = new Vector(_lis);
    int err = _lis.module.callMethod('_lis_vector_axpyz', [alpha, vx._p_vec, _p_vec, vz._p_vec]);
    _lis._CHKERR(err);
    return vz;
  }

  /// Multiply vector x by scalar a.
  void scale(S alpha) {
    int err = _lis.module.callMethod('_lis_vector_scale', [alpha, _p_vec]);
    _lis._CHKERR(err);
  }

  /// Multiply each element of vector x by the corresponding element of y.
  void pmul(Vector<S> vx) {
    int err = _lis.module.callMethod('_lis_vector_pmul', [vx._p_vec, _p_vec, _p_vec]);
    _lis._CHKERR(err);
  }

  /// Divide each element of vector x by the corresponding element of y.
  void pdiv(Vector<S> vx) {
    int err = _lis.module.callMethod('_lis_vector_pdiv', [vx._p_vec, _p_vec, _p_vec]);
    _lis._CHKERR(err);
  }

  /// Assign the scalar value to the elements of vector x.
  void fill(S alpha) {
//    int p_alpha = _lis.heapScalar(alpha);
    int err = _lis.module.callMethod('_lis_vector_set_all', [alpha, _p_vec]);
    _lis._CHKERR(err);
  }

  /// Get the absolute values of the elements of vector x.
  void abs() {
    int err = _lis.module.callMethod('_lis_vector_abs', [_p_vec]);
    _lis._CHKERR(err);
  }

  /// Get the reciprocal values of the elements of vector x.
  void reciprocal() {
    int err = _lis.module.callMethod('_lis_vector_reciprocal', [_p_vec]);
    _lis._CHKERR(err);
  }

  void shift(S alpha) {
    int err = _lis.module.callMethod('_lis_vector_shift', [alpha, _p_vec]);
    _lis._CHKERR(err);
  }

  double dot(Vector<S> vx) {
    int p_value = _lis.heapDouble(0.0);
    int err = _lis.module.callMethod('_lis_vector_dot', [vx._p_vec, _p_vec, p_value]);
    _lis._CHKERR(err);
    var value = _lis.derefDouble(p_value);
    _lis._free(p_value);
    return value;
  }

  double nrm1(Vector<S> vx) {
    int p_value = _lis.heapDouble(0.0);
    int err = _lis.module.callMethod('_lis_vector_nrm1', [vx._p_vec, _p_vec, p_value]);
    _lis._CHKERR(err);
    var value = _lis.derefDouble(p_value);
    _lis._free(p_value);
    return value;
  }

  double nrm2(Vector<S> vx) {
    int p_value = _lis.heapDouble(0.0);
    int err = _lis.module.callMethod('_lis_vector_nrm2', [vx._p_vec, _p_vec, p_value]);
    _lis._CHKERR(err);
    var value = _lis.derefDouble(p_value);
    _lis._free(p_value);
    return value;
  }

  double nrmi(Vector<S> vx) {
    int p_value = _lis.heapDouble(0.0);
    int err = _lis.module.callMethod('_lis_vector_nrmi', [vx._p_vec, _p_vec, p_value]);
    _lis._CHKERR(err);
    var value = _lis.derefDouble(p_value);
    _lis._free(p_value);
    return value;
  }

  S sum(Vector<S> vx) {
    int p_value = _lis.heapScalar(0.0);
    int err = _lis.module.callMethod('_lis_vector_sum', [vx._p_vec, _p_vec, p_value]);
    _lis._CHKERR(err);
    var value = _lis.derefScalar(p_value);
    _lis._free(p_value);
    return value;
  }
}

class Matrix<S> {
  final LIS _lis;
  int _p_mat;
  Matrix(this._lis);

  Matrix._(this._lis) {
    int pp_mat = _lis.heapInt(0);
    _lis.module.callMethod('_lis_vector_create', [_COMM_WORLD, pp_mat]);
    _p_mat = _lis.module.callMethod('getValue', [pp_mat, 'i32']);
    _lis._free(pp_mat);
  }
}

class Solver<S> {
  final LIS _lis;
  Solver(this._lis) {
    int pp_solver = _lis.heapInt(0);
  }
}
