class UserRecipeModel {
  final String id;
  final String title;
  final String description;
  final String recipe;
  final double calories;
  final double carbs;
  final double proteins;
  final double fat;
  final double fibers;
  final double sodium;

  const UserRecipeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.recipe,
    this.calories = 0,
    this.carbs = 0,
    this.proteins = 0,
    this.fat = 0,
    this.fibers = 0,
    this.sodium = 0,
  });

  factory UserRecipeModel.fromJson(Map<String, dynamic> json) {
    final nestedData = json['data'];
    final source = nestedData is Map<String, dynamic> ? nestedData : json;

    return UserRecipeModel(
      id: (source['id'] ?? source['recipeId'] ?? '').toString(),
      title: (source['title'] ?? '').toString(),
      description: (source['description'] ?? '').toString(),
      recipe: (source['recipe'] ?? '').toString(),
      calories: _toDouble(source['calorias_kcal']),
      carbs: _toDouble(source['carboidratos_g']),
      proteins: _toDouble(source['proteinas_g']),
      fat: _toDouble(source['gorduras_g']),
      fibers: _toDouble(source['fibras_g']),
      sodium: _toDouble(source['sodio_mg']),
    );
  }
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.replaceAll(',', '.')) ?? 0;
  return 0;
}
