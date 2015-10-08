library lis.internal;

import 'dart:typed_data';
import 'dart:js' as js;
import 'package:emscripten/emscripten.dart';

part 'vector.dart';
part 'matrix.dart';
part 'solver.dart';
part 'esolver.dart';

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
