import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ppeso_mobile/core/styles.dart';
import 'package:ppeso_mobile/features/profile/models/date_model.dart';

class WeightChart extends StatelessWidget {
  final List<DateModel> weightData;

  const WeightChart({super.key, required this.weightData});

  @override
  Widget build(BuildContext context) {
    if (weightData.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No weight data available.')),
      );
    }

    final sortedData = List<DateModel>.from(weightData)
      ..sort((a, b) => a.date.compareTo(b.date));
    final firstDate = sortedData.first.date;
    final minX = 0.0;
    double maxX = sortedData.last.date.difference(firstDate).inDays.toDouble();
    if (maxX == 0) maxX = 1; // prevent crash for single point

    final minWeight = sortedData
        .map((e) => e.weight)
        .reduce((a, b) => a < b ? a : b);
    final maxWeight = sortedData
        .map((e) => e.weight)
        .reduce((a, b) => a > b ? a : b);

    final minY = minWeight - 1;
    // Ensure maxY is always greater than minY to prevent range errors in the chart.
    final maxY = (maxWeight == minWeight) ? minWeight + 2 : maxWeight + 1;

    return LineChart(
  LineChartData(
    minX: minX,
    maxX: maxX,
    minY: minY,
    maxY: maxY,
    gridData: FlGridData(show: true),
    titlesData: FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index < 0 || index >= sortedData.length) return const SizedBox();
            final date = sortedData[index].date;
            return Text("${date.day}/${date.month}");
          },
          interval: 1,
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: true),
      ),
    ),
    lineBarsData: [
      LineChartBarData(
        spots: sortedData.asMap().entries.map((e) {
          // use index as X for safe axis calculation
          return FlSpot(e.key.toDouble(), e.value.weight);
        }).toList(),
        isCurved: true,
        color: AppColors.accent,
        barWidth: 3,
      ),
    ],
  ));
  }
}
