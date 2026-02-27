import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ppeso_mobile/core/styles.dart';
import 'package:ppeso_mobile/features/meal/pages/daily_nutrition_tab.dart';
import 'package:ppeso_mobile/features/meal/pages/new_meal_tab.dart';
import 'package:ppeso_mobile/features/meal/pages/recipes_meal_tab.dart';
import 'package:ppeso_mobile/features/meal/pages/register_meal_tab.dart';
import 'package:ppeso_mobile/shared/content.dart';
import 'package:ppeso_mobile/shared/logout_button.dart';

class MealPage extends StatelessWidget {
  const MealPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
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
            tabs: [
              Tab(text: MealPageText.dailyNutritionTabTitle),
              Tab(text: MealPageText.recipesMealTabTitle),
            ],
            labelColor: AppColors.appBackground,
            unselectedLabelColor: AppColors.widgetBackground,
            indicatorColor: AppColors.appBackground,
          ),
          actions: [const LogoutButton()],
        ),
        body: TabBarView(
          children: [
            DailyNutritionTab(
              onOpenNewMeal: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => _StandaloneTabPage(
                    title: 'Nova refeição',
                    child: const NewMealTab(),
                  ),
                ),
              ),
            ),
            RecipesMealTab(
              onOpenNewMeal: (initialFirstItem) => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => _StandaloneTabPage(
                    title: 'Nova refeição',
                    child: NewMealTab(initialFirstItem: initialFirstItem),
                  ),
                ),
              ),
              onOpenRegisterRecipe: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const _StandaloneTabPage(
                    title: 'Nova',
                    child: RegisterMealTab(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StandaloneTabPage extends StatelessWidget {
  final String title;
  final Widget child;

  const _StandaloneTabPage({required this.title, required this.child});

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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(36),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.appBackground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
      body: child,
    );
  }
}
