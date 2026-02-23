import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ppeso_mobile/core/styles.dart';
import 'package:ppeso_mobile/features/meal/models/user_recipe_model.dart';
import 'package:ppeso_mobile/features/meal/providers/user_recipes_provider.dart';
import 'package:ppeso_mobile/features/profile/widgets/custom_modal.dart';
import 'package:ppeso_mobile/shared/content.dart';
import 'package:ppeso_mobile/shared/tab_structure.dart';

class RecipesMealTab extends ConsumerWidget {
  const RecipesMealTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipes = ref.watch(userRecipesProvider);

    return TabStructure(
      children: [
        Text(MealPageText.recipesMealTitle, style: AppTextStyles.title),
        const SizedBox(height: 20),
        if (recipes.isEmpty)
          const Text(
            'No registered recipes yet.',
            style: AppTextStyles.description,
          ),
        ...recipes.map((recipe) => _RecipeCard(recipe: recipe)),
      ],
    );
  }
}

class _RecipeCard extends ConsumerWidget {
  final UserRecipeModel recipe;

  const _RecipeCard({required this.recipe});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      color: AppColors.widgetBackground,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(recipe.title, style: AppTextStyles.bodyBold),
            const SizedBox(height: 4),
            Text(recipe.description, style: AppTextStyles.description),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _openFullRecipe(context, ref, recipe),
                  icon: const Icon(Icons.menu_book),
                  label: const Text('Open'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(selectedRecipeForNewMealProvider.notifier).state =
                        recipe.title;
                    DefaultTabController.of(context).animateTo(0);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('"${recipe.title}" added to New Meal.'),
                      ),
                    );
                  },
                  style: ButtonStyles.defaultAcceptButton,
                  icon: const Icon(Icons.add),
                  label: const Text('Add as first item'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openFullRecipe(
    BuildContext context,
    WidgetRef ref,
    UserRecipeModel recipe,
  ) {
    CustomModal.bottomSheet(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(recipe.title, style: AppTextStyles.subTitle),
          const SizedBox(height: 10),
          Text(recipe.description, style: AppTextStyles.body),
          const SizedBox(height: 14),
          Text('Full recipe', style: AppTextStyles.bodyBold),
          const SizedBox(height: 8),
          Text(recipe.recipe, style: AppTextStyles.body),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ref.read(selectedRecipeForNewMealProvider.notifier).state =
                      recipe.title;
                  DefaultTabController.of(context).animateTo(0);
                },
                style: ButtonStyles.defaultAcceptButton,
                child: const Text('Add as first item'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
