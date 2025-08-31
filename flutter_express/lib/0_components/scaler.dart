import 'package:flutter/material.dart';

extension ScaleExtension on BuildContext {
  double scaleFactor({double baseWidth = 375.0}) {
    return MediaQuery.of(this).size.width / baseWidth;
  }
}
