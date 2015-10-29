part of lis.internal;

class Vector<S> {
  final LIS<S> _lis;
  final int _p_vec;

  factory Vector(LIS lis, [int size]) {
    var p_vec = lis.vectorCreate();
    var v = new Vector._(lis, p_vec);
    if (size != null) {
      v.size = size;
    }
    return v;
  }

  Vector._(this._lis, this._p_vec);

  factory Vector.fromMatrix(LIS lis, Matrix<S> A) {
    var p_vout = lis.vectorDuplicate(A._p_mat);
    return new Vector._(lis, p_vout);
  }

  factory Vector.input(LIS lis, String data) {
    var v = new Vector(lis);
    lis.inputVector(v._p_vec, data);
    return v;
  }

  factory Vector.from(LIS lis, List<S> vals) {
    return new Vector<S>(lis, vals.length)..setAll(0, vals);
  }

  static Vector<Complex> createReal(LIS<Complex> lis, List<double> re) {
    var n = re.length;
    var l = new List.generate(n, (i) => new Complex(re[i]));
    return new Vector(lis, n)..setAll(0, l);
  }

  static Vector<Complex> createImag(LIS<Complex> lis, List<double> im) {
    var n = im.length;
    var l = new List.generate(n, (i) => new Complex(0.0, im[i]));
    return new Vector(lis, n)..setAll(0, l);
  }

  static Vector<Complex> createParts(
      LIS<Complex> lis, List<double> re, List<double> im) {
    if (re.length != im.length) {
      throw new ArgumentError('re.length != im.length');
    }
    var n = re.length;
    var l = new List<Complex>.generate(n, (i) => new Complex(re[i], im[i]));
    return new Vector(lis, n)..setAll(0, l);
  }

  static Vector<Complex> createPolar(
      LIS<Complex> lis, List<double> r, List<double> theta,
      [bool radians = true]) {
    if (r.length != theta.length) {
      throw new ArgumentError('r.length != theta.length');
    }
    var n = r.length;
    var vals = new List<Complex>(n);
    enumerate(theta).forEach((iv) {
      double th = radians ? iv.value : iv.value * (PI / 180.0);
      vals[iv.index] = new Complex.polar(r[iv.index], th);
    });
    return new Vector<Complex>(lis, n)..setAll(0, vals);
  }

  String output([Format fmt = Format.PLAIN]) {
    return _lis.outputVector(_p_vec, fmt.index);
  }

  void destroy() => _lis.vectorDestroy(_p_vec);

  void set size(int sz) => _lis.vectorSetSize(_p_vec, sz);

  int get size => _lis.vectorGetSize(_p_vec);

  Vector<S> duplicate() {
    var p_vout = _lis.vectorDuplicate(_p_vec);
    return new Vector._(_lis, p_vout);
  }

  S operator [](int i) => _lis.vectorGetValue(_p_vec, i);

  void operator []=(int i, S value) => setValue(i, value);

  void setValue(int i, S value, [Flag flag = Flag.INSERT]) {
    _lis.vectorSetValue(flag.index, i, value, _p_vec);
  }

  List<S> values([int start = 0, int count]) {
    if (count == null) {
      count = size;
    }
    return _lis.vectorGetValues(_p_vec, start, count);
  }

  void setValues(List<int> index, List<S> value, [Flag flag = Flag.INSERT]) {
    int count = index.length;
    _lis.vectorSetValues(flag.index, count, index, value, _p_vec);
  }

  void setAll(int start, Iterable<S> value) {
    int count = value.length;
    _lis.vectorSetValues2(Flag.INSERT.index, start, count, value, _p_vec);
  }

  void print() => _lis.vectorPrint(_p_vec);

  bool isNull() => _lis.vectorIsNull(_p_vec) != 0;

  void swap(Vector<S> vdst) => _lis.vectorSwap(_p_vec, vdst._p_vec);

  Vector<S> copy([Vector<S> vdst]) {
    if (vdst == null) {
      vdst = duplicate();
    }
    _lis.vectorCopy(_p_vec, vdst._p_vec);
    return vdst;
  }

  /// Calculate the sum of the vectors `y = ax + y`.
  void axpy(Vector<S> vx, [S alpha]) {
    _lis.vectorAxpy(alpha, vx._p_vec, _p_vec);
  }

  /// Calculate the sum of the vectors `y = x + ay`.
  void xpay(Vector<S> vx, [S alpha]) {
    _lis.vectorXpay(vx._p_vec, alpha, _p_vec);
  }

  /// Calculate the sum of the vectors `z = ax + y`.
  Vector<S> axpyz(Vector<S> vx, [S alpha, Vector<S> vz]) {
    if (alpha == null) {
      alpha = _lis.one;
    }
    if (vz == null) {
      vz = duplicate();
    }
    _lis.vectorAxpyz(alpha, vx._p_vec, _p_vec, vz._p_vec);
    return vz;
  }

  /// Multiply vector x by scalar a.
  void scale(S alpha) => _lis.vectorScale(alpha, _p_vec);

  /// Multiply each element of vector x by the corresponding element of y.
  void pmul(Vector<S> vy) => _lis.vectorPmul(_p_vec, vy._p_vec, _p_vec);

  /// Divide each element of vector x by the corresponding element of y.
  void pdiv(Vector<S> vy) => _lis.vectorPdiv(_p_vec, vy._p_vec, _p_vec);

  /// Assign the scalar value to the elements of vector x.
  void fill(S alpha) => _lis.vectorSetAll(alpha, _p_vec);

  /// Get the absolute values of the elements of vector x.
  void abs() => _lis.vectorAbs(_p_vec);

  /// Get the reciprocal values of the elements of vector x.
  void reciprocal() => _lis.vectorReciprocal(_p_vec);

  void shift(S alpha) => _lis.vectorShift(alpha, _p_vec);

  S dot(Vector<S> vx) => _lis.vectorDot(vx._p_vec, _p_vec);

  double nrm1() => _lis.vectorNrm1(_p_vec);

  double nrm2() => _lis.vectorNrm2(_p_vec);

  double nrmi() => _lis.vectorNrmi(_p_vec);

  S sum() => _lis.vectorSum(_p_vec);

  void real() => _lis.vectorReal(_p_vec);

  void imag() => _lis.vectorImaginary(_p_vec);

  void arg() => _lis.vectorArgument(_p_vec);

  void conj() => _lis.vectorConjugate(_p_vec);

  Vector<S> operator *(y) {
    if (y is Vector) {
      return copy()..pmul(y);
    } else if (y is Complex) {
      return copy()..scale(y as S);
    } else if (y is num) {
      return copy()..scale(y.toDouble() as S);
    } else {
      throw new ArgumentError('expected Vector or S type');
    }
  }

  Vector<S> operator /(y) {
    if (y is Vector) {
      return copy()..pdiv(y);
    } else if (y is Complex) {
      return copy()..scale(y.reciprocal() as S);
    } else if (y is num) {
      return copy()..scale(1 / y as S);
    } else {
      throw new ArgumentError('expected Vector or S type');
    }
  }

  Vector<S> operator +(y) {
    if (y is Vector) {
      return axpyz(y);
    } else if (y is Complex) {
      return copy()..shift(y as S);
    } else if (y is num) {
      return copy()..shift(y.toDouble() as S);
    } else {
      throw new ArgumentError('expected Vector or S type');
    }
  }

  Vector<S> operator -(y) {
    if (y is Vector) {
      return axpyz(y, -(_lis.one as dynamic));
    } else if (y is Complex) {
      return copy()..shift(-y as S);
    } else if (y is num) {
      return copy()..shift(-y as S);
    } else {
      throw new ArgumentError('expected Vector or S type');
    }
  }

  Vector<S> operator -() => copy()..scale(-(_lis.one as dynamic));
}
