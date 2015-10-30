import 'dart:math';
import 'package:lis/lis.dart';
//import 'package:lis/web/dlis.dart';
import 'package:lis/native/dlis.dart';

main() {
  final lis = new DLIS();

  var b = new Vector(lis)..length = 5;

  b.fill(PI);

  b.print();

  b.destroy();

  lis.finalize();
}
