import 'package:flutter/material.dart';
import 'package:ppeso_mobile/core/styles.dart';
import 'package:ppeso_mobile/features/meal/pages/new_meal_tab.dart';
import 'package:ppeso_mobile/features/meal/pages/recipes_meal_tab.dart';
import 'package:ppeso_mobile/features/meal/pages/register_meal_tab.dart';
import 'package:ppeso_mobile/shared/content.dart';

class MealPage extends StatelessWidget {
  const MealPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('PPeso', style: AppTextStyles.titleWhite),
          backgroundColor: AppColors.primary,
          bottom: const TabBar(
            tabs: [
              Tab(text: MealPageText.newMealTabTitle),
              Tab(text: MealPageText.registerMealTabTitle),
              Tab(text: MealPageText.recipesMealTabTitle),
            ],
            labelColor: AppColors.appBackground,
            unselectedLabelColor: AppColors.widgetBackground,
            indicatorColor: AppColors.appBackground,
          ),
        ),
        body: const TabBarView(
          children: [NewMealTab(), RegisterMealTab(), RecipesMealTab()],
        ),
      ),
    );
  }
}
