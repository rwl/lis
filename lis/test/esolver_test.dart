library lis.test.esolver;

import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:lis/lis.dart';
import 'package:quiver/iterables.dart';

Matrix wilkinson(LIS lis, {int N: 21, bool positive: false}) {
  var nnd = 3;
  var index = [-1, 0, 1];
  var value = new Float64List(nnd * N);

  value.fillRange(1, N, lis.one);

  double n = (N - 1) / 2;
  enumerate(range(-n, n + 1)).forEach((iv) {
    value[N + iv.index] = positive ? iv.value.abs() : iv.value;
  });

  value.fillRange(2 * N, 3 * N - 1, lis.one);

  return new Matrix.dia(lis, N, nnd, index, value);
}

esolverTest(LIS lis) {
  Matrix W;
  Vector x;
  setUp(() {
    W = wilkinson(lis, positive: false);
    x = new Vector.fromMatrix(lis, W);
  });
  test('wilkinson', () {
    //print(W.output());

    var esolver = new EigenSolver(lis);
    esolver.setOption("-e li -ss 21");
    esolver.setOptionC();
    var evalue = esolver.solve(W, x);

    print(evalue);
    x.print();
    esolver.evalues().print();
  });
}
