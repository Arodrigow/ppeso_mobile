//Token Provider
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _secureStorage = const FlutterSecureStorage();

final authTokenProvider = StateProvider<String?>((ref) => null);

// User Profile Provider (JSON mapping)
final userProvider = StateProvider<Map<String, dynamic>?>((ref) => null);

//Preferences naming
final String authToken = 'auth_token';
final String userProfile = 'user_profile';

// Helper to load saved session
Future<void> loadSession(WidgetRef ref) async {
  final prefs = await SharedPreferences.getInstance();

  final token = await _secureStorage.read(key: authToken);
  final userJson = prefs.getString(userProfile);

  if (token != null) {
    ref.read(authTokenProvider.notifier).state = token;
  }

  if (userJson != null) {
    ref.read(userProvider.notifier).state = jsonDecode(userJson);
  }
}

// Save Session
Future<void> saveSession(
  WidgetRef ref,
  String token,
  Map<String, dynamic> user,
) async {
  final prefs = await SharedPreferences.getInstance();

  await _secureStorage.write(key: authToken, value: token);
  await prefs.setString(userProfile, jsonEncode(user));

  ref.read(authTokenProvider.notifier).state = token;
  ref.read(userProvider.notifier).state = user;
}

// Clear Session
Future<void> clearSession(WidgetRef ref) async {
  final prefs = await SharedPreferences.getInstance();

  await _secureStorage.delete(key: authToken);
  await prefs.remove(userProfile);

  ref.read(authTokenProvider.notifier).state = null;
  ref.read(userProvider.notifier).state = null;
}
