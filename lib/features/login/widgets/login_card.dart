import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:ppeso_mobile/core/styles.dart';
import 'package:ppeso_mobile/shared/content.dart';

class LoginCard extends StatelessWidget {
  const LoginCard({super.key});

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
                  width: 150,
                  height: 150,
                ),
                const Text("PPESO", style: AppTextStyles.ppesoTitle),
              ],
            ),
            TextFormField(
              decoration: InputDecoration(
                labelText: LoginText.email,
                enabledBorder: TextInputStyles.enabledDefault,
                focusedBorder: TextInputStyles.focusDefault,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: LoginText.password,
                enabledBorder: TextInputStyles.enabledDefault,
                focusedBorder: TextInputStyles.focusDefault,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                     context.replace('/profile');
                  },
                  style: ButtonStyles.defaultAcceptButton,
                  child: const Text(LoginText.loginButton),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Handle login logic here
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
