import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:ppeso_mobile/core/styles.dart';
import 'package:ppeso_mobile/providers/user_provider.dart';
import 'package:ppeso_mobile/shared/content.dart';

class LoginCard extends ConsumerStatefulWidget  {
  const LoginCard({super.key});

  @override
  ConsumerState<LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends ConsumerState<LoginCard> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final storage = FlutterSecureStorage();

  void _login() async {
    final email = emailController.text;
    final password = passwordController.text;

    if (email == "" || password == "") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid email or password"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final apiUrl = dotenv.env['API_URL'] ?? "https://fallback-url.com";
      final recaptchCode = dotenv.env['RECAPTCHA_SECRET'] ?? "";
      final response = await http.post(
        Uri.parse("$apiUrl/auth/login"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'captchaToken': recaptchCode,
        }),
      );
      if (!mounted) return;

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final token = data['access_token'];
        final user = data['user'];

        await saveSession(ref, token, user);

        if (!mounted) return;
        context.replace('/profile');
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Login failed: ${response.body}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(30),
      color: AppColors.widgetBackground,
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  "assets/svg/svg_base.svg",
                  width: 90,
                  height: 90,
                ),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text("PPESO", style: AppTextStyles.ppesoTitle),
                  ),
                ),
              ],
            ),
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: UserTextFields.email,
                enabledBorder: TextInputStyles.enabledDefault,
                focusedBorder: TextInputStyles.focusDefault,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              obscureText: true,
              controller: passwordController,
              decoration: InputDecoration(
                labelText: UserTextFields.password,
                enabledBorder: TextInputStyles.enabledDefault,
                focusedBorder: TextInputStyles.focusDefault,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: _login,
                  style: ButtonStyles.defaultAcceptButton,
                  child: const Text(LoginText.loginButton),
                ),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Add registration page
                  },
                  child: const Text(LoginText.registerButton),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
