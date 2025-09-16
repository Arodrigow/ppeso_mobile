import 'package:flutter/material.dart';
import 'package:ppeso_mobile/core/styles.dart';
import 'package:ppeso_mobile/features/history/widgets/custom_calendar.dart';
import 'package:ppeso_mobile/shared/content.dart';
import 'package:ppeso_mobile/shared/tab_structure.dart';

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return TabStructure(
      children: [
        Text(HistoryTabText.historyTabTitle, style: AppTextStyles.title),
        const SizedBox(height: 20),
        CustomCalendar(),
      ],
    );
  }
}
