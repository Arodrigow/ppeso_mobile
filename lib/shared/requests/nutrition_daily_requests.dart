import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class NutritionDailySummary {
  final DateTime date;
  final double dailyLimit;
  final double calories;
  final double carbs;
  final double proteins;
  final double fat;
  final double fibers;

  const NutritionDailySummary({
    required this.date,
    required this.dailyLimit,
    required this.calories,
    required this.carbs,
    required this.proteins,
    required this.fat,
    required this.fibers,
  });
}

Future<NutritionDailySummary> getTodayNutritionSummary({
  required int userId,
  required String token,
}) async {
  final apiUrl =
      dotenv.env['NEXT_PUBLIC_API_URL'] ?? dotenv.env['API_URL'] ?? '';
  final localToday = DateTime.now();
  final todayParam = _toUtcMidnightIsoFromLocalDay(localToday);

  final dailyRes = await http
      .get(
        Uri.parse('$apiUrl/daily?date=$todayParam&userId=$userId'),
        headers: _authHeaders(token),
      )
      .timeout(const Duration(seconds: 120));

  if (dailyRes.statusCode < 200 || dailyRes.statusCode >= 300) {
    throw Exception('Failed to load daily (${dailyRes.statusCode})');
  }

  final daily = _extractMap(jsonDecode(dailyRes.body));
  if (daily == null) {
    return NutritionDailySummary(
      date: localToday,
      dailyLimit: 0,
      calories: 0,
      carbs: 0,
      proteins: 0,
      fat: 0,
      fibers: 0,
    );
  }

  final dailyId = _toInt(daily['id']);
  final dailyLimit = _toDouble(daily['daily_limit']) ?? 0;
  // Source of truth for consumed calories is the daily aggregate.
  final calories = _toDouble(daily['calorias_total']) ?? 0;
  double carbs = 0;
  double proteins = 0;
  double fat = 0;
  double fibers = 0;

  if (dailyId != null) {
    final mealsRes = await http
        .get(
          Uri.parse('$apiUrl/meal/$userId/$dailyId'),
          headers: _authHeaders(token),
        )
        .timeout(const Duration(seconds: 120));

    if (mealsRes.statusCode >= 200 && mealsRes.statusCode < 300) {
      final meals = _extractList(jsonDecode(mealsRes.body));
      for (final meal in meals) {
        final mealId = _toInt(meal['id']);

        carbs += _toDouble(meal['carboidratos_g']) ?? 0;
        proteins += _toDouble(meal['proteinas_g']) ?? 0;
        fat += _toDouble(meal['gorduras_g']) ?? 0;
        fibers += _toDouble(meal['fibras_g']) ?? 0;

        if (mealId == null) {
          continue;
        }
        final itemsRes = await http
            .get(
              Uri.parse('$apiUrl/item/$userId/$mealId'),
              headers: _authHeaders(token),
            )
            .timeout(const Duration(seconds: 120));

        if (itemsRes.statusCode < 200 || itemsRes.statusCode >= 300) {
          continue;
        }
        final items = _extractList(jsonDecode(itemsRes.body));
        // Fallback only when meal-level macro values are missing.
        final mealHasMacros =
            (_toDouble(meal['carboidratos_g']) ?? 0) > 0 ||
            (_toDouble(meal['proteinas_g']) ?? 0) > 0 ||
            (_toDouble(meal['gorduras_g']) ?? 0) > 0 ||
            (_toDouble(meal['fibras_g']) ?? 0) > 0;
        if (mealHasMacros) {
          continue;
        }
        for (final item in items) {
          carbs += _toDouble(item['carboidratos_g']) ?? 0;
          proteins += _toDouble(item['proteinas_g']) ?? 0;
          fat += _toDouble(item['gorduras_g']) ?? 0;
          fibers += _toDouble(item['fibras_g']) ?? 0;
        }
      }
    }
  }

  return NutritionDailySummary(
    date: _toDate(daily['data']) ?? localToday,
    dailyLimit: dailyLimit,
    calories: calories,
    carbs: carbs,
    proteins: proteins,
    fat: fat,
    fibers: fibers,
  );
}

Map<String, String> _authHeaders(String token) => {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  'Authorization': 'Bearer $token',
};

String _toUtcMidnightIsoFromLocalDay(DateTime localDate) {
  final utcMidnight = DateTime.utc(
    localDate.year,
    localDate.month,
    localDate.day,
  );
  return utcMidnight.toIso8601String();
}

Map<String, dynamic>? _extractMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is List &&
      value.isNotEmpty &&
      value.first is Map<String, dynamic>) {
    return value.first as Map<String, dynamic>;
  }
  return null;
}

List<Map<String, dynamic>> _extractList(dynamic value) {
  if (value is List) {
    return value.whereType<Map<String, dynamic>>().toList();
  }
  if (value is Map<String, dynamic>) {
    final nested = value['data'] ?? value['items'] ?? value['meals'];
    if (nested is List) {
      return nested.whereType<Map<String, dynamic>>().toList();
    }
  }
  return [];
}

double? _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.replaceAll(',', '.'));
  return null;
}

int? _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

DateTime? _toDate(dynamic value) {
  if (value is String) return DateTime.tryParse(value);
  if (value is DateTime) return value;
  return null;
}
