import 'package:flutter/material.dart';
import 'package:ppeso_mobile/core/styles.dart';
import 'package:ppeso_mobile/shared/content.dart';

class HealthTab extends StatefulWidget {
  const HealthTab({super.key});

  @override
  State<HealthTab> createState() => _HealthTabState();
}

enum ExerciseLevel { basal, sedentario, leve,moderado, ativo, muitoAtivo, extremamenteAtivo }

class _HealthTabState extends State<HealthTab> {
  ExerciseLevel? _selectedExerciseLevel = ExerciseLevel.leve;
  String? selectedCalRegime;
  String? selectedObjective;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      body: Center(
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
                          Text(
                            ProfilePageText.profileTile,
                            style: AppTextStyles.title,
                          ),
                          const SizedBox(height: 20),
                          RadioGroup(
                            groupValue: _selectedExerciseLevel,
                            onChanged:  (ExerciseLevel? value) {
                              setState(() {
                                _selectedExerciseLevel = value;
                              });
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Selecionado: $_selectedExerciseLevel'), 
                                const ListTile(
                                  title: Text('Basal'),
                                  leading: Radio(value: ExerciseLevel.basal),
                                ),
                                const ListTile(
                                  title: Text('Sedentário'),
                                  leading: Radio(value: ExerciseLevel.sedentario),
                                ),
                                const ListTile(
                                  title: Text('Leve'),
                                  leading: Radio(value: ExerciseLevel.leve),
                                ),
                                const ListTile(
                                  title: Text('Moderado'),
                                  leading: Radio(value: ExerciseLevel.moderado),
                                ),
                                const ListTile(
                                  title: Text('Ativo'),
                                  leading: Radio(value: ExerciseLevel.ativo),
                                ),
                                const ListTile(
                                  title: Text('Muito Ativo'),
                                  leading: Radio(value: ExerciseLevel.muitoAtivo),
                                ),
                                const ListTile(
                                  title: Text('Extremamente Ativo'),
                                  leading: Radio(value: ExerciseLevel.extremamenteAtivo),
                                ),

                              ],
                            ),
                          )
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
    );
  }
}
