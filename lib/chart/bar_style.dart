import 'package:flutter/material.dart';

class BarStyle {
  final TextStyle dateStyle;
  final TextStyle valueStyle;
  final Color colorBar1;
  final Color colorBar2;
  BarStyle({
    required this.dateStyle,
    required this.valueStyle,
    required this.colorBar1,
    required this.colorBar2,
  });

  factory BarStyle.defaultStyle() {
    return BarStyle(
      dateStyle: const TextStyle(
        fontSize: 12.0,
        color: Colors.black,
        fontWeight: FontWeight.w400,
      ),
      valueStyle: const TextStyle(
        fontSize: 12.0,
        color: Colors.black,
        fontWeight: FontWeight.w400,
      ),
      colorBar1: const Color(0xffFF795B),
      colorBar2: const Color(0xff6171FF),
    );
  }
}
