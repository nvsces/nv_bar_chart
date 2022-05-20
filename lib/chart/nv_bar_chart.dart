import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:nv_bar_chart/bar_data.dart';
import 'package:nv_bar_chart/chart/bar_style.dart';
import 'package:nv_bar_chart/chart/nv_bar_chart_painter.dart';
import 'package:nv_bar_chart/chart/nv_bar_painter_params.dart';

class NvBarChart extends StatefulWidget {
  final List<BarData> bars;
  final int initialVisibleCandleCount;
  final ValueChanged<BarData>? onTap;
  final ValueChanged<double>? onCandleResize;
  final BarStyle? barStyle;

  const NvBarChart({
    Key? key,
    required this.bars,
    this.barStyle,
    this.initialVisibleCandleCount = 5,
    this.onTap,
    this.onCandleResize,
  }) : super(key: key);

  @override
  State<NvBarChart> createState() => _NvBarChartState();
}

class _NvBarChartState extends State<NvBarChart> {
  late double _sectionForBarsWidth;
  double get _paddingBar => _sectionForBarsWidth;
  late double _startOffset;

  double? _prevChartWidth;
  late double _prevSectionForBarsWidth;
  late double _prevStartOffset;
  late Offset _initialFocalPoint;
  NvBarPainterParams? _prevParams;

  BarStyle get barStyle => widget.barStyle ?? BarStyle.defaultStyle();

  List<BarData> get bars => [
        BarData(
          date: '',
          valueBar1: 0,
          valueBar2: 0,
        ),
        ...widget.bars,
      ];

  @override
  Widget build(BuildContext context) {
    return bars.length < 2
        ? Container()
        : LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final size = constraints.biggest;
              final w = (size.width - 10.0) * 1;
              _handleResize(w);
              final int start = (_startOffset / (_sectionForBarsWidth)).floor();
              final int count = (w / (_sectionForBarsWidth)).ceil();
              final int end = (start + count).clamp(
                  start, (start > bars.length) ? start + 1 : bars.length);
              final candlesInRange = bars.getRange(start, end).toList();
              if (end < bars.length) {
                final nextItem = bars[end];
                candlesInRange.add(nextItem);
              }
              final halfCandle = _sectionForBarsWidth / 2;
              final fractionCandle =
                  _startOffset - start * _sectionForBarsWidth;
              final xShift = halfCandle - fractionCandle;

              double? highest(BarData c) {
                return max(c.valueBar1.toDouble(), c.valueBar2.toDouble());
              }

              final maxPrice =
                  candlesInRange.map(highest).whereType<double>().reduce(max);

              const minPrice = 0.0;
              final childTween = TweenAnimationBuilder(
                tween: MyPainterParamsTween(
                  end: NvBarPainterParams(
                    dateStyle: barStyle.dateStyle,
                    valueStyle: barStyle.valueStyle,
                    colorBar1: barStyle.colorBar1,
                    colorBar2: barStyle.colorBar2,
                    paddingBar: _paddingBar,
                    bars: candlesInRange,
                    size: size,
                    sectionForBarsWidth: _sectionForBarsWidth,
                    startOffset: _startOffset,
                    maxValue: maxPrice,
                    minValue: minPrice,
                    xShift: xShift,
                  ),
                ),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                builder: (_, NvBarPainterParams params, __) {
                  _prevParams = params;
                  return RepaintBoundary(
                    child: CustomPaint(
                      size: size,
                      painter: NvBarChartPainter(
                        params: params,
                      ),
                    ),
                  );
                },
              );
              return Listener(
                onPointerSignal: (signal) {
                  if (signal is PointerScrollEvent) {
                    final dy = signal.scrollDelta.dy;
                    if (dy.abs() > 0) {
                      _onScaleStart(signal.position);
                      _onScaleUpdate(
                        dy > 0 ? 0.9 : 1.1,
                        signal.position,
                        w,
                      );
                    }
                  }
                },
                child: GestureDetector(
                  onScaleStart: (details) =>
                      _onScaleStart(details.localFocalPoint),
                  onScaleUpdate: (details) =>
                      _onScaleUpdate(details.scale, details.localFocalPoint, w),
                  child: childTween,
                ),
              );
            },
          );
  }

  _onScaleStart(Offset focalPoint) {
    _prevSectionForBarsWidth = _sectionForBarsWidth;
    _prevStartOffset = _startOffset;
    _initialFocalPoint = focalPoint;
  }

  _onScaleUpdate(double scale, Offset focalPoint, double w) {
    final sectionForBarsWidth = (_getMinSectionForBarsWidth(w) >
            _getMaxSectionForBarsWidth(w))
        ? (_prevSectionForBarsWidth * scale)
            .clamp(_getMaxSectionForBarsWidth(w), _getMinSectionForBarsWidth(w))
        : (_prevSectionForBarsWidth * scale).clamp(
            _getMinSectionForBarsWidth(w), _getMaxSectionForBarsWidth(w));

    final clampedScale = sectionForBarsWidth / _prevSectionForBarsWidth;
    var startOffset = _prevStartOffset * clampedScale;
    final dx = (focalPoint - _initialFocalPoint).dx * -1;
    startOffset += dx;
    final double prevCount = w / _prevSectionForBarsWidth;
    final double currCount = w / sectionForBarsWidth;
    final zoomAdjustment = (currCount - prevCount) * sectionForBarsWidth;
    final focalPointFactor = focalPoint.dx / w;
    startOffset -= zoomAdjustment * focalPointFactor;
    startOffset =
        startOffset.clamp(0, _getMaxStartOffset(w, sectionForBarsWidth));
    if (sectionForBarsWidth != _sectionForBarsWidth) {
      widget.onCandleResize?.call(sectionForBarsWidth);
    }
    setState(() {
      _sectionForBarsWidth = sectionForBarsWidth;
      _startOffset = startOffset;
    });
  }

  _handleResize(double w) {
    if (w == _prevChartWidth) return;
    if (_prevChartWidth != null) {
      _sectionForBarsWidth = _sectionForBarsWidth.clamp(
        _getMinSectionForBarsWidth(w),
        _getMaxSectionForBarsWidth(w),
      );
      _startOffset = _startOffset.clamp(
        5,
        _getMaxStartOffset(w, _sectionForBarsWidth),
      );
    } else {
      final count = min(
            bars.length,
            widget.initialVisibleCandleCount,
          ) -
          1;
      _sectionForBarsWidth = w / count;
      _startOffset = (bars.length - count) * _sectionForBarsWidth;
    }
    _prevChartWidth = w;
  }

  double _getMinSectionForBarsWidth(double w) => 126.0;

  double _getMaxSectionForBarsWidth(double w) => w / min(8, bars.length);

  double _getMaxStartOffset(double w, double candleWidth) {
    final count = w / candleWidth;
    final start = bars.length - count;
    return max(0, candleWidth * start);
  }
}
