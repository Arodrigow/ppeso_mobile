import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ppeso_mobile/core/styles.dart';
import 'package:ppeso_mobile/features/profile/models/user.dart';
import 'package:ppeso_mobile/features/profile/widgets/custom_modal.dart';
import 'package:ppeso_mobile/features/profile/widgets/weekly_grid.dart';
import 'package:ppeso_mobile/providers/user_provider.dart';
import 'package:ppeso_mobile/shared/calculate_age.dart';
import 'package:ppeso_mobile/shared/calorie_calc.dart';
import 'package:ppeso_mobile/shared/content.dart';
import 'package:ppeso_mobile/shared/divider.dart';
import 'package:ppeso_mobile/shared/parse_daily_value.dart';
import 'package:ppeso_mobile/shared/requests/update_user.dart';
import 'package:ppeso_mobile/shared/tab_structure.dart';

class HealthTab extends ConsumerStatefulWidget {
  const HealthTab({super.key});

  @override
  ConsumerState<HealthTab> createState() => _HealthTabState();
}

class _HealthTabState extends ConsumerState<HealthTab> {
  late ExerciseLevel _selectedExerciseLevel;
  late CalorieStrat _selectedCalRegime;
  late Strategy _selectedStrategy;

  @override
  void initState() {
    super.initState();
    final userRaw = ref.read(userProvider);
    final user = User.fromJson(userRaw);

    _selectedExerciseLevel = user.atividade;
    _selectedCalRegime = user.regimeCalorico;
    _selectedStrategy = user.estrategia;
  }

  @override
  Widget build(BuildContext context) {
    final userRaw = ref.watch(userProvider);
    final user = User.fromJson(userRaw);
    final token = ref.read(authTokenProvider);

    int idade = calculateAge(user.aniversario);
    final weeklyValue = calorieCalculator(
      user.pesoNow,
      user.altura,
      idade,
      user.gender,
      _selectedExerciseLevel,
      _selectedCalRegime,
    );
    final manterCal = calorieCalculator(
      user.pesoNow,
      user.altura,
      idade,
      user.gender,
      _selectedExerciseLevel,
      CalorieStrat.Manter,
    );

    final daysOfWeek = parseToDailyValue(
      calculateZigZagCalories(
        weeklyValue,
        manterCal,
        user.gender,
        _selectedCalRegime,
        _selectedStrategy,
      ),
    );
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                ModalText.chooseOption,
                                style: TextStyle(fontSize: 18),
                              ),
                              IconButton(
                                icon: Icon(Icons.close),
                                onPressed: () =>
                                    Navigator.pop(context), // closes the modal
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          RadioGroup<ExerciseLevel>(
                            groupValue: _selectedExerciseLevel,
                            onChanged: (ExerciseLevel? value) {
                              setState(() {
                                _selectedExerciseLevel =
                                    value ?? ExerciseLevel.Basal;
                              });
                              Navigator.pop(context);
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
                  Text(_selectedExerciseLevel.title),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                ModalText.chooseOption,
                                style: TextStyle(fontSize: 18),
                              ),
                              IconButton(
                                icon: Icon(Icons.close),
                                onPressed: () =>
                                    Navigator.pop(context), // closes the modal
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          RadioGroup<CalorieStrat>(
                            groupValue: _selectedCalRegime,
                            onChanged: (CalorieStrat? value) {
                              setState(() {
                                _selectedCalRegime =
                                    value ?? CalorieStrat.Manter;
                                updateUser(
                                  user: user.copyWith(regimeCalorico: _selectedCalRegime),
                                  token: token ?? '',
                                );
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
                  Text(_selectedCalRegime.title),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                ModalText.chooseOption,
                                style: TextStyle(fontSize: 18),
                              ),
                              IconButton(
                                icon: Icon(Icons.close),
                                onPressed: () =>
                                    Navigator.pop(context), // closes the modal
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          RadioGroup<Strategy>(
                            groupValue: _selectedStrategy,
                            onChanged: (Strategy? value) {
                              setState(() {
                                _selectedStrategy = value ?? Strategy.Fixo;
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
                  Text(_selectedStrategy.title),
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
            Text("Total semanal (kCal): ", style: AppTextStyles.bodyBold),
            Text(
              (weeklyValue * 7).ceil().toString(),
              style: AppTextStyles.body,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Text("Média diária (kCal): ", style: AppTextStyles.bodyBold),
            Text(weeklyValue.ceil().toString(), style: AppTextStyles.body),
          ],
        ),
        const SizedBox(height: 20),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
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
        ),

        const SizedBox(height: 10),
        WeeklyGrid(days: daysOfWeek),
      ],
    );
  }
}
