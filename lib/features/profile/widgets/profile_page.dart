import 'package:flutter/material.dart';
import 'package:ppeso_mobile/core/styles.dart';
import 'package:ppeso_mobile/features/profile/widgets/health_tab.dart';
import 'package:ppeso_mobile/features/profile/widgets/info_tab.dart';
import 'package:ppeso_mobile/features/profile/widgets/weight_tab.dart';
import 'package:ppeso_mobile/shared/content.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return 
    DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text("PPeso", style: AppTextStyles.titleWhite,),
          backgroundColor: AppColors.primary,
          bottom: 
          const TabBar(
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
        ),
        body: const TabBarView(children: [
            InfoTab(),
            HealthTab(),
            WeightTab(),
          ],
        ),
      ),
    );
  }
}
