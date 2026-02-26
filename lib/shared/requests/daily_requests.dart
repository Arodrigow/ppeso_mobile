import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<Map<String, dynamic>?> getTodayDaily({
  required int userId,
  required String token,
}) async {
  final apiUrl =
      dotenv.env['NEXT_PUBLIC_API_URL'] ?? dotenv.env['API_URL'] ?? '';
  final dateIsoUtc = _utcMidnightIsoFromLocalDay(DateTime.now());

  final response = await http
      .get(
        Uri.parse('$apiUrl/daily?date=$dateIsoUtc&userId=$userId'),
        headers: _authHeaders(token),
      )
      .timeout(const Duration(seconds: 120));

  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw Exception(
      'Failed to load daily (${response.statusCode}): ${response.body}',
    );
  }

  final parsed = jsonDecode(response.body);
  if (parsed is Map<String, dynamic>) return parsed;
  if (parsed is List &&
      parsed.isNotEmpty &&
      parsed.first is Map<String, dynamic>) {
    return parsed.first as Map<String, dynamic>;
  }
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
  final dateIsoUtc = _utcMidnightIsoFromLocalDay(DateTime.now());

  final createRes = await http
      .post(
        Uri.parse('$apiUrl/daily'),
        headers: _authHeaders(token),
        body: jsonEncode({
          'data': {'date': dateIsoUtc, 'userId': userId},
        }),
      )
      .timeout(const Duration(seconds: 120));

  if (createRes.statusCode < 200 || createRes.statusCode >= 300) {
    throw Exception(
      'Failed to create daily (${createRes.statusCode}): ${createRes.body}',
    );
  }

  await prefs.setString(persistedKey, localDayKey);
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
