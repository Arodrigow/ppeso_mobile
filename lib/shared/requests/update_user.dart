import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:ppeso_mobile/features/profile/models/user.dart';

Future<bool> updateUser({
  required User user,
  required String token
}) async {
  final url = Uri.parse("${dotenv.env['API_URL']}/user/${user.id}");
  final body = jsonEncode(user.toJson());

  try {
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: body,
    );

    if (response.statusCode == 200) {
      // Success
      return true;
    } else {
      print("Failed to update user: ${response.statusCode} - ${response.body}");
      return false;
    }
  } catch (e) {
    print("Error updating user: $e");
    return false;
  }
}
