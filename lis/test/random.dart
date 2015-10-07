library lis.test.random;

import 'dart:math';

final Random _r = new Random();

int rint([int max = 8]) => _r.nextInt(max) + 2;

double rand() => _r.nextDouble();
