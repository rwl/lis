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
  }

  int heapScalars(List<S> list);

  List<S> derefScalars(int ptr, int n, [bool free = true]);

  int heapScalar([S value]);

  S derefScalar(int ptr, [bool free = true]);

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
}
