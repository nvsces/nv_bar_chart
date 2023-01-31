import 'dart:math';

import 'package:nv_bar_chart/bar_data.dart';

class DataSource {
  static List<BarData> dataMock(int count) {
    final list = <BarData>[
      BarData(
        date: '',
        valueBar1: 0,
        valueBar2: 0,
      ),
      BarData(
        date: '10 Апр',
        valueBar1: 7,
        valueBar2: 5,
      ),
      BarData(
        date: '12 Апр',
        valueBar1: 9,
        valueBar2: 16,
      ),
      BarData(
        date: '13 Апр',
        valueBar1: 7,
        valueBar2: 5,
      ),
      BarData(
        date: '14 Апр',
        valueBar1: 7,
        valueBar2: 5,
      ),
    ];
    return list;
  }

  static List<BarData> generateData(int count) {
    return List.generate(count, (i) {
      return BarData(
        date: '${i + 1} Апр',
        valueBar1: i,
        valueBar2: i,
      );
    });
  }
}
