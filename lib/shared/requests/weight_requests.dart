import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:ppeso_mobile/features/profile/models/date_model.dart';

Future<List<DateModel>> getWeightHistory({
  required int userId,
  required String token,
}) async {
  final apiUrl =
      dotenv.env['NEXT_PUBLIC_API_URL'] ?? dotenv.env['API_URL'] ?? '';
  final response = await http.get(
    Uri.parse('$apiUrl/peso/$userId'),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw Exception('Failed to load weights (${response.statusCode})');
  }

  final body = jsonDecode(response.body);
  if (body is! List) {
    return [];
  }

  final result = <DateModel>[];
  for (final item in body) {
    if (item is! Map<String, dynamic>) continue;
    final parsed = _parseWeight(item);
    if (parsed != null) result.add(parsed);
  }

  return result;
}

Future<void> createWeight({
  required int userId,
  required String token,
  required double weight,
  required DateTime date,
}) async {
  final apiUrl =
      dotenv.env['NEXT_PUBLIC_API_URL'] ?? dotenv.env['API_URL'] ?? '';
  final response = await http
      .post(
        Uri.parse('$apiUrl/peso/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'peso': weight,
          'data': _toIsoDate(date),
          'user': {
            'connect': {'id': userId},
          },
        }),
      )
      .timeout(const Duration(seconds: 12));

  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw Exception(
      'Failed to create weight (${response.statusCode}): ${response.body}',
    );
  }
}

Future<void> deleteWeight({
  required int userId,
  required int weightId,
  required String token,
}) async {
  final apiUrl =
      dotenv.env['NEXT_PUBLIC_API_URL'] ?? dotenv.env['API_URL'] ?? '';
  final response = await http
      .delete(
        Uri.parse('$apiUrl/peso/$userId/$weightId'),
        headers: {
          'Authorization': 'Bearer $token',
        }
      )
      .timeout(const Duration(seconds: 12));

  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw Exception(
      'Failed to delete weight (${response.statusCode}): ${response.body}',
    );
  }
}

DateModel? _parseWeight(Map<String, dynamic> json) {
  final id = _toInt(json['id'] ?? json['peso_id']);
  final weight = _toDouble(
    json['peso'] ?? json['weight'] ?? json['value'] ?? json['peso_now'],
  );
  if (weight == null) return null;

  final dateRaw =
      json['date'] ?? json['data'] ?? json['created_at'] ?? json['updated_at'];
  final date = _toDate(dateRaw) ?? DateTime.now();

  return DateModel(id: id, date: date, weight: weight);
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
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

String _toIsoDate(DateTime date) {
  final utcMidnight = DateTime.utc(date.year, date.month, date.day);
  final iso = utcMidnight.toIso8601String();
  return iso.endsWith('Z') ? iso : '${iso}Z';
}
