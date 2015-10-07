library lis.test.matrix;

import 'package:test/test.dart';
import 'package:lis/lis.dart';

import 'random.dart';

testMatrix() {
  group('matrix', () {
    LIS lis;
    Matrix m;

    setUp(() {
      lis = new LIS();
      m = new Matrix(lis);
    });

    tearDown(() {
      m.destroy();
      lis.finalize();
    });

    test('assemble', () {
      expect(m.assembled(), isTrue);
      m.size = rint();
      expect(m.assembled(), isFalse);
      m.setValue(0, 0, rand());
      expect(m.assembled(), isTrue);
      m.type = MatrixType.DENSE;
      expect(m.assembled(), isTrue);
      m.assemble();
      expect(m.assembled(), isTrue);
    });
  });
}
