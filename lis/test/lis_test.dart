import 'package:test/test.dart';
import 'package:lis/dlis.dart' as dlis;
import 'package:lis/zlis.dart' as zlis;

import 'vector_test.dart';
import 'matrix_test.dart';

main() {
  group('lis', () {
    group('double', () {
      makeLIS() => new dlis.DLIS();
      group('vector', () => vectorTest(makeLIS));
      group('matrix', () => matrixTest(makeLIS));
    });
    group('complex', () {
      makeLIS() => new zlis.ZLIS();
//      group('vector', () => vectorTest(makeLIS));
//      group('matrix', () => matrixTest(makeLIS));
    });
  });
}
