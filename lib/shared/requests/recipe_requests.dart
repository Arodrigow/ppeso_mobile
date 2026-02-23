import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:ppeso_mobile/features/meal/models/recipe_analysis_model.dart';

Future<RecipeAnalysisModel> analyzeRecipe({
  required String title,
  required String description,
  required String recipe,
  String? token,
}) async {
  final baseUrl = dotenv.env['API_URL'] ?? '';
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

Future<void> saveRecipe({
  required String title,
  required String description,
  required String recipe,
  required RecipeAnalysisModel nutrition,
  String? token,
}) async {
  final baseUrl = dotenv.env['API_URL'] ?? '';
  final endpoint = dotenv.env['RECIPE_CREATE_ENDPOINT'] ?? '$baseUrl/recipe';
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
      'nutrition': nutrition.toJson(),
    }),
  );

  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw Exception('Failed to save recipe (${response.statusCode})');
  }
}
