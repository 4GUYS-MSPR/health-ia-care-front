import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Widget réutilisable pour afficher un camembert (pie chart).
class GenericPieChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final List<Color> colors;

  const GenericPieChart({required this.values, required this.labels, required this.colors, super.key});

  @override
  Widget build(BuildContext context) {
    final total = values.fold(0.0, (a, b) => a + b);
    final sections = [
      for (int i = 0; i < values.length; i++)
        PieChartSectionData(
          value: values[i],
          title: total == 0 ? '0%' : '${(values[i] / total * 100).toStringAsFixed(0)}%',
          color: colors[i % colors.length],
          radius: 60,
          titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
        ),
    ];
    return PieChart(PieChartData(sections: sections, centerSpaceRadius: 36, sectionsSpace: 2));
  }
}
