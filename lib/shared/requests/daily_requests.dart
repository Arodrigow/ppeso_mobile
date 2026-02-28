import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const Duration _todayDailyCacheTtl = Duration(seconds: 30);
final Map<String, _CachedDaily> _todayDailyCache = {};

class _CachedDaily {
  final DateTime timestamp;
  final Map<String, dynamic>? data;

  const _CachedDaily({required this.timestamp, required this.data});
}

Future<Map<String, dynamic>?> getTodayDaily({
  required int userId,
  required String token,
  bool forceRefresh = false,
}) async {
  final cacheKey = _todayDailyKey(userId, DateTime.now());
  if (!forceRefresh) {
    final cached = _todayDailyCache[cacheKey];
    if (cached != null &&
        DateTime.now().difference(cached.timestamp) < _todayDailyCacheTtl) {
      return cached.data;
    }

    final diskCached = await _readTodayDailyFromDisk(userId);
    if (diskCached != null) {
      _todayDailyCache[cacheKey] = diskCached;
      return diskCached.data;
    }
  }

  final apiUrl =
      dotenv.env['NEXT_PUBLIC_API_URL'] ?? dotenv.env['API_URL'] ?? '';
  final localDay = _localDayKey(DateTime.now());
  final dateIsoUtc = _utcMidnightIsoFromLocalDay(DateTime.now());

  final response = await _getDailyWithDate(
    apiUrl: apiUrl,
    token: token,
    userId: userId,
    dateParam: localDay,
  );
  final resolvedResponse =
      (response.statusCode >= 200 && response.statusCode < 300)
      ? response
      : await _getDailyWithDate(
          apiUrl: apiUrl,
          token: token,
          userId: userId,
          dateParam: dateIsoUtc,
        );

  if (resolvedResponse.statusCode < 200 || resolvedResponse.statusCode >= 300) {
    throw Exception(
      'Failed to load daily (${resolvedResponse.statusCode}): ${resolvedResponse.body}',
    );
  }

  final parsed = jsonDecode(resolvedResponse.body);
  if (parsed is Map<String, dynamic>) {
    _todayDailyCache[cacheKey] = _CachedDaily(
      timestamp: DateTime.now(),
      data: parsed,
    );
    await _saveTodayDailyToDisk(userId, parsed);
    return parsed;
  }
  if (parsed is List &&
      parsed.isNotEmpty &&
      parsed.first is Map<String, dynamic>) {
    final mapped = parsed.first as Map<String, dynamic>;
    _todayDailyCache[cacheKey] = _CachedDaily(
      timestamp: DateTime.now(),
      data: mapped,
    );
    await _saveTodayDailyToDisk(userId, mapped);
    return mapped;
  }
  _todayDailyCache[cacheKey] = _CachedDaily(
    timestamp: DateTime.now(),
    data: null,
  );
  await _saveTodayDailyToDisk(userId, null);
  return null;
}

Future<void> ensureDailyForToday({
  required int userId,
  required String token,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final localDayKey = _localDayKey(DateTime.now());
  final persistedKey = 'daily_ensured_$userId';
  final alreadyEnsured = prefs.getString(persistedKey);
  if (alreadyEnsured == localDayKey) {
    return;
  }

  final existing = await getTodayDaily(userId: userId, token: token);
  if (existing != null) {
    await prefs.setString(persistedKey, localDayKey);
    return;
  }

  final apiUrl =
      dotenv.env['NEXT_PUBLIC_API_URL'] ?? dotenv.env['API_URL'] ?? '';
  final localDay = _localDayKey(DateTime.now());
  final dateIsoUtc = _utcMidnightIsoFromLocalDay(DateTime.now());

  final createRes = await _createDailyWithFallback(
    apiUrl: apiUrl,
    token: token,
    userId: userId,
    localDay: localDay,
    dateIsoUtc: dateIsoUtc,
  );

  if (createRes.statusCode < 200 || createRes.statusCode >= 300) {
    throw Exception(
      'Failed to create daily (${createRes.statusCode}): ${createRes.body}',
    );
  }

  await prefs.setString(persistedKey, localDayKey);
  _todayDailyCache.remove(_todayDailyKey(userId, DateTime.now()));
  await prefs.remove(_todayDailyDiskKey(userId, DateTime.now()));
}

Future<http.Response> _getDailyWithDate({
  required String apiUrl,
  required String token,
  required int userId,
  required String dateParam,
}) async {
  return http
      .get(
        Uri.parse('$apiUrl/daily?date=$dateParam&userId=$userId'),
        headers: _authHeaders(token),
      )
      .timeout(const Duration(seconds: 120));
}

Future<http.Response> _createDailyWithFallback({
  required String apiUrl,
  required String token,
  required int userId,
  required String localDay,
  required String dateIsoUtc,
}) async {
  final localDayEndOfDay = '$localDay 23:59:59';
  final attempts = <_DailyCreateAttempt>[
    _DailyCreateAttempt(
      url: '$apiUrl/daily',
      body: {
        'data': {'date': localDayEndOfDay, 'userId': userId},
      },
    ),
    _DailyCreateAttempt(
      url: '$apiUrl/daily',
      body: {
        'data': {'date': localDay, 'userId': userId},
      },
    ),
    _DailyCreateAttempt(
      url: '$apiUrl/daily',
      body: {
        'data': {'date': dateIsoUtc, 'userId': userId},
      },
    ),
    _DailyCreateAttempt(
      url: '$apiUrl/daily',
      body: {'date': localDay, 'userId': userId},
    ),
    _DailyCreateAttempt(
      url: '$apiUrl/daily',
      body: {'date': dateIsoUtc, 'userId': userId},
    ),
    _DailyCreateAttempt(
      url: '$apiUrl/daily',
      body: {
        'data': {'date': localDay},
      },
    ),
    _DailyCreateAttempt(
      url: '$apiUrl/daily',
      body: {'date': localDay},
    ),
  ];

  http.Response? lastResponse;
  for (final attempt in attempts) {
    final response = await http
        .post(
          Uri.parse(attempt.url),
          headers: _authHeaders(token),
          body: jsonEncode(attempt.body),
        )
        .timeout(const Duration(seconds: 120));
    lastResponse = response;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    }
  }

  return lastResponse ??
      http.Response('Daily create not attempted', 500);
}

Map<String, String> _authHeaders(String token) => {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  'Authorization': 'Bearer $token',
};

String _localDayKey(DateTime localDate) {
  final y = localDate.year.toString().padLeft(4, '0');
  final m = localDate.month.toString().padLeft(2, '0');
  final d = localDate.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

String _utcMidnightIsoFromLocalDay(DateTime localDate) {
  final utcMidnight = DateTime.utc(
    localDate.year,
    localDate.month,
    localDate.day,
  );
  return utcMidnight.toIso8601String();
}

String _todayDailyKey(int userId, DateTime localDate) {
  final y = localDate.year.toString().padLeft(4, '0');
  final m = localDate.month.toString().padLeft(2, '0');
  final d = localDate.day.toString().padLeft(2, '0');
  return 'today_daily_${userId}_$y$m$d';
}

String _todayDailyDiskKey(int userId, DateTime localDate) {
  final y = localDate.year.toString().padLeft(4, '0');
  final m = localDate.month.toString().padLeft(2, '0');
  final d = localDate.day.toString().padLeft(2, '0');
  return 'cache_today_daily_${userId}_$y$m$d';
}

Future<_CachedDaily?> _readTodayDailyFromDisk(int userId) async {
  final prefs = await SharedPreferences.getInstance();
  final key = _todayDailyDiskKey(userId, DateTime.now());
  final raw = prefs.getString(key);
  if (raw == null || raw.isEmpty) return null;

  final decoded = jsonDecode(raw);
  if (decoded is! Map<String, dynamic>) return null;
  final tsRaw = decoded['timestamp'];
  if (tsRaw is! String) return null;
  final timestamp = DateTime.tryParse(tsRaw);
  if (timestamp == null) return null;
  if (DateTime.now().difference(timestamp) >= _todayDailyCacheTtl) return null;

  final data = decoded['data'];
  if (data == null) {
    return _CachedDaily(timestamp: timestamp, data: null);
  }
  if (data is Map<String, dynamic>) {
    return _CachedDaily(timestamp: timestamp, data: data);
  }
  return null;
}

Future<void> _saveTodayDailyToDisk(int userId, Map<String, dynamic>? data) async {
  final prefs = await SharedPreferences.getInstance();
  final key = _todayDailyDiskKey(userId, DateTime.now());
  final payload = {
    'timestamp': DateTime.now().toIso8601String(),
    'data': data,
  };
  await prefs.setString(key, jsonEncode(payload));
}

class _DailyCreateAttempt {
  final String url;
  final Map<String, dynamic> body;

  const _DailyCreateAttempt({required this.url, required this.body});
}
