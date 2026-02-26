import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ppeso_mobile/core/styles.dart';
import 'package:ppeso_mobile/features/meal/models/user_recipe_model.dart';
import 'package:ppeso_mobile/features/meal/providers/user_recipes_provider.dart';
import 'package:ppeso_mobile/features/profile/widgets/custom_modal.dart';
import 'package:ppeso_mobile/providers/user_provider.dart';
import 'package:ppeso_mobile/shared/content.dart';
import 'package:ppeso_mobile/shared/loading_message.dart';
import 'package:ppeso_mobile/shared/requests/recipe_requests.dart';
import 'package:ppeso_mobile/shared/tab_structure.dart';

class RecipesMealTab extends ConsumerStatefulWidget {
  const RecipesMealTab({super.key});

  @override
  ConsumerState<RecipesMealTab> createState() => _RecipesMealTabState();
}

class _RecipesMealTabState extends ConsumerState<RecipesMealTab> {
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadRecipes);
  }

  Future<void> _loadRecipes() async {
    final user = ref.read(userProvider);
    final token = ref.read(authTokenProvider);
    final userId = _parseUserId(user?['id']);

    if (userId == null || token == null || token.isEmpty) {
      if (!mounted) return;
      setState(() => _error = 'Invalid user session.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final recipes = await getUserRecipes(userId: userId, token: token);
      if (!mounted) return;
      setUserRecipes(ref, recipes);
      setState(() => _isLoading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load recipes: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _askDeleteRecipe(UserRecipeModel recipe) async {
    await CustomModal.dialog(
      context,
      title: 'Delete recipe',
      message: 'Do you want to delete "${recipe.title}"?',
      cancelText: 'Cancel',
      confirmText: 'Delete',
      onConfirm: () async {
        final user = ref.read(userProvider);
        final token = ref.read(authTokenProvider);
        final userId = _parseUserId(user?['id']);

        if (userId == null || token == null || token.isEmpty) return;

        try {
          await withLoading(
            context,
            () =>
                deleteRecipe(userId: userId, recipeId: recipe.id, token: token),
          );
          removeRecipeFromUserList(ref, recipe.id);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Recipe deleted successfully.')),
          );
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete recipe: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final recipes = ref.watch(userRecipesProvider);

    return TabStructure(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(MealPageText.recipesMealTitle, style: AppTextStyles.title),
            IconButton(
              onPressed: _isLoading ? null : _loadRecipes,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (_isLoading) const LinearProgressIndicator(),
        if (_error != null && !_isLoading)
          Text(_error!, style: const TextStyle(color: Colors.red)),
        if (!_isLoading && _error == null && recipes.isEmpty)
          const Text(
            'Nenhuma receita cadastrada',
            style: AppTextStyles.description,
          ),
        ...recipes.map((recipe) => _buildRecipeCard(recipe)),
      ],
    );
  }

  Widget _buildRecipeCard(UserRecipeModel recipe) {
    return Card(
      color: AppColors.widgetBackground,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(recipe.title, style: AppTextStyles.bodyBold),
                ),
                IconButton(
                  tooltip: 'Delete recipe',
                  onPressed: () => _askDeleteRecipe(recipe),
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(recipe.description, style: AppTextStyles.description),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _openFullRecipe(recipe),
                  icon: const Icon(Icons.menu_book),
                  label: const Text('Open'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(selectedRecipeForNewMealProvider.notifier).state =
                        recipe.title;
                    DefaultTabController.of(context).animateTo(1);
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

  void _openFullRecipe(UserRecipeModel recipe) {
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
                  DefaultTabController.of(context).animateTo(1);
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

  int? _parseUserId(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
