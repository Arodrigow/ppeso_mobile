import 'package:flutter/material.dart';
import 'package:ppeso_mobile/core/styles.dart';
import 'package:ppeso_mobile/features/meal/pages/new_meal_tab.dart';
import 'package:ppeso_mobile/features/meal/pages/register_meal_tab.dart';
import 'package:ppeso_mobile/shared/content.dart';

class MealPage extends StatelessWidget {
  const MealPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("PPeso", style: AppTextStyles.titleWhite),
          backgroundColor: AppColors.primary,
          bottom: const TabBar(
            // isScrollable: true,
            tabs: [
              Tab(text: MealPageText.newMealTabTitle),
              Tab(text: MealPageText.registerMealTabTitle),
            ],
            labelColor: AppColors.appBackground,
            unselectedLabelColor: AppColors.widgetBackground,
            indicatorColor: AppColors.appBackground,
          ),
        ),
        body: const TabBarView(children: [NewMealTab(), RegisterMealTab()]),
      ),
    );
  }
}
