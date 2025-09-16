import 'package:flutter/material.dart';
import 'package:ppeso_mobile/core/styles.dart';
import 'package:ppeso_mobile/shared/content.dart';
import 'package:ppeso_mobile/shared/tab_structure.dart';

class RegisterMealTab extends StatelessWidget {
  const RegisterMealTab({super.key});

  @override
  Widget build(BuildContext context) {
    return TabStructure(
      children: [
        Text(MealPageText.registerMealTitle, style: AppTextStyles.title),
        const SizedBox(height: 20),
      ],
    );
  }
}