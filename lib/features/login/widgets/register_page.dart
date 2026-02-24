import 'package:flutter/material.dart';
import 'package:ppeso_mobile/core/styles.dart';
import 'package:ppeso_mobile/features/login/widgets/register_card.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: const RegisterCard(),
          ),
        ),
      ),
    );
  }
}
