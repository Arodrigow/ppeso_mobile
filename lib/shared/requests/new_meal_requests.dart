import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class NutritionItemResult {
  final String alimento;
  final String porcao;
  final double caloriasKcal;
  final double carboidratosG;
  final double proteinasG;
  final double gordurasG;
  final double fibrasG;
  final double sodioMg;
  final String fonte;

  const NutritionItemResult({
    required this.alimento,
    required this.porcao,
    required this.caloriasKcal,
    required this.carboidratosG,
    required this.proteinasG,
    required this.gordurasG,
    required this.fibrasG,
    required this.sodioMg,
    required this.fonte,
  });

  factory NutritionItemResult.fromJson(Map<String, dynamic> json) {
    return NutritionItemResult(
      alimento: (json['alimento'] ?? '').toString(),
      porcao: (json['porcao'] ?? '').toString(),
      caloriasKcal: _toDouble(json['calorias_kcal']),
      carboidratosG: _toDouble(json['carboidratos_g']),
      proteinasG: _toDouble(json['proteinas_g']),
      gordurasG: _toDouble(json['gorduras_g']),
      fibrasG: _toDouble(json['fibras_g']),
      sodioMg: _toDouble(json['sodio_mg']),
      fonte: (json['fonte'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toItemCreateInput(int mealId) {
    return {
      'alimento': alimento,
      'porcao': porcao,
      'calorias_kcal': caloriasKcal,
      'carboidratos_g': carboidratosG,
      'proteinas_g': proteinasG,
      'gorduras_g': gordurasG,
      'fibras_g': fibrasG,
      'sodio_mg': sodioMg,
      'fonte': fonte,
      'mealId': mealId,
    };
  }
}

class NutritionAnalysisResult {
  final List<NutritionItemResult> itens;
  final NutritionItemResult total;
  final String? other;

  const NutritionAnalysisResult({
    required this.itens,
    required this.total,
    this.other,
  });

  bool get hasWarning => other != null && other!.trim().isNotEmpty;
}

Future<NutritionAnalysisResult> analyzeMealText({
  required int userId,
  required String token,
  required String text,
}) async {
  final apiUrl =
      dotenv.env['NEXT_PUBLIC_API_URL'] ?? dotenv.env['API_URL'] ?? '';
  final res = await http
      .post(
        Uri.parse('$apiUrl/model/$userId'),
        headers: _headers(token),
        body: jsonEncode({'data': text}),
      )
      .timeout(const Duration(seconds: 120));

  if (res.statusCode < 200 || res.statusCode >= 300) {
    throw Exception('Failed to analyze meal (${res.statusCode}): ${res.body}');
  }

  final payload = jsonDecode(res.body);
  if (payload is! Map<String, dynamic>) {
    throw Exception('Invalid analysis response format');
  }

  final other = payload['Other']?.toString();
  final itensRaw = payload['itens'] is List
      ? (payload['itens'] as List)
            .whereType<Map<String, dynamic>>()
            .map(NutritionItemResult.fromJson)
            .toList()
      : <NutritionItemResult>[];

  final totalRaw = payload['total'] is Map<String, dynamic>
      ? NutritionItemResult.fromJson(payload['total'] as Map<String, dynamic>)
      : _sumTotal(itensRaw);

  return NutritionAnalysisResult(
    itens: itensRaw,
    total: totalRaw,
    other: other,
  );
}

Future<int> createMeal({
  required int userId,
  required String token,
  required int dailyId,
  required double dailyLimit,
  required NutritionItemResult total,
}) async {
  final apiUrl =
      dotenv.env['NEXT_PUBLIC_API_URL'] ?? dotenv.env['API_URL'] ?? '';
  final res = await http
      .post(
        Uri.parse('$apiUrl/meal/$userId'),
        headers: _headers(token),
        body: jsonEncode({
          'meal': {
            'porcao': total.porcao.isEmpty ? '1 porção' : total.porcao,
            'calorias_kcal': total.caloriasKcal,
            'carboidratos_g': total.carboidratosG,
            'proteinas_g': total.proteinasG,
            'gorduras_g': total.gordurasG,
            'fibras_g': total.fibrasG,
            'sodio_mg': total.sodioMg,
            'daily': {
              'connect': {'id': dailyId},
            },
          },
          'daily_limit': dailyLimit,
        }),
      )
      .timeout(const Duration(seconds: 120));

  if (res.statusCode < 200 || res.statusCode >= 300) {
    throw Exception('Failed to create meal (${res.statusCode}): ${res.body}');
  }

  final body = jsonDecode(res.body);
  if (body is! Map<String, dynamic>) {
    throw Exception('Invalid meal create response');
  }
  final mealId = _toInt(body['id']);
  if (mealId == null) throw Exception('Meal ID not returned by backend');
  return mealId;
}

Future<void> createItems({
  required int userId,
  required String token,
  required int mealId,
  required List<NutritionItemResult> itens,
}) async {
  final apiUrl =
      dotenv.env['NEXT_PUBLIC_API_URL'] ?? dotenv.env['API_URL'] ?? '';
  for (final item in itens) {
    final res = await http
        .post(
          Uri.parse('$apiUrl/item/$userId'),
          headers: _headers(token),
          body: jsonEncode({'data': item.toItemCreateInput(mealId)}),
        )
        .timeout(const Duration(seconds: 120));

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Failed to create item (${res.statusCode}): ${res.body}');
    }
  }
}

NutritionItemResult _sumTotal(List<NutritionItemResult> itens) {
  double calories = 0;
  double carbs = 0;
  double proteins = 0;
  double fat = 0;
  double fibers = 0;
  double sodium = 0;
  for (final i in itens) {
    calories += i.caloriasKcal;
    carbs += i.carboidratosG;
    proteins += i.proteinasG;
    fat += i.gordurasG;
    fibers += i.fibrasG;
    sodium += i.sodioMg;
  }
  return NutritionItemResult(
    alimento: 'Total',
    porcao: 'total',
    caloriasKcal: calories,
    carboidratosG: carbs,
    proteinasG: proteins,
    gordurasG: fat,
    fibrasG: fibers,
    sodioMg: sodium,
    fonte: '',
  );
}

Map<String, String> _headers(String token) => {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  'Authorization': 'Bearer $token',
};

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.replaceAll(',', '.')) ?? 0;
  return 0;
}

int? _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}
