import 'package:flutter/material.dart';
import 'package:ppeso_mobile/core/styles.dart';
import 'package:ppeso_mobile/features/profile/models/date_model.dart';
import 'package:ppeso_mobile/features/profile/widgets/custom_modal.dart';
import 'package:ppeso_mobile/features/profile/widgets/weight_chart.dart';
import 'package:ppeso_mobile/shared/content.dart';
import 'package:ppeso_mobile/shared/divider.dart';
import 'package:ppeso_mobile/shared/tab_structure.dart';

class WeightTab extends StatefulWidget {
  const WeightTab({super.key});

  @override
  State<WeightTab> createState() => _WeightTabState();
}

class _WeightTabState extends State<WeightTab> {
  final TextEditingController _controller = TextEditingController(
    text:
        "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
  );

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      _controller.text = "${picked.day}/${picked.month}/${picked.year}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return TabStructure(
      children: [
        Text("PPeso", style: AppTextStyles.title),
        const SizedBox(height: 20),
        WeightChart(
          weightData: [
            DateModel(date: DateTime(2025, 1, 1), weight: 80.5),
            DateModel(date: DateTime(2025, 2, 1), weight: 79.2),
            DateModel(date: DateTime(2025, 3, 1), weight: 78.8),
          ],
        ),
        DividerPPeso(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              WeightTabContent.addWeightButton,
              style: AppTextStyles.subTitle,
            ),
            ElevatedButton(
              onPressed: () {
                CustomModal.bottomSheet(
                  context,
                  child: StatefulBuilder(
                    builder: (context, setModalWeightState) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          //New weight date
                          TextFormField(
                            readOnly: true,
                            controller: _controller,
                            decoration: InputDecoration(
                              labelText: WeightTabContent.addDate,
                              enabledBorder: TextInputStyles.enabledDefault,
                              focusedBorder: TextInputStyles.focusDefault,
                              suffixIcon: Icon(
                                Icons.calendar_month,
                                color: AppColors.primary,
                              ),
                            ),
                            onTap: _selectDate,
                          ),
                          const SizedBox(height: 15),
                          //New Weight value
                          TextFormField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: WeightTabContent.addWeight,
                              enabledBorder: TextInputStyles.enabledDefault,
                              focusedBorder: TextInputStyles.focusDefault,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ElevatedButton(
                                onPressed: () {},
                                style: ButtonStyles.defaultAcceptButton,
                                child: const Text(
                                  WeightTabContent.addWeightData,
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text(
                                  WeightTabContent.closeWeightModal,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      );
                    },
                  ),
                );
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(AppColors.primary),
              ),
              child: Icon(Icons.add, color: AppColors.widgetBackground),
            ),
          ],
        ),
        DividerPPeso(),
      ],
    );
  }
}
