import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

const Duration _dashboardCacheTtl = Duration(seconds: 45);
const Duration _calendarCacheTtl = Duration(minutes: 5);

final Map<String, _CachedDashboard> _dashboardCache = {};
final Map<String, _CachedCalendar> _calendarCache = {};

class _CachedDashboard {
  final DateTime timestamp;
  final NutritionDailyDashboard data;

  const _CachedDashboard({required this.timestamp, required this.data});
}

class _CachedCalendar {
  final DateTime timestamp;
  final List<DailyCalendarSummary> data;

  const _CachedCalendar({required this.timestamp, required this.data});
}

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

class MealItemDetails {
  final int id;
  final String alimento;
  final String porcao;
  final double caloriasKcal;
  final double carboidratosG;
  final double proteinasG;
  final double gordurasG;
  final double fibrasG;
  final double sodioMg;
  final String fonte;

  const MealItemDetails({
    required this.id,
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
}

class MealDetails {
  final int id;
  final String porcao;
  final double caloriasKcal;
  final double carboidratosG;
  final double proteinasG;
  final double gordurasG;
  final double fibrasG;
  final double sodioMg;
  final List<MealItemDetails> itens;

  const MealDetails({
    required this.id,
    required this.porcao,
    required this.caloriasKcal,
    required this.carboidratosG,
    required this.proteinasG,
    required this.gordurasG,
    required this.fibrasG,
    required this.sodioMg,
    required this.itens,
  });
}

class NutritionDailyDashboard {
  final NutritionDailySummary summary;
  final List<MealDetails> meals;
  final int? dailyId;

  const NutritionDailyDashboard({
    required this.summary,
    required this.meals,
    this.dailyId,
  });
}

class DailyCalendarSummary {
  final DateTime date;
  final double dailyLimit;
  final double calories;

  const DailyCalendarSummary({
    required this.date,
    required this.dailyLimit,
    required this.calories,
  });
}

Future<NutritionDailyDashboard> getTodayNutritionDashboard({
  required int userId,
  required String token,
  bool forceRefresh = false,
}) async {
  return getNutritionDashboardByDate(
    userId: userId,
    token: token,
    localDate: DateTime.now(),
    forceRefresh: forceRefresh,
  );
}

Future<NutritionDailyDashboard> getNutritionDashboardByDate({
  required int userId,
  required String token,
  required DateTime localDate,
  bool forceRefresh = false,
}) async {
  final dashboardKey = _dashboardKey(userId, localDate);
  if (!forceRefresh) {
    final cached = _dashboardCache[dashboardKey];
    if (cached != null &&
        DateTime.now().difference(cached.timestamp) < _dashboardCacheTtl) {
      return cached.data;
    }
  }

  final apiUrl =
      dotenv.env['NEXT_PUBLIC_API_URL'] ?? dotenv.env['API_URL'] ?? '';
  final todayParam = _toUtcMidnightIsoFromLocalDay(localDate);

  final dailyRes = await http
      .get(
        Uri.parse('$apiUrl/daily?date=$todayParam&userId=$userId'),
        headers: _authHeaders(token),
      )
      .timeout(const Duration(seconds: 120));

  if (dailyRes.statusCode < 200 || dailyRes.statusCode >= 300) {
    throw Exception('Falha ao carregar diario (${dailyRes.statusCode})');
  }

  final daily = _extractMap(jsonDecode(dailyRes.body));
  if (daily == null) {
    final empty = NutritionDailyDashboard(
      summary: NutritionDailySummary(
        date: localDate,
        dailyLimit: 0,
        calories: 0,
        carbs: 0,
        proteins: 0,
        fat: 0,
        fibers: 0,
      ),
      meals: const [],
      dailyId: null,
    );
    _dashboardCache[dashboardKey] = _CachedDashboard(
      timestamp: DateTime.now(),
      data: empty,
    );
    return empty;
  }

  final dailyId = _toInt(daily['id']);
  final dailyLimit = _toDouble(daily['daily_limit']) ?? 0;
  final calories = _toDouble(daily['calorias_total']) ?? 0;
  double carbs = 0;
  double proteins = 0;
  double fat = 0;
  double fibers = 0;
  final meals = <MealDetails>[];

  if (dailyId != null) {
    final mealsRes = await http
        .get(
          Uri.parse('$apiUrl/meal/$userId/$dailyId'),
          headers: _authHeaders(token),
        )
        .timeout(const Duration(seconds: 120));

    if (mealsRes.statusCode >= 200 && mealsRes.statusCode < 300) {
      final mealsRaw = _extractList(jsonDecode(mealsRes.body));
      for (final meal in mealsRaw) {
        final mealId = _toInt(meal['id']);
        if (mealId == null) continue;

        final mealCarbs = _toDouble(meal['carboidratos_g']) ?? 0;
        final mealProteins = _toDouble(meal['proteinas_g']) ?? 0;
        final mealFat = _toDouble(meal['gorduras_g']) ?? 0;
        final mealFibers = _toDouble(meal['fibras_g']) ?? 0;
        final mealCalories = _toDouble(meal['calorias_kcal']) ?? 0;
        final mealSodium = _toDouble(meal['sodio_mg']) ?? 0;
        final mealPortion = (meal['porcao'] ?? '').toString();

        final itemsRes = await http
            .get(
              Uri.parse('$apiUrl/item/$userId/$mealId'),
              headers: _authHeaders(token),
            )
            .timeout(const Duration(seconds: 120));

        final itemModels = <MealItemDetails>[];
        if (itemsRes.statusCode >= 200 && itemsRes.statusCode < 300) {
          final itemsRaw = _extractList(jsonDecode(itemsRes.body));
          for (final item in itemsRaw) {
            itemModels.add(
              MealItemDetails(
                id: _toInt(item['id']) ?? 0,
                alimento: (item['alimento'] ?? '').toString(),
                porcao: (item['porcao'] ?? '').toString(),
                caloriasKcal: _toDouble(item['calorias_kcal']) ?? 0,
                carboidratosG: _toDouble(item['carboidratos_g']) ?? 0,
                proteinasG: _toDouble(item['proteinas_g']) ?? 0,
                gordurasG: _toDouble(item['gorduras_g']) ?? 0,
                fibrasG: _toDouble(item['fibras_g']) ?? 0,
                sodioMg: _toDouble(item['sodio_mg']) ?? 0,
                fonte: (item['fonte'] ?? '').toString(),
              ),
            );
          }
        }

        final mealHasMacros =
            mealCarbs > 0 || mealProteins > 0 || mealFat > 0 || mealFibers > 0;
        final sumCarbs = itemModels.fold<double>(
          0,
          (a, b) => a + b.carboidratosG,
        );
        final sumProteins = itemModels.fold<double>(
          0,
          (a, b) => a + b.proteinasG,
        );
        final sumFat = itemModels.fold<double>(0, (a, b) => a + b.gordurasG);
        final sumFibers = itemModels.fold<double>(0, (a, b) => a + b.fibrasG);
        final sumCalories = itemModels.fold<double>(
          0,
          (a, b) => a + b.caloriasKcal,
        );
        final sumSodium = itemModels.fold<double>(0, (a, b) => a + b.sodioMg);

        final finalCarbs = mealHasMacros ? mealCarbs : sumCarbs;
        final finalProteins = mealHasMacros ? mealProteins : sumProteins;
        final finalFat = mealHasMacros ? mealFat : sumFat;
        final finalFibers = mealHasMacros ? mealFibers : sumFibers;
        final finalCalories = mealCalories > 0 ? mealCalories : sumCalories;
        final finalSodium = mealSodium > 0 ? mealSodium : sumSodium;

        carbs += finalCarbs;
        proteins += finalProteins;
        fat += finalFat;
        fibers += finalFibers;

        meals.add(
          MealDetails(
            id: mealId,
            porcao: mealPortion,
            caloriasKcal: finalCalories,
            carboidratosG: finalCarbs,
            proteinasG: finalProteins,
            gordurasG: finalFat,
            fibrasG: finalFibers,
            sodioMg: finalSodium,
            itens: itemModels,
          ),
        );
      }
    }
  }

  final dashboard = NutritionDailyDashboard(
    summary: NutritionDailySummary(
      date: _toDate(daily['data']) ?? localDate,
      dailyLimit: dailyLimit,
      calories: calories,
      carbs: carbs,
      proteins: proteins,
      fat: fat,
      fibers: fibers,
    ),
    meals: meals,
    dailyId: dailyId,
  );

  _dashboardCache[dashboardKey] = _CachedDashboard(
    timestamp: DateTime.now(),
    data: dashboard,
  );

  return dashboard;
}

Future<List<DailyCalendarSummary>> getDailyCalendarSummaries({
  required int userId,
  required String token,
  bool forceRefresh = false,
}) async {
  final calendarKey = _calendarKey(userId);
  if (!forceRefresh) {
    final cached = _calendarCache[calendarKey];
    if (cached != null &&
        DateTime.now().difference(cached.timestamp) < _calendarCacheTtl) {
      return cached.data;
    }
  }

  final apiUrl =
      dotenv.env['NEXT_PUBLIC_API_URL'] ?? dotenv.env['API_URL'] ?? '';
  final response = await http
      .get(
        Uri.parse('$apiUrl/daily/$userId'),
        headers: _authHeaders(token),
      )
      .timeout(const Duration(seconds: 120));

  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw Exception(
      'Falha ao carregar lista de diarios (${response.statusCode}): ${response.body}',
    );
  }

  final parsed = jsonDecode(response.body);
  final list = _extractList(parsed);
  final summaries = list
      .map((e) {
        final date = _toDate(e['data']);
        if (date == null) return null;
        return DailyCalendarSummary(
          date: date.toLocal(),
          dailyLimit: _toDouble(e['daily_limit']) ?? 0,
          calories: _toDouble(e['calorias_total']) ?? 0,
        );
      })
      .whereType<DailyCalendarSummary>()
      .toList();

  _calendarCache[calendarKey] = _CachedCalendar(
    timestamp: DateTime.now(),
    data: summaries,
  );

  return summaries;
}

Future<void> deleteMealById({
  required int userId,
  required int mealId,
  required String token,
}) async {
  final apiUrl =
      dotenv.env['NEXT_PUBLIC_API_URL'] ?? dotenv.env['API_URL'] ?? '';
  final response = await http
      .delete(
        Uri.parse('$apiUrl/meal/$userId/$mealId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      )
      .timeout(const Duration(seconds: 120));

  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw Exception(
      'Falha ao deletar refeicao (${response.statusCode}): ${response.body}',
    );
  }

  clearNutritionRequestCaches(userId: userId);
}

void clearNutritionRequestCaches({int? userId}) {
  if (userId == null) {
    _dashboardCache.clear();
    _calendarCache.clear();
    return;
  }
  _dashboardCache.removeWhere(
    (key, _) => key.startsWith('dashboard_${userId}_'),
  );
  _calendarCache.remove(_calendarKey(userId));
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

String _calendarKey(int userId) => 'calendar_$userId';

String _dashboardKey(int userId, DateTime localDate) {
  final y = localDate.year.toString().padLeft(4, '0');
  final m = localDate.month.toString().padLeft(2, '0');
  final d = localDate.day.toString().padLeft(2, '0');
  return 'dashboard_${userId}_$y$m$d';
}
