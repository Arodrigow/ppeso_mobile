import 'package:flutter/material.dart';
import 'package:ppeso_mobile/core/styles.dart';
import 'package:ppeso_mobile/features/profile/widgets/custom_modal.dart';
import 'package:ppeso_mobile/shared/content.dart';
import 'package:ppeso_mobile/shared/tab_structure.dart';

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
    return TabStructure(
      children: [
        //Row - Exercise Level
        Row(
          children: [
            Text(UserTextFields.activityLevel, style: AppTextStyles.bodyBold),
            ElevatedButton(
              onPressed: () {
                ExerciseLevel? tempSelectedExerciseLevel =
                    _selectedExerciseLevel;
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
                            groupValue: tempSelectedExerciseLevel,
                            onChanged: (ExerciseLevel? value) {
                              setModalExerciseState(() {
                                tempSelectedExerciseLevel = value;
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
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedExerciseLevel =
                                    tempSelectedExerciseLevel;
                              });
                              Navigator.pop(context); // close modal
                            },
                            child: const Text(ModalText.updateOption),
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
              child: Text(
                "${_selectedExerciseLevel?.title}: ${_selectedExerciseLevel?.description}",
              ),
            ),
          ],
        ),
        //Row - Calorie Regime
        Row(
          children: [
            Text(UserTextFields.colorieTiTle, style: AppTextStyles.bodyBold),
            ElevatedButton(
              onPressed: () {
                CalorieStrat? tempSelectedCalRegime = _selectedCalRegime;
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
                            groupValue: tempSelectedCalRegime,
                            onChanged: (CalorieStrat? value) {
                              setModalColorieState(() {
                                tempSelectedCalRegime = value;
                              });
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
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context); // close modal
                                    setState(() {
                                      _selectedCalRegime =
                                          tempSelectedCalRegime;
                                    });
                                  },
                                  child: const Text(ModalText.updateOption),
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
              child: Text(
                "${_selectedCalRegime?.title}: ${_selectedCalRegime?.description}",
              ),
            ),
          ],
        ),
      ],
    );
  }
}
