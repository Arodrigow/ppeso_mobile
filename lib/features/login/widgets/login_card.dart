import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:ppeso_mobile/core/styles.dart';
import 'package:ppeso_mobile/providers/user_provider.dart';
import 'package:ppeso_mobile/shared/content.dart';
import 'package:ppeso_mobile/shared/loading_message.dart';

class LoginCard extends ConsumerStatefulWidget {
  const LoginCard({super.key});

  @override
  ConsumerState<LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends ConsumerState<LoginCard> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid email or password'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final apiUrl = dotenv.env['API_URL'] ?? '';
      final captchaToken = dotenv.env['CAPTCHA_TOKEN'] ?? 'mobile-client';

      final response = await withLoading(
        context,
        () => http.post(
          Uri.parse('$apiUrl/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': email,
            'password': password,
            'captchaToken': captchaToken,
          }),
        ),
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final token = data['access_token'] ?? data['token'];
        final user = data['user'];

        if (token is! String || user is! Map<String, dynamic>) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid login response from server.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        await saveSession(ref, token, user);
        if (!mounted) return;
        context.replace('/profile');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${response.body} STATUS: ${response.statusCode} BODY: ${response.body}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(30),
      color: AppColors.widgetBackground,
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/svg/svg_base.svg',
                  width: 90,
                  height: 90,
                ),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('PPESO', style: AppTextStyles.ppesoTitle),
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
                  onPressed: () => context.push('/register'),
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
