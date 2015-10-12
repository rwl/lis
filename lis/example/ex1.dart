import 'package:lis/dlis.dart';

main() {
  final lis = new LIS();

  var b = new Vector(lis)..size = 5;

  b.fill(4.9);

  b.print();

  b.destroy();

  lis.finalize();
}
