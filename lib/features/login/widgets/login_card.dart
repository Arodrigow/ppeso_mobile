import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:ppeso_mobile/core/styles.dart';
import 'package:ppeso_mobile/shared/content.dart';

class LoginCard extends StatefulWidget {
  const LoginCard({super.key});

  @override
  State<LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends State<LoginCard> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _login() {
    // final email = emailController.text;
    // final password = passwordController.text;

    // if (email != "" || password != "") {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text("Invalid email or password"),
    //       backgroundColor: Colors.red,
    //     ),
    //   );
    //   return;
    // }

    context.replace('/profile');
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
                  width: 100,
                  height: 100,
                ),
                const Text("PPESO", style: AppTextStyles.ppesoTitle),
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
