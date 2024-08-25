import 'package:flutter/material.dart';

class DecelerationCurve extends Curve {
  @override
  double transform(double t) {
    return 1 - (1 - t) * (1 - t); // Custom deceleration effect
  }
}