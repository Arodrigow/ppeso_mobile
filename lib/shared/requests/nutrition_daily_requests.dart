import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

    final diskCached = await _readDashboardFromDisk(userId, localDate);
    if (diskCached != null) {
      _dashboardCache[dashboardKey] = diskCached;
      return diskCached.data;
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
    await _saveDashboardToDisk(userId, localDate, empty);
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
  await _saveDashboardToDisk(userId, localDate, dashboard);

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

    final diskCached = await _readCalendarFromDisk(userId);
    if (diskCached != null) {
      _calendarCache[calendarKey] = diskCached;
      return diskCached.data;
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
  await _saveCalendarToDisk(userId, summaries);

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
    _clearAllNutritionDiskCaches();
    return;
  }
  _dashboardCache.removeWhere(
    (key, _) => key.startsWith('dashboard_${userId}_'),
  );
  _calendarCache.remove(_calendarKey(userId));
  _clearUserNutritionDiskCaches(userId);
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

String _dashboardDiskKey(int userId, DateTime localDate) {
  final y = localDate.year.toString().padLeft(4, '0');
  final m = localDate.month.toString().padLeft(2, '0');
  final d = localDate.day.toString().padLeft(2, '0');
  return 'cache_dashboard_${userId}_$y$m$d';
}

String _calendarDiskKey(int userId) => 'cache_calendar_$userId';

Future<_CachedDashboard?> _readDashboardFromDisk(
  int userId,
  DateTime localDate,
) async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_dashboardDiskKey(userId, localDate));
  if (raw == null || raw.isEmpty) return null;

  final decoded = jsonDecode(raw);
  if (decoded is! Map<String, dynamic>) return null;
  final tsRaw = decoded['timestamp'];
  final dataRaw = decoded['data'];
  if (tsRaw is! String || dataRaw is! Map<String, dynamic>) return null;

  final timestamp = DateTime.tryParse(tsRaw);
  if (timestamp == null) return null;
  if (DateTime.now().difference(timestamp) >= _dashboardCacheTtl) return null;

  final dashboard = _dashboardFromJson(dataRaw);
  if (dashboard == null) return null;
  return _CachedDashboard(timestamp: timestamp, data: dashboard);
}

Future<void> _saveDashboardToDisk(
  int userId,
  DateTime localDate,
  NutritionDailyDashboard dashboard,
) async {
  final prefs = await SharedPreferences.getInstance();
  final payload = {
    'timestamp': DateTime.now().toIso8601String(),
    'data': _dashboardToJson(dashboard),
  };
  await prefs.setString(
    _dashboardDiskKey(userId, localDate),
    jsonEncode(payload),
  );
}

Future<_CachedCalendar?> _readCalendarFromDisk(int userId) async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_calendarDiskKey(userId));
  if (raw == null || raw.isEmpty) return null;

  final decoded = jsonDecode(raw);
  if (decoded is! Map<String, dynamic>) return null;
  final tsRaw = decoded['timestamp'];
  final dataRaw = decoded['data'];
  if (tsRaw is! String || dataRaw is! List) return null;

  final timestamp = DateTime.tryParse(tsRaw);
  if (timestamp == null) return null;
  if (DateTime.now().difference(timestamp) >= _calendarCacheTtl) return null;

  final data = dataRaw.whereType<Map<String, dynamic>>().map((e) {
    final date = _toDate(e['date']);
    if (date == null) return null;
    return DailyCalendarSummary(
      date: date,
      dailyLimit: _toDouble(e['dailyLimit']) ?? 0,
      calories: _toDouble(e['calories']) ?? 0,
    );
  }).whereType<DailyCalendarSummary>().toList();

  return _CachedCalendar(timestamp: timestamp, data: data);
}

Future<void> _saveCalendarToDisk(
  int userId,
  List<DailyCalendarSummary> summaries,
) async {
  final prefs = await SharedPreferences.getInstance();
  final payload = {
    'timestamp': DateTime.now().toIso8601String(),
    'data': summaries
        .map(
          (s) => {
            'date': s.date.toIso8601String(),
            'dailyLimit': s.dailyLimit,
            'calories': s.calories,
          },
        )
        .toList(),
  };
  await prefs.setString(_calendarDiskKey(userId), jsonEncode(payload));
}

Map<String, dynamic> _dashboardToJson(NutritionDailyDashboard dashboard) {
  return {
    'summary': {
      'date': dashboard.summary.date.toIso8601String(),
      'dailyLimit': dashboard.summary.dailyLimit,
      'calories': dashboard.summary.calories,
      'carbs': dashboard.summary.carbs,
      'proteins': dashboard.summary.proteins,
      'fat': dashboard.summary.fat,
      'fibers': dashboard.summary.fibers,
    },
    'dailyId': dashboard.dailyId,
    'meals': dashboard.meals
        .map(
          (meal) => {
            'id': meal.id,
            'porcao': meal.porcao,
            'caloriasKcal': meal.caloriasKcal,
            'carboidratosG': meal.carboidratosG,
            'proteinasG': meal.proteinasG,
            'gordurasG': meal.gordurasG,
            'fibrasG': meal.fibrasG,
            'sodioMg': meal.sodioMg,
            'itens': meal.itens
                .map(
                  (item) => {
                    'id': item.id,
                    'alimento': item.alimento,
                    'porcao': item.porcao,
                    'caloriasKcal': item.caloriasKcal,
                    'carboidratosG': item.carboidratosG,
                    'proteinasG': item.proteinasG,
                    'gordurasG': item.gordurasG,
                    'fibrasG': item.fibrasG,
                    'sodioMg': item.sodioMg,
                    'fonte': item.fonte,
                  },
                )
                .toList(),
          },
        )
        .toList(),
  };
}

NutritionDailyDashboard? _dashboardFromJson(Map<String, dynamic> json) {
  final summaryRaw = json['summary'];
  if (summaryRaw is! Map<String, dynamic>) return null;
  final date = _toDate(summaryRaw['date']);
  if (date == null) return null;

  final mealsRaw = json['meals'];
  final meals = <MealDetails>[];
  if (mealsRaw is List) {
    for (final mealRaw in mealsRaw.whereType<Map<String, dynamic>>()) {
      final mealId = _toInt(mealRaw['id']) ?? 0;
      final itens = <MealItemDetails>[];
      final itensRaw = mealRaw['itens'];
      if (itensRaw is List) {
        for (final itemRaw in itensRaw.whereType<Map<String, dynamic>>()) {
          itens.add(
            MealItemDetails(
              id: _toInt(itemRaw['id']) ?? 0,
              alimento: (itemRaw['alimento'] ?? '').toString(),
              porcao: (itemRaw['porcao'] ?? '').toString(),
              caloriasKcal: _toDouble(itemRaw['caloriasKcal']) ?? 0,
              carboidratosG: _toDouble(itemRaw['carboidratosG']) ?? 0,
              proteinasG: _toDouble(itemRaw['proteinasG']) ?? 0,
              gordurasG: _toDouble(itemRaw['gordurasG']) ?? 0,
              fibrasG: _toDouble(itemRaw['fibrasG']) ?? 0,
              sodioMg: _toDouble(itemRaw['sodioMg']) ?? 0,
              fonte: (itemRaw['fonte'] ?? '').toString(),
            ),
          );
        }
      }

      meals.add(
        MealDetails(
          id: mealId,
          porcao: (mealRaw['porcao'] ?? '').toString(),
          caloriasKcal: _toDouble(mealRaw['caloriasKcal']) ?? 0,
          carboidratosG: _toDouble(mealRaw['carboidratosG']) ?? 0,
          proteinasG: _toDouble(mealRaw['proteinasG']) ?? 0,
          gordurasG: _toDouble(mealRaw['gordurasG']) ?? 0,
          fibrasG: _toDouble(mealRaw['fibrasG']) ?? 0,
          sodioMg: _toDouble(mealRaw['sodioMg']) ?? 0,
          itens: itens,
        ),
      );
    }
  }

  return NutritionDailyDashboard(
    summary: NutritionDailySummary(
      date: date,
      dailyLimit: _toDouble(summaryRaw['dailyLimit']) ?? 0,
      calories: _toDouble(summaryRaw['calories']) ?? 0,
      carbs: _toDouble(summaryRaw['carbs']) ?? 0,
      proteins: _toDouble(summaryRaw['proteins']) ?? 0,
      fat: _toDouble(summaryRaw['fat']) ?? 0,
      fibers: _toDouble(summaryRaw['fibers']) ?? 0,
    ),
    meals: meals,
    dailyId: _toInt(json['dailyId']),
  );
}

void _clearUserNutritionDiskCaches(int userId) {
  SharedPreferences.getInstance().then((prefs) {
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith('cache_dashboard_${userId}_') ||
          key == _calendarDiskKey(userId)) {
        prefs.remove(key);
      }
    }
  });
}

void _clearAllNutritionDiskCaches() {
  SharedPreferences.getInstance().then((prefs) {
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith('cache_dashboard_') || key.startsWith('cache_calendar_')) {
        prefs.remove(key);
      }
    }
  });
}

String _calendarKey(int userId) => 'calendar_$userId';

String _dashboardKey(int userId, DateTime localDate) {
  final y = localDate.year.toString().padLeft(4, '0');
  final m = localDate.month.toString().padLeft(2, '0');
  final d = localDate.day.toString().padLeft(2, '0');
  return 'dashboard_${userId}_$y$m$d';
}
