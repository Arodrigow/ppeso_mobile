import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ppeso_mobile/core/styles.dart';
import 'package:ppeso_mobile/features/profile/models/date_model.dart';

class WeightChart extends StatelessWidget {
  final List<DateModel> weightData;
  final double? targetWeight;
  final double height;

  const WeightChart({
    super.key,
    required this.weightData,
    this.targetWeight,
    this.height = 250,
  });

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

    final target = targetWeight;
    final minRef = target != null
        ? (target < minWeight ? target : minWeight)
        : minWeight;
    final maxRef = target != null
        ? (target > maxWeight ? target : maxWeight)
        : maxWeight;
    final minY = minRef - 1;
    final maxY = (maxRef == minRef) ? minRef + 2 : maxRef + 1;
    final yRange = maxY - minY;
    final xStep = sortedData.length <= 6
        ? 1
        : ((sortedData.length - 1) / 5).ceil();

    final yLabels = <double>[
      for (int i = 0; i <= 5; i++) minY + (yRange * (i / 5)),
      if (target != null) target,
    ];
    const eps = 0.15;
    final yInterval = math.max(0.1, yRange / 60);

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
                    final isLast = index == sortedData.length - 1;
                    if (!isLast && index % xStep != 0) {
                      return const SizedBox();
                    }
                    final date = sortedData[index].date;
                    return Text(
                      "${date.day}/${date.month}",
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
                  interval: yInterval,
                  getTitlesWidget: (value, meta) {
                    final isTarget =
                        target != null && (value - target).abs() <= eps;
                    final shouldShowLabel = yLabels.any(
                      (label) => (value - label).abs() <= eps,
                    );
                    if (!isTarget && !shouldShowLabel) {
                      return const SizedBox();
                    }
                    return Text(
                      value.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 10,
                        color: isTarget ? Colors.red : Colors.black,
                        fontWeight: isTarget
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    );
                  },
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
            extraLinesData: target == null
                ? const ExtraLinesData()
                : ExtraLinesData(
                    horizontalLines: [
                      HorizontalLine(
                        y: target,
                        color: Colors.red,
                        strokeWidth: 1.1,
                      ),
                    ],
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
