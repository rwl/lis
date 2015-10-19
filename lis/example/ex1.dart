import 'package:lis/lis.dart';
import 'package:lis/web/dlis.dart';

main() {
  final lis = new DLIS();

  var b = new Vector(lis)..size = 5;

  b.fill(4.9);

  b.print();

  b.destroy();

  lis.finalize();
}
