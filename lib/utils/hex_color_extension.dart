import 'package:flutter/material.dart';

extension HexColor on String {
  Color toColor() {
    String hex = replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }
}