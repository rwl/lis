library lis.test.module;

import 'package:test/test.dart';
import 'package:lis/src/web/module.dart';

import 'random.dart';

moduleTest(LisModule module, rscal()) {
  test('scalar', () {
    var c = rscal();
    int ptr = module.heapScalar(c);
    expect(ptr, isNonZero);
    var c2 = module.derefScalar(ptr);
    expect(c2, equals(c));
  });
  test('scalars', () {
    int n = rint();
    var l = new List.generate(n, (_) => rscal());
    int ptr = module.heapScalars(l);
    expect(ptr, isNonZero);
    var l2 = module.derefScalars(ptr, n);
    expect(l2, equals(l));
  });
}
