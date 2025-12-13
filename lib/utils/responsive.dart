import 'dart:math' as math;

import 'package:flutter/cupertino.dart';

class Responsive {
  late double _width, _height, _diagonal;

  double get width => _width;
  double get height => _height;
  double get diagonal => _diagonal;

  static Responsive of(BuildContext context) => Responsive(context);

  Responsive(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    _width = size.width;
    _height = size.height;

    _diagonal = math.sqrt(math.pow(_width, 2) + math.pow(_height, 2));
  }

  double wp(double percent, {max = double.infinity}) => math.min(_width * percent / 100, max);
  double hp(double percent, {max = double.infinity}) => math.min(_height * percent / 100, max);
  double dp(double percent, {max = double.infinity}) => math.min(_diagonal * percent / 100, max);
}