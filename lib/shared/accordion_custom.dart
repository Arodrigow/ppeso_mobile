import 'package:flutter/material.dart';
import 'package:ppeso_mobile/core/styles.dart';
import 'package:ppeso_mobile/features/profile/models/date_model.dart';
import 'package:ppeso_mobile/shared/content.dart';

class AccordionCustom extends StatefulWidget {
  final List<DateModel> weightData;
  const AccordionCustom({super.key, required this.weightData});

  @override
  State<AccordionCustom> createState() => _AccordionCustomState();
}

class _AccordionCustomState extends State<AccordionCustom> {
  @override
  Widget build(BuildContext context) {
    return ExpansionPanelList.radio(
      children: [
        ExpansionPanelRadio(
          value: 0,
          headerBuilder: (context, isExpanded) {
            return const ListTile(
              leading: Icon(Icons.history),
              title: Text(
                WeightTabContent.historicWeightTitle,
                style: AppTextStyles.bodyBold,
              ),
            );
          },
          backgroundColor: AppColors.appBackground,
          canTapOnHeader: true,
          body: Container(
            color: AppColors.widgetBackground,
            child: Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 10,
                bottom: 10,
              ),
              child: Column(
                children: [
                  for (final weight in widget.weightData)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${weight.date.day}/${weight.date.month}/${weight.date.year}: ${weight.weight}"),
                        ElevatedButton(
                          onPressed: () {},
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                              Colors.red,
                            ),
                          ),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
