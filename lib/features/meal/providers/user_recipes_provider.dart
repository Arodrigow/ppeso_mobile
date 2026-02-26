import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:ppeso_mobile/features/meal/models/user_recipe_model.dart';

final userRecipesProvider = StateProvider<List<UserRecipeModel>>((ref) {
  return const [];
});

final selectedRecipeForNewMealProvider = StateProvider<String?>((ref) => null);

void prependRecipeToUserList(WidgetRef ref, UserRecipeModel recipe) {
  final current = ref.read(userRecipesProvider);
  ref.read(userRecipesProvider.notifier).state = [recipe, ...current];
}

void setUserRecipes(WidgetRef ref, List<UserRecipeModel> recipes) {
  ref.read(userRecipesProvider.notifier).state = recipes;
}

void removeRecipeFromUserList(WidgetRef ref, String recipeId) {
  final current = ref.read(userRecipesProvider);
  ref.read(userRecipesProvider.notifier).state = current
      .where((recipe) => recipe.id != recipeId)
      .toList();
}
