import 'dart:math';

double roundFloor(double input, int fractionDigits) =>
    (input * pow(10, fractionDigits)).floorToDouble() / pow(10, fractionDigits);
