import 'package:flutter/material.dart';
import 'package:ppeso_mobile/core/styles.dart';
import 'package:ppeso_mobile/features/meal/models/meal_item_model.dart';
import 'package:ppeso_mobile/shared/content.dart';

class MealForm extends StatefulWidget {
  const MealForm({super.key});

  @override
  State<MealForm> createState() => _MealFormState();
}

class _MealFormState extends State<MealForm> {
  final List<MealItemModel> _items = [];

  @override
  void initState() {
    super.initState();
    _addItem(); // start with one item
  }

  @override
  void dispose() {
    for (var item in _items) {
      item.name.dispose();
      item.quantity.dispose();
    }
    super.dispose();
  }

  void _addItem() {
    setState(() {
      _items.add(
        MealItemModel(
          name: TextEditingController(),
          quantity: TextEditingController(),
        ),
      );
    });
  }

  void _removeItem(int index) {
    setState(() {
      if (_items.length > 1) {
        _items[index].name.dispose();
        _items[index].quantity.dispose();
        _items.removeAt(index);
      }
    });
  }

  void _submit() {
    final mealData = _items.map((item) {
      return {
        "name": item.name.text.trim(),
        "quantity": item.quantity.text.trim(),
        "unit": item.unit.title,
      };
    }).toList();

    debugPrint("Submitting meal data: $mealData");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Meal submitted successfully")),
    );

    // TODO: send mealData to your backend
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ElevatedButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.send),
              label: const Text(NewMealTabText.newMealItemSubmitBtn),
              style: ButtonStyles.defaultAcceptButton,
            ),
          ],
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _items.length,
          itemBuilder: (context, index) {
            final item = _items[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              color: AppColors.widgetBackground,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Text(
                      "${NewMealTabText.newMealItem} ${index + 1}",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: item.name,
                      minLines: 1,
                      maxLines: null,
                      decoration: InputDecoration(
                        labelText: NewMealTabText.newMealItemDesc,
                        enabledBorder: TextInputStyles.enabledDefault,
                        focusedBorder: TextInputStyles.focusDefault,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: item.quantity,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: NewMealTabText.newMealItemValueTitle,
                              enabledBorder: TextInputStyles.enabledDefault,
                              focusedBorder: TextInputStyles.focusDefault,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<Measurements>(
                            initialValue: item.unit,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: NewMealTabText.newMealItemUnitTitle,
                              enabledBorder: TextInputStyles.enabledDefault,
                              focusedBorder: TextInputStyles.focusDefault,
                            ),
                            items: Measurements.values
                                .map(
                                  (m) => DropdownMenuItem(
                                    value: m,
                                    child: Text(
                                      m.title,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _items[index].unit = value;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(
                          Icons.remove_circle,
                          color: Colors.red,
                        ),
                        onPressed: () => _removeItem(index),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton.icon(
              onPressed: _addItem,
              icon: const Icon(Icons.add),
              label: const Text(NewMealTabText.newMealItemBtn),
            ),
          ],
        ),
      ],
    );
  }
}
