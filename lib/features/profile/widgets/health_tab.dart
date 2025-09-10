import 'package:flutter/material.dart';
import 'package:ppeso_mobile/core/styles.dart';
import 'package:ppeso_mobile/features/profile/models/daily_value.dart';
import 'package:ppeso_mobile/features/profile/widgets/custom_modal.dart';
import 'package:ppeso_mobile/features/profile/widgets/weekly_grid.dart';
import 'package:ppeso_mobile/shared/content.dart';
import 'package:ppeso_mobile/shared/divider.dart';
import 'package:ppeso_mobile/shared/tab_structure.dart';

class HealthTab extends StatefulWidget {
  const HealthTab({super.key});

  @override
  State<HealthTab> createState() => _HealthTabState();
}

class _HealthTabState extends State<HealthTab> {
  ExerciseLevel? _selectedExerciseLevel = ExerciseLevel.leve;
  CalorieStrat? _selectedCalRegime = CalorieStrat.extremo;
  Strategy? _selectedStrategy = Strategy.zigZag2;

  final weeklyValue = 20000;
  final daysOfWeek = [
    DailyValue(label: "Seg", value: 120),
    DailyValue(label: "Ter", value: 90),
    DailyValue(label: "Qua", value: 150),
    DailyValue(label: "Qui", value: 80),
    DailyValue(label: "Sex", value: 200),
    DailyValue(label: "Sáb", value: 130),
    DailyValue(label: "Dom", value: 170),
  ];

  @override
  Widget build(BuildContext context) {
    return TabStructure(
      children: [
        Text("Estratégia", style: AppTextStyles.title),
        //Row - Exercise Level
        const SizedBox(height: 20),
        Row(
          children: [
            Text(UserTextFields.activityLevel, style: AppTextStyles.bodyBold),
            const SizedBox(width: 15),
            ElevatedButton(
              onPressed: () {
                CustomModal.bottomSheet(
                  context,
                  child: StatefulBuilder(
                    builder: (context, setModalExerciseState) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            ModalText.chooseOption,
                            style: TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 20),
                          RadioGroup<ExerciseLevel>(
                            groupValue: _selectedExerciseLevel,
                            onChanged: (ExerciseLevel? value) {
                              setState(() {
                                _selectedExerciseLevel = value;
                                Navigator.pop(context);
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
                        ],
                      );
                    },
                  ),
                );
              },
              child: Row(
                children: [
                  Text("${_selectedExerciseLevel?.title}"),
                  const SizedBox(width: 8),
                  Icon(Icons.edit, color: AppColors.primary),
                ],
              ),
            ),
          ],
        ),
        //Row - Calorie Regime
        Row(
          children: [
            Text(UserTextFields.colorieTiTle, style: AppTextStyles.bodyBold),
            const SizedBox(width: 15),
            ElevatedButton(
              onPressed: () {
                CustomModal.bottomSheet(
                  context,
                  child: StatefulBuilder(
                    builder: (context, setModalColorieState) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            ModalText.chooseOption,
                            style: TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 20),
                          RadioGroup<CalorieStrat>(
                            groupValue: _selectedCalRegime,
                            onChanged: (CalorieStrat? value) {
                              setState(() {
                                _selectedCalRegime = value;
                              });
                              Navigator.pop(context); // close modal
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (final calories in CalorieStrat.values)
                                  RadioListTile(
                                    value: calories,
                                    title: Text(
                                      calories.title,
                                      style: AppTextStyles.bodyBold,
                                    ),
                                    subtitle: Text(
                                      calories.description,
                                      style: AppTextStyles.description,
                                    ),
                                  ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
              child: Row(
                children: [
                  Text("${_selectedCalRegime?.title}"),
                  const SizedBox(width: 8),
                  Icon(Icons.edit, color: AppColors.primary),
                ],
              ),
            ),
          ],
        ),
        //Row - Weight Loss Strategy
        Row(
          children: [
            Text(UserTextFields.strategyTitle, style: AppTextStyles.bodyBold),
            const SizedBox(width: 15),
            ElevatedButton(
              onPressed: () {
                CustomModal.bottomSheet(
                  context,
                  child: StatefulBuilder(
                    builder: (context, setModalStrategyState) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            ModalText.chooseOption,
                            style: TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 20),
                          RadioGroup<Strategy>(
                            groupValue: _selectedStrategy,
                            onChanged: (Strategy? value) {
                              setState(() {
                                _selectedStrategy = value;
                              });
                              Navigator.pop(context); // close modal
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (final strat in Strategy.values)
                                  RadioListTile(
                                    value: strat,
                                    title: Text(
                                      strat.title,
                                      style: AppTextStyles.bodyBold,
                                    ),
                                    subtitle: Text(
                                      strat.description,
                                      style: AppTextStyles.description,
                                    ),
                                  ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
              child: Row(
                children: [
                  Text("${_selectedStrategy?.title}"),
                  const SizedBox(width: 8),
                  Icon(Icons.edit, color: AppColors.primary),
                ],
              ),
            ),
          ],
        ),
        const DividerPPeso(),
        const SizedBox(height: 25),
        Row(
          children: [Text("Sua estratégia: ", style: AppTextStyles.subTitle)],
        ),
        const SizedBox(height: 25),
        Row(
          children: [
            Text("Valor semanal (kCal): ", style: AppTextStyles.bodyBold),
            Text(weeklyValue.toString(), style: AppTextStyles.body),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Text("Valor diário (kCal)", style: AppTextStyles.bodyBold),
            const SizedBox(width: 15),
            if (_selectedStrategy == Strategy.sCustom)
              ElevatedButton(
                onPressed: () {},
                child: Row(
                  children: [
                    Text("Customizar"),
                    const SizedBox(width: 8),
                    Icon(Icons.edit, color: AppColors.primary),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        WeeklyGrid(days: daysOfWeek),
      ],
    );
  }
}
