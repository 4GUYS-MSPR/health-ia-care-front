import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Widget réutilisable pour afficher un bar chart groupé.
class GenericBarChart extends StatelessWidget {
  final List<String> labels;
  final List<double> values;
  final List<Color> colors;

  const GenericBarChart({required this.labels, required this.values, required this.colors, super.key});

  @override
  Widget build(BuildContext context) {
    final valeurMax = values.isEmpty ? 10.0 : values.reduce((a, b) => a > b ? a : b);
    return BarChart(BarChartData(
      maxY: valeurMax * 1.3,
      gridData: const FlGridData(show: true),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 28,
          getTitlesWidget: (valeur, _) => Text(valeur.toInt().toString(), style: const TextStyle(fontSize: 11)),
        )),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (valeur, _) {
          final index = valeur.toInt();
          return index < labels.length
              ? Text(labels[index], style: const TextStyle(fontSize: 11))
              : const SizedBox.shrink();
        })),
      ),
      barGroups: [
        for (int index = 0; index < values.length; index++)
          BarChartGroupData(x: index, barRods: [
            BarChartRodData(
              toY: values[index],
              color: colors[index % colors.length],
              width: 28,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ]),
      ],
    ));
  }
}
