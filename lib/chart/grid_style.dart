import 'package:flutter/material.dart';

class GridStyle {
  final Color color;
  final TextStyle textStyle;
  GridStyle({
    required this.color,
    required this.textStyle,
  });

  factory GridStyle.gefaultStyle() {
    return GridStyle(
      color: const Color(0xffD6D7F9),
      textStyle: const TextStyle(
        fontSize: 12.0,
        color: Color(0xff909090),
      ),
    );
  }
}
