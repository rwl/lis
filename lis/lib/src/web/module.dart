library lis.module;

import 'dart:js' show JsObject;

import 'package:emscripten/emscripten.dart';
import 'package:emscripten/experimental.dart';

abstract class LisModule<S> extends Module {
  FS _fs;

  LisModule(String funcName, List<String> options, JsObject context)
      : super.func(funcName, context) {
    _fs = new FS.func(module);
    if (_fs == null) {
      throw new ArgumentError.notNull('fs');
    }
    if (options == null) {
      options = [];
    }
    int argc = heapInt(options.length + 1);
    options = ['lis']..addAll(options);
    int p_args = heapStrings(options);
    int argv = heapInt(p_args);
    int err = callFunc('lis_initialize', [argc, argv]);
    CHKERR(err);
  }

  int heapScalars(List<S> list);

  List<S> derefScalars(int ptr, int n, [bool free = true]);

  int heapScalar([S value]);

  S derefScalar(int ptr, [bool free = true]);

//  S scalarOne();
//  S scalarZero();

  finalize() => callFunc('lis_finalize');

  int writeFile(String data) {
    var path = pathname();
    _fs.writeFile(path, data);
    return heapString(path);
  }

  void removeFile(int p_path) {
    _fs.unlink(stringify(p_path));
  }

  int heapPath() {
    var path = pathname();
    return heapString(path);
  }

  String readFile(int p_path) {
    var path = stringify(p_path);
    var data = _fs.readFile(path);
    _fs.unlink(path);
    return data;
  }

  String pathname() => 'file';

  void CHKERR(int err) {
    if (err != 0) {
      finalize();
      throw err; // TODO: LisError
    }
  }
}
