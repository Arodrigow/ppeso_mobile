import 'package:flutter/material.dart';
import 'package:ppeso_mobile/core/styles.dart';
import 'package:ppeso_mobile/features/profile/models/date_model.dart';
import 'package:ppeso_mobile/features/profile/widgets/weight_chart.dart';
import 'package:ppeso_mobile/shared/tab_structure.dart';

class WeightTab extends StatelessWidget {
  const WeightTab({super.key});

  @override
  Widget build(BuildContext context) {
    return TabStructure(
      children: [
        Text("PPeso", style: AppTextStyles.title),
        const SizedBox(height: 20),
        WeightChart(
          weightData: [
            DateModel(date: DateTime(2025, 1, 1), weight: 80.5),
            // DateModel(date: DateTime(2025, 2, 1), weight: 79.2),
            // DateModel(date: DateTime(2025, 3, 1), weight: 78.8),
          ],
        ),
      ],
    );
  }
}
