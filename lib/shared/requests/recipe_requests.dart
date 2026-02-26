import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:ppeso_mobile/features/meal/models/recipe_analysis_model.dart';
import 'package:ppeso_mobile/features/meal/models/user_recipe_model.dart';

const Duration _recipesCacheTtl = Duration(minutes: 3);
final Map<String, _CachedRecipes> _userRecipesCache = {};

class _CachedRecipes {
  final DateTime timestamp;
  final List<UserRecipeModel> data;

  const _CachedRecipes({required this.timestamp, required this.data});
}

Future<RecipeAnalysisModel> analyzeRecipe({
  required String title,
  required String description,
  required String recipe,
  String? token,
}) async {
  final baseUrl =
      dotenv.env['NEXT_PUBLIC_API_URL'] ?? dotenv.env['API_URL'] ?? '';
  final endpoint =
      dotenv.env['RECIPE_ANALYZE_ENDPOINT'] ?? '$baseUrl/recipe/analyze';
  final response = await http.post(
    Uri.parse(endpoint),
    headers: {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      'title': title,
      'description': description,
      'recipe': recipe,
    }),
  );

  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw Exception('Failed to analyze recipe (${response.statusCode})');
  }

  final decoded = jsonDecode(response.body);
  final payload = decoded is Map<String, dynamic>
      ? (decoded['nutrition'] is Map<String, dynamic>
            ? decoded['nutrition'] as Map<String, dynamic>
            : decoded)
      : <String, dynamic>{};

  return RecipeAnalysisModel.fromJson(payload);
}

Future<UserRecipeModel> saveRecipe({
  required int userId,
  required String title,
  required String description,
  required String recipe,
  required RecipeAnalysisModel nutrition,
  required String token,
}) async {
  final baseUrl =
      dotenv.env['NEXT_PUBLIC_API_URL'] ?? dotenv.env['API_URL'] ?? '';
  final endpoint = '$baseUrl/recipe/$userId';
  final payload = {
    'title': title,
    'description': description,
    'recipe': recipe,
    'calorias_kcal': nutrition.calories,
    'carboidratos_g': nutrition.carbo,
    'proteinas_g': nutrition.proteins,
    'gorduras_g': nutrition.fat,
    'fibras_g': nutrition.fibers,
    'sodio_mg': 0.0,
  };

  http.Response response = await http
      .post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      )
      .timeout(const Duration(seconds: 120));

  // Some backend routes accept DTO wrapped in `data`.
  if (response.statusCode == 400) {
    response = await http
        .post(
          Uri.parse(endpoint),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({'data': payload}),
        )
        .timeout(const Duration(seconds: 120));
  }

  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw Exception(
      'Failed to save recipe (${response.statusCode}): ${response.body}',
    );
  }

  final parsed = jsonDecode(response.body);
  if (parsed is Map<String, dynamic>) {
    final recipePayload = _extractItem(parsed);
    if (recipePayload != null) {
      _invalidateUserRecipesCache(userId);
      return UserRecipeModel.fromJson(recipePayload);
    }
  }

  final created = UserRecipeModel(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    title: title,
    description: description,
    recipe: recipe,
  );
  _invalidateUserRecipesCache(userId);
  return created;
}

Future<List<UserRecipeModel>> getUserRecipes({
  required int userId,
  required String token,
  bool forceRefresh = false,
}) async {
  final cacheKey = _recipesKey(userId);
  if (!forceRefresh) {
    final cached = _userRecipesCache[cacheKey];
    if (cached != null &&
        DateTime.now().difference(cached.timestamp) < _recipesCacheTtl) {
      return cached.data;
    }
  }

  final baseUrl =
      dotenv.env['NEXT_PUBLIC_API_URL'] ?? dotenv.env['API_URL'] ?? '';
  final response = await http
      .get(
        Uri.parse('$baseUrl/recipe/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      )
      .timeout(const Duration(seconds: 120));

  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw Exception(
      'Failed to load recipes (${response.statusCode}): ${response.body}',
    );
  }

  final parsed = jsonDecode(response.body);
  final list = _extractList(parsed);
  final mapped = list.map(UserRecipeModel.fromJson).toList();
  _userRecipesCache[cacheKey] = _CachedRecipes(
    timestamp: DateTime.now(),
    data: mapped,
  );
  return mapped;
}

Future<void> deleteRecipe({
  required int userId,
  required String recipeId,
  required String token,
}) async {
  final baseUrl = dotenv.env['API_URL'] ?? '';
  final response = await http
      .delete(
        Uri.parse('$baseUrl/recipe/$userId/$recipeId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      )
      .timeout(const Duration(seconds: 120));

  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw Exception(
      'Failed to delete recipe (${response.statusCode}): ${response.body}',
    );
  }

  _invalidateUserRecipesCache(userId);
}

void clearUserRecipesCache({int? userId}) {
  if (userId != null) {
    _invalidateUserRecipesCache(userId);
    return;
  }
  _userRecipesCache.clear();
}

List<Map<String, dynamic>> _extractList(dynamic value) {
  if (value is List) {
    return value.whereType<Map<String, dynamic>>().toList();
  }
  if (value is Map<String, dynamic>) {
    final nested = value['data'] ?? value['items'] ?? value['recipes'];
    if (nested is List) {
      return nested.whereType<Map<String, dynamic>>().toList();
    }
    if (nested is Map<String, dynamic>) {
      final nestedList =
          nested['data'] ?? nested['items'] ?? nested['recipes'] ?? nested['list'];
      if (nestedList is List) {
        return nestedList.whereType<Map<String, dynamic>>().toList();
      }
    }
  }
  return [];
}

Map<String, dynamic>? _extractItem(Map<String, dynamic> value) {
  if (value['data'] is Map<String, dynamic>) {
    return value['data'] as Map<String, dynamic>;
  }
  if (value['recipe'] is Map<String, dynamic>) {
    return value['recipe'] as Map<String, dynamic>;
  }
  return value;
}

String _recipesKey(int userId) => 'recipes_$userId';

void _invalidateUserRecipesCache(int userId) {
  _userRecipesCache.remove(_recipesKey(userId));
}
