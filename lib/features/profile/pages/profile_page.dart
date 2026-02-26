import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ppeso_mobile/core/styles.dart';
import 'package:ppeso_mobile/features/profile/pages/health_tab.dart';
import 'package:ppeso_mobile/features/profile/pages/info_tab.dart';
import 'package:ppeso_mobile/features/profile/pages/weight_tab.dart';
import 'package:ppeso_mobile/shared/content.dart';
import 'package:ppeso_mobile/shared/logout_button.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
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
          bottom: const TabBar(
            // isScrollable: true,
            tabs: [
              Tab(text: ProfilePageText.info),
              Tab(text: ProfilePageText.health),
              Tab(text: ProfilePageText.weight),
            ],
            labelColor: AppColors.appBackground,
            unselectedLabelColor: AppColors.widgetBackground,
            indicatorColor: AppColors.appBackground,
          ),
          actions: [const LogoutButton()],
        ),
        body: const TabBarView(children: [InfoTab(), HealthTab(), WeightTab()]),
      ),
    );
  }
}
