import 'package:flutter/material.dart';
import 'package:ppeso_mobile/core/styles.dart';
import 'package:ppeso_mobile/features/meal/widgets/new_meal_form.dart';
import 'package:ppeso_mobile/shared/content.dart';
import 'package:ppeso_mobile/shared/tab_structure.dart';

class NewMealTab extends StatefulWidget {
  final String? initialFirstItem;

  const NewMealTab({super.key, this.initialFirstItem});

  @override
  State<NewMealTab> createState() => _NewMealTabState();
}

class _NewMealTabState extends State<NewMealTab> {
  @override
  Widget build(BuildContext context) {
    return TabStructure(
      children: [
        Text(MealPageText.newMealTitle, style: AppTextStyles.title),
        const SizedBox(height: 20),
        MealForm(initialFirstItem: widget.initialFirstItem),
      ],
    );
  }
}
