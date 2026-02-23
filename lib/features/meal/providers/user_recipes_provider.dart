import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:ppeso_mobile/features/meal/models/user_recipe_model.dart';

final userRecipesProvider = StateProvider<List<UserRecipeModel>>((ref) {
  return const [
    UserRecipeModel(
      id: 'r1',
      title: 'Frango grelhado com arroz',
      description: 'Prato proteico simples com arroz integral e salada.',
      recipe:
          'Ingredientes:\n- 150g de peito de frango\n- 100g de arroz integral cozido\n- Salada verde\n\nPreparo:\n1. Tempere e grelhe o frango.\n2. Cozinhe o arroz.\n3. Monte o prato com a salada.',
    ),
    UserRecipeModel(
      id: 'r2',
      title: 'Omelete de legumes',
      description: 'Omelete rapida para cafe da manha ou jantar leve.',
      recipe:
          'Ingredientes:\n- 2 ovos\n- 1/4 cebola\n- 1/4 tomate\n- Sal e pimenta\n\nPreparo:\n1. Bata os ovos.\n2. Refogue legumes rapidamente.\n3. Adicione os ovos e cozinhe ate firmar.',
    ),
    UserRecipeModel(
      id: 'r3',
      title: 'Iogurte com aveia e banana',
      description: 'Lanche pratico com fibras e carboidratos.',
      recipe:
          'Ingredientes:\n- 1 pote de iogurte natural\n- 2 colheres de aveia\n- 1 banana picada\n\nPreparo:\n1. Misture tudo em uma tigela.\n2. Sirva gelado.',
    ),
  ];
});

final selectedRecipeForNewMealProvider = StateProvider<String?>((ref) => null);

void prependRecipeToUserList(WidgetRef ref, UserRecipeModel recipe) {
  final current = ref.read(userRecipesProvider);
  ref.read(userRecipesProvider.notifier).state = [recipe, ...current];
}

