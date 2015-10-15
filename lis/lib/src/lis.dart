library lis.internal;

import 'dart:typed_data';
import 'dart:js' show JsObject;

import 'package:complex/complex.dart';
import 'package:emscripten/emscripten.dart';
import 'package:emscripten/experimental.dart';

part 'vector.dart';
part 'matrix.dart';
part 'solver.dart';
part 'esolver.dart';

enum Flag { INSERT, ADD }

const int COMM_WORLD = 0x1;

abstract class LIS<S> extends Module {
  final FS _fs;

  LIS(String funcName, List<String> options, JsObject context)
      : super.func(funcName, context),
        _fs = new FS(context: context) {
    if (options == null) {
      options = [];
    }
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

  S scalarOne();
  S scalarZero();

  finalize() => callFunc('lis_finalize');

  int _writeFile(String data) {
    var path = _pathname();
    _fs.writeFile(path, data);
    return heapString(path);
  }

  void _removeFile(int p_path) {
    _fs.unlink(stringify(p_path));
  }

  int _heapPath() {
    var path = _pathname();
    return heapString(path);
  }

  String _readFile(int p_path) {
    var path = stringify(p_path);
    var data = _fs.readFile(path);
    _fs.unlink(path);
    return data;
  }

  String _pathname() => 'file';

  void _CHKERR(int err) {
    if (err != 0) {
      finalize();
      throw err; // TODO: LisError
    }
  }
}

class LinearProblem<S> {
  final LIS _lis;
  final Matrix<S> A;
  final Vector<S> b, x;

  factory LinearProblem(LIS lis, String data) {
    var A = new Matrix<S>(lis);
    var b = new Vector<S>(lis);
    var x = new Vector<S>(lis);
    int p_path = lis._writeFile(data);
    int err = lis.callFunc('lis_input', [A._p_mat, b._p_vec, x._p_vec, p_path]);
    lis._CHKERR(err);
    lis._removeFile(p_path);
    return new LinearProblem<S>._(lis, A, b, x);
  }

  LinearProblem._(this._lis, this.A, this.b, this.x);

  String output() {
    int p_path = _lis._heapPath();
    int err = _lis.callFunc(
        'lis_output', [A._p_mat, b._p_vec, x._p_vec, Format.MM.index, p_path]);
    _lis._CHKERR(err);
    return _lis._readFile(p_path);
  }
}

enum Format { AUTO, PLAIN, MM, ASCII, BINARY, FREE, ITBL, HB, MMB }
