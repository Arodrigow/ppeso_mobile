import 'package:flutter/material.dart';
import 'package:ppeso_mobile/core/styles.dart';
import 'package:ppeso_mobile/features/history/pages/history_tab.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("PPeso", style: AppTextStyles.titleWhite),
        backgroundColor: AppColors.primary,
      ),
      body: HistoryTab(),
    );
  }
}
