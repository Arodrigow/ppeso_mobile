import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ppeso_mobile/core/styles.dart';
import 'package:ppeso_mobile/features/profile/models/date_model.dart';

class WeightChart extends StatelessWidget {
  final List<DateModel> weightData;
  final double height;

  const WeightChart({super.key, required this.weightData, this.height = 250});

  @override
  Widget build(BuildContext context) {
    if (weightData.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(child: Text('No weight data available.')),
      );
    }

    final sortedData = List<DateModel>.from(weightData)
      ..sort((a, b) => a.date.compareTo(b.date));

    final minWeight = sortedData
        .map((e) => e.weight)
        .reduce((a, b) => a < b ? a : b);
    final maxWeight = sortedData
        .map((e) => e.weight)
        .reduce((a, b) => a > b ? a : b);

    final minY = minWeight - 1;
    final maxY = (maxWeight == minWeight) ? minWeight + 2 : maxWeight + 1;

    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: (sortedData.length - 1).toDouble(),
            minY: minY,
            maxY: maxY,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              horizontalInterval: 1,
              verticalInterval: 1,
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.grey.withValues(
                  alpha: (Colors.grey.a * 0.2),
                  red: (Colors.grey.r),
                  green: (Colors.grey.g),
                  blue: (Colors.grey.b),
                ),
                strokeWidth: 1,
              ),
              getDrawingVerticalLine: (value) => FlLine(
                color: Colors.grey.withValues(
                  alpha: (Colors.grey.a * 0.1),
                  red: (Colors.grey.r),
                  green: (Colors.grey.g),
                  blue: (Colors.grey.b),
                ),
                strokeWidth: 1,
              ),
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= sortedData.length) {
                      return const SizedBox();
                    }
                    final date = sortedData[index].date;
                    return Text(
                      "${date.day}/${date.month}/${date.year}",
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                  interval: 1,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  interval: 1,
                  getTitlesWidget: (value, meta) => Text(
                    value.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(
                color: Colors.grey.withValues(
                  alpha: (Colors.grey.a * 0.3),
                  red: (Colors.grey.r),
                  green: (Colors.grey.g),
                  blue: (Colors.grey.b),
                ),
                width: 1,
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: sortedData
                    .asMap()
                    .entries
                    .map((e) => FlSpot(e.key.toDouble(), e.value.weight))
                    .toList(),
                isCurved: true,
                color: AppColors.accent,
                barWidth: 3,
                dotData: FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  color: AppColors.accent.withValues(
                    alpha: (AppColors.accent.a * 0.1),
                    red: (AppColors.accent.r),
                    green: (AppColors.accent.g),
                    blue: (AppColors.accent.b),
                  ),
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    final date = sortedData[spot.x.toInt()].date;
                    return LineTooltipItem(
                      "${date.day}/${date.month}/${date.year}\n${spot.y.toStringAsFixed(1)} kg",
                      const TextStyle(color: Colors.white),
                    );
                  }).toList();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
