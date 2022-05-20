import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:nv_bar_chart/chart/grid_style.dart';

import '../bar_data.dart';

class NvBarPainterParams {
  final List<BarData> bars;
  final Size size;
  final double sectionForBarsWidth;
  final double startOffset;

  final double maxValue;
  final double minValue;
  final double paddingBar;

  final Color? colorBar1;
  final Color? colorBar2;
  final TextStyle? valueStyle;
  final TextStyle? dateStyle;
  final GridStyle gridStyle;

  final double xShift;

  NvBarPainterParams({
    required this.bars,
    required this.size,
    required this.sectionForBarsWidth,
    required this.startOffset,
    required this.maxValue,
    required this.minValue,
    required this.xShift,
    required this.paddingBar,
    this.colorBar1,
    this.colorBar2,
    this.valueStyle,
    this.dateStyle,
    required this.gridStyle,
  });

  double get chartWidth => size.width - 40;

  double get chartHeight => size.height - 10.0;

  double get priceHeight => chartHeight - 120.0;

  double fitValue(double y) =>
      90 + (priceHeight * (maxValue - y) / (maxValue - minValue));

  static NvBarPainterParams lerp(
      NvBarPainterParams a, NvBarPainterParams b, double t) {
    double lerpField(double getField(NvBarPainterParams p)) =>
        lerpDouble(getField(a), getField(b), t)!;
    return NvBarPainterParams(
      dateStyle: b.dateStyle,
      gridStyle: b.gridStyle,
      valueStyle: b.valueStyle,
      colorBar1: b.colorBar1,
      colorBar2: b.colorBar2,
      bars: b.bars,
      size: b.size,
      paddingBar: b.paddingBar,
      sectionForBarsWidth: b.sectionForBarsWidth,
      startOffset: b.startOffset,
      maxValue: lerpField((p) => p.maxValue),
      minValue: lerpField((p) => p.minValue),
      xShift: b.xShift,
    );
  }

  bool shouldRepaint(NvBarPainterParams other) {
    if (bars.length != other.bars.length) return true;

    if (size != other.size ||
        sectionForBarsWidth != other.sectionForBarsWidth ||
        startOffset != other.startOffset ||
        xShift != other.xShift) return true;

    if (maxValue != other.maxValue || minValue != other.minValue) return true;

    return false;
  }
}

class MyPainterParamsTween extends Tween<NvBarPainterParams> {
  MyPainterParamsTween({
    NvBarPainterParams? begin,
    required NvBarPainterParams end,
  }) : super(begin: begin, end: end);

  @override
  NvBarPainterParams lerp(double t) =>
      NvBarPainterParams.lerp(begin ?? end!, end!, t);
}
