part of lis.internal;

class Vector<S> {
  final LIS _lis;

  final int _p_vec;

  factory Vector(LIS lis, [int size]) {
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

  factory Vector.fromMatrix(LIS lis, Matrix<S> A) {
    int pp_vout = lis.heapInt();
    var err = lis.callFunc('lis_vector_duplicate', [A._p_mat, pp_vout]);
    lis._CHKERR(err);
    var p_vout = lis.derefInt(pp_vout);
    return new Vector._(lis, p_vout);
  }

  factory Vector.input(LIS lis, String data) {
    var v = new Vector(lis);
    int p_path = lis._writeFile(data);
    int err = lis.callFunc('lis_input_vector', [v._p_vec, p_path]);
    lis._CHKERR(err);
    lis._removeFile(p_path);
    return v;
  }

  String output([Format fmt = Format.PLAIN]) {
    int p_path = _lis._heapPath();
    int err = _lis.callFunc('lis_output_vector', [_p_vec, fmt.index, p_path]);
    _lis._CHKERR(err);
    return _lis._readFile(p_path);
  }

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
    _lis._CHKERR(err);
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
    _lis._CHKERR(err);
  }

  List<S> values([int start = 0, int count]) {
    if (count == null) {
      count = size;
    }
    var vals = new List.generate(count, (_) => _lis.scalarZero());
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
  void axpy(Vector<S> vx, [S alpha]) {
    if (alpha == null) {
      alpha = _lis.scalarOne();
    }
    int err = _lis.callFunc('lis_vector_axpy', [alpha, vx._p_vec, _p_vec]);
    _lis._CHKERR(err);
  }

  /// Calculate the sum of the vectors `y = x + ay`.
  void xpay(Vector<S> vx, [S alpha]) {
    if (alpha == null) {
      alpha = _lis.scalarOne();
    }
    int err = _lis.callFunc('lis_vector_xpay', [vx._p_vec, alpha, _p_vec]);
    _lis._CHKERR(err);
  }

  /// Calculate the sum of the vectors `z = ax + y`.
  Vector<S> axpyz(Vector<S> vx, [S alpha, Vector<S> vz]) {
    if (alpha == null) {
      alpha = _lis.scalarOne();
    }
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
