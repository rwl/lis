library lis.internal;

import 'dart:typed_data';
import 'dart:js' as js;
import 'package:emscripten/emscripten.dart';
import 'package:emscripten/experimental.dart';

part 'vector.dart';
part 'matrix.dart';
part 'solver.dart';
part 'esolver.dart';

const int LIS_INS_VALUE = 0;

const int COMM_WORLD = 0x1;

abstract class _LIS<S> extends Module {
  final FS _fs;

  _LIS(
      {String moduleName: 'Module',
      js.JsObject context,
      List<String> options: const []})
      : super(moduleName: moduleName, context: context),
        _fs = new FS(context: context) {
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

  S _scalarOne();

  finalize() => callFunc('lis_finalize');

  LinearProblem input(String data) {
    var A = new Matrix(this);
    var b = new Vector(this);
    var x = new Vector(this);
    int p_path = _writeFile(data);
    int err = callFunc('lis_input', [A._p_mat, b._p_vec, x._p_vec, p_path]);
    _CHKERR(err);
    _removeFile(p_path);
    return new LinearProblem._(this, A, b, x);
  }

  int _writeFile(String data) {
    var path = _pathname();
    _fs.writeFile(path, data);
    return heapString(path);
  }

  void _removeFile(int p_path) {
    _fs.unlink(stringify(p_path));
    free(p_path);
  }

  int _heapPath() {
    var path = _pathname();
    return heapString(path);
  }

  String _readFile(int p_path) {
    var path = stringify(p_path);
    var data = _fs.readFile(path);
    _fs.unlink(path);
    free(p_path);
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

class LIS extends _LIS {
  LIS([List<String> options = const []]);

  int heapScalars(List list) => heapDoubles(list);

  List derefScalars(int ptr, int n, [bool free = true]) =>
      derefDoubles(ptr, n, free);

  heapScalar([val]) => heapDouble(val);

  derefScalar(int ptr, [bool free = true]) => derefDouble(ptr, free);
}

class LinearProblem {
  final _LIS _lis;
  final Matrix A;
  final Vector b, x;
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
