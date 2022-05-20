import 'package:flutter/material.dart';
import 'package:nv_bar_chart/chart/nv_bar_painter_params.dart';

class NvBarChartPainter extends CustomPainter {
  final NvBarPainterParams params;

  NvBarChartPainter({
    required this.params,
  });
  @override
  void paint(Canvas canvas, Size size) {
    _drawPriceGridAndLabels(canvas, params);
    canvas.save();
    canvas.clipRect(
        const Offset(35, 0) & Size(params.chartWidth, params.chartHeight));
    canvas.translate(params.xShift, 0);
    for (int i = 0; i < params.bars.length; i++) {
      _drawSingleDay(canvas, params, i);
    }

    canvas.restore();
  }

  void _drawPriceGridAndLabels(
    canvas,
    NvBarPainterParams params,
  ) {
    [0.0, 0.625, 1.25]
        .map((v) => ((params.maxValue - params.minValue) * v))
        .forEach((y) {
      canvas.drawLine(
        Offset(40, params.fitValue(y)),
        Offset(params.size.width, params.fitValue(y)),
        Paint()
          ..strokeWidth = 0.5
          ..color = Colors.black,
      );
      final priceTp = TextPainter(
        text: TextSpan(
          text: y.toStringAsFixed(1),
          style: TextStyle(color: Colors.black),
        ),
      )
        ..textDirection = TextDirection.ltr
        ..layout();
      priceTp.paint(
          canvas,
          Offset(
            0,
            params.fitValue(y) - priceTp.height / 2,
          ));
    });
  }

  void _drawSingleDay(canvas, NvBarPainterParams params, int i) {
    final candle = params.bars[i];
    final x = i * (params.sectionForBarsWidth) + 15;
    final valueBar1 = candle.valueBar1.toDouble();
    final valueBar2 = candle.valueBar2.toDouble();
    final dl = (params.sectionForBarsWidth - (4 + 30)) / 2;
    if (params.bars[i].date.isNotEmpty) {
      canvas.drawRRect(
          RRect.fromRectAndRadius(
            Offset(x - 2 - dl, params.fitValue(0.0)) &
                Size(dl, params.fitValue(valueBar1) - params.fitValue(0.0)),
            const Radius.circular(4),
          ),
          Paint()..color = params.colorBar1 ?? Colors.blue);

      // legenda 1
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Offset(x - 2 - dl, params.fitValue(valueBar1) - dl - 5) &
              Size(dl, dl),
          const Radius.circular(4),
        ),
        Paint()
          ..color = params.colorBar1 ?? Colors.blue
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );

      final legendScaleFactor = dl / 17;
      final textPositionL1 = valueBar1.toStringAsFixed(0).length > 1
          ? x - dl + dl / 18
          : x - 3 * dl / 4;
      final countTextL1 = TextPainter(
        textScaleFactor: legendScaleFactor,
        textAlign: TextAlign.end,
        text: TextSpan(
          text: valueBar1.toStringAsFixed(0),
          style: params.valueStyle,
        ),
      )
        ..textDirection = TextDirection.rtl
        ..layout();
      countTextL1.paint(
          canvas,
          Offset(
            textPositionL1,
            params.fitValue(valueBar1) - dl - dl / 10,
          ));

      // legenda 2

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Offset(x + 2, params.fitValue(valueBar2) - dl - 5) & Size(dl, dl),
          const Radius.circular(4),
        ),
        Paint()
          ..color = params.colorBar2 ?? Colors.blue
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );
      final textPositionL2 = valueBar2.toStringAsFixed(0).length > 1
          ? x + dl / 8
          : x + 1.8 * dl / 4;
      final countTextL2 = TextPainter(
        textScaleFactor: legendScaleFactor,
        textAlign: TextAlign.end,
        text: TextSpan(
          text: valueBar2.toStringAsFixed(0),
          style: params.valueStyle,
        ),
      )
        ..textDirection = TextDirection.ltr
        ..layout();
      countTextL2.paint(
          canvas,
          Offset(
            textPositionL2,
            params.fitValue(valueBar2) - dl - dl / 10,
          ));

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Offset(x + 2, params.fitValue(0.0)) &
              Size(dl, params.fitValue(valueBar2) - params.fitValue(0.0)),
          const Radius.circular(4),
        ),
        Paint()..color = params.colorBar2 ?? Colors.blue,
      );

      final scaleFactor = params.sectionForBarsWidth / 80;

      final textDate = TextPainter(
        textScaleFactor: scaleFactor,
        textAlign: TextAlign.end,
        text: TextSpan(
          text: '${params.bars[i].date}',
          style: params.dateStyle,
        ),
      )
        ..textDirection = TextDirection.rtl
        ..layout();
      textDate.paint(
          canvas,
          Offset(
            x - 2 - dl / 2 - dl / 4,
            params.chartHeight - 25,
          ));
    }
  }

  @override
  bool shouldRepaint(NvBarChartPainter oldDelegate) =>
      params.shouldRepaint(oldDelegate.params);
}
