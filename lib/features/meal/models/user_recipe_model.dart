class UserRecipeModel {
  final String id;
  final String title;
  final String description;
  final String recipe;

  const UserRecipeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.recipe,
  });

  factory UserRecipeModel.fromJson(Map<String, dynamic> json) {
    final nestedData = json['data'];
    final source = nestedData is Map<String, dynamic> ? nestedData : json;

    return UserRecipeModel(
      id: (source['id'] ?? source['recipeId'] ?? '').toString(),
      title: (source['title'] ?? '').toString(),
      description: (source['description'] ?? '').toString(),
      recipe: (source['recipe'] ?? '').toString(),
    );
  }
}
