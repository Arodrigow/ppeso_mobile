import 'package:flutter/material.dart';
import 'package:ppeso_mobile/core/styles.dart';
import 'package:ppeso_mobile/shared/content.dart';

class HealthTab extends StatefulWidget {
  const HealthTab({super.key});

  @override
  State<HealthTab> createState() => _HealthTabState();
}

class _HealthTabState extends State<HealthTab> {
  ExerciseLevel? _selectedExerciseLevel = ExerciseLevel.leve;
  CalorieStrat? _selectedCalRegime = CalorieStrat.extremo;
  String? selectedObjective;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Card(
                      margin: const EdgeInsets.all(30),
                      color: AppColors.widgetBackground,
                      child: Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            //Raiogroup - Exercise Level
                            Text(UserTextFields.activityLevel, style: AppTextStyles.subTitle),
                            RadioGroup<ExerciseLevel>(
                              groupValue: _selectedExerciseLevel,
                              onChanged: (ExerciseLevel? value) {
                                setState(() {
                                  _selectedExerciseLevel = value;
                                });
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (final level in ExerciseLevel.values)
                                    RadioListTile(
                                      value: level,
                                      title: Text(
                                        level.title,
                                        style: AppTextStyles.bodyBold,
                                      ),
                                      subtitle: Text(
                                        level.description,
                                        style: AppTextStyles.description,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10,),
                            const Divider(
                              color: AppColors.primary,
                              thickness: 1,
                              indent: 16,
                              endIndent: 16,
                            ),
                            const SizedBox(height: 10,),
                            Text(UserTextFields.colorieTiTle, style: AppTextStyles.subTitle),
                            //Raiogroup - Exercise Level
                            RadioGroup<CalorieStrat>(
                              groupValue: _selectedCalRegime,
                              onChanged: (CalorieStrat? value) {
                                setState(() {
                                  _selectedCalRegime = value;
                                });
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (final calories in CalorieStrat.values)
                                    RadioListTile(
                                      value: calories,
                                      title: Text(calories.title, style: AppTextStyles.bodyBold,),
                                      subtitle: Text(calories.description, style: AppTextStyles.description),
                                      )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
