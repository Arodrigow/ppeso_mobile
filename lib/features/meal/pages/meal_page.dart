import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ppeso_mobile/core/styles.dart';
import 'package:ppeso_mobile/features/meal/pages/daily_nutrition_tab.dart';
import 'package:ppeso_mobile/features/meal/pages/new_meal_tab.dart';
import 'package:ppeso_mobile/features/meal/pages/recipes_meal_tab.dart';
import 'package:ppeso_mobile/features/meal/pages/register_meal_tab.dart';
import 'package:ppeso_mobile/shared/content.dart';
import 'package:ppeso_mobile/shared/logout_button.dart';

class MealPage extends StatefulWidget {
  const MealPage({super.key});

  @override
  State<MealPage> createState() => _MealPageState();
}

class _MealPageState extends State<MealPage> {
  int _dailyTabVersion = 0;

  Future<void> _openNewMealPage(
    BuildContext tabContext, {
    String? initialFirstItem,
  }) async {
    final created = await Navigator.of(tabContext).push<bool>(
      MaterialPageRoute(
        builder: (_) => _StandaloneTabPage(
          title: 'Nova refeição',
          child: NewMealTab(initialFirstItem: initialFirstItem),
        ),
      ),
    );

    if (!mounted || !tabContext.mounted || created != true) return;
    setState(() => _dailyTabVersion++);
    DefaultTabController.of(tabContext).animateTo(0);
    ScaffoldMessenger.of(tabContext).showSnackBar(
      const SnackBar(content: Text('Refeição criada com sucesso.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Builder(
        builder: (tabContext) => Scaffold(
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
                key: ValueKey('daily_tab_$_dailyTabVersion'),
                onOpenNewMeal: () => _openNewMealPage(tabContext),
              ),
              RecipesMealTab(
                onOpenNewMeal: (initialFirstItem) => _openNewMealPage(
                  tabContext,
                  initialFirstItem: initialFirstItem,
                ),
                onOpenRegisterRecipe: () => Navigator.of(tabContext).push(
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
