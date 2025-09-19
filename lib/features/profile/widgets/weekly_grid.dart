import 'package:flutter/material.dart';
import 'package:ppeso_mobile/core/styles.dart';
import 'package:ppeso_mobile/features/profile/models/daily_value.dart';

class WeeklyGrid extends StatelessWidget {
  final List<DailyValue> days;
  final int columns;

  

  const WeeklyGrid({super.key, required this.days, this.columns = 7});

  @override
  Widget build(BuildContext context) {    
    return GridView.count(
      crossAxisCount: columns,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 0.5,
      children: days.map((day) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(day.label, style: AppTextStyles.bodyBold),
            const SizedBox(height: 10),
            Text("${day.value}"),
          ],
        );
      }).toList(),
    );
  }
}
