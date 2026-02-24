import 'package:flutter/material.dart';
import 'package:ppeso_mobile/core/styles.dart';
import 'package:ppeso_mobile/features/profile/models/date_model.dart';
import 'package:ppeso_mobile/shared/content.dart';

class AccordionCustom extends StatefulWidget {
  final List<DateModel> weightData;
  final Future<void> Function(DateModel weight)? onDelete;

  const AccordionCustom({super.key, required this.weightData, this.onDelete});

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
                        Text(
                          "${weight.date.day}/${weight.date.month}/${weight.date.year}: ${weight.weight}",
                        ),
                        ElevatedButton(
                          onPressed: widget.onDelete == null
                              ? null
                              : () async => widget.onDelete!(weight),
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
