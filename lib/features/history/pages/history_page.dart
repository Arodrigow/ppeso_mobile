import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ppeso_mobile/core/styles.dart';
import 'package:ppeso_mobile/features/history/pages/history_tab.dart';
import 'package:ppeso_mobile/shared/logout_button.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: SvgPicture.asset(
                'assets/svg/svg_base.svg',
                width: 24,
                height: 24,
              ),
            ),
            const SizedBox(width: 8),
            Text('PPeso', style: AppTextStyles.titleWhite),
          ],
        ),
        backgroundColor: AppColors.primary,
        actions: [const LogoutButton()],
      ),
      body: HistoryTab(),
    );
  }
}
