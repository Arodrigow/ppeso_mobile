import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ppeso_mobile/core/styles.dart';
import 'package:ppeso_mobile/features/meal/models/meal_item_model.dart';
import 'package:ppeso_mobile/features/meal/providers/user_recipes_provider.dart';
import 'package:ppeso_mobile/shared/content.dart';

class MealForm extends ConsumerStatefulWidget {
  const MealForm({super.key});

  @override
  ConsumerState<MealForm> createState() => _MealFormState();
}

class _MealFormState extends ConsumerState<MealForm> {
  final List<MealItemModel> _items = [];

  @override
  void initState() {
    super.initState();
    _addItem();
  }

  @override
  void dispose() {
    for (var item in _items) {
      item.name.dispose();
      item.quantity.dispose();
    }
    super.dispose();
  }

  void _addItem({String? initialName, bool asFirst = false}) {
    final item = MealItemModel(
      name: TextEditingController(text: initialName ?? ''),
      quantity: TextEditingController(),
    );

    setState(() {
      if (asFirst) {
        _items.insert(0, item);
      } else {
        _items.add(item);
      }
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
        'name': item.name.text.trim(),
        'quantity': item.quantity.text.trim(),
        'unit': item.unit.title,
      };
    }).toList();

    debugPrint('Submitting meal data: $mealData');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Meal submitted successfully')),
    );

    // TODO: send mealData to your backend
  }

  Widget _buildNameAutocomplete(MealItemModel item, List<String> options) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        final query = textEditingValue.text.trim().toLowerCase();
        if (query.isEmpty) {
          return options;
        }
        return options.where((option) => option.toLowerCase().contains(query));
      },
      onSelected: (selected) {
        item.name.value = TextEditingValue(
          text: selected,
          selection: TextSelection.collapsed(offset: selected.length),
        );
      },
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
            if (textEditingController.text != item.name.text) {
              textEditingController.value = TextEditingValue(
                text: item.name.text,
                selection: TextSelection.collapsed(
                  offset: item.name.text.length,
                ),
              );
            }

            return TextField(
              controller: textEditingController,
              focusNode: focusNode,
              minLines: 1,
              maxLines: null,
              decoration: InputDecoration(
                labelText: NewMealTabText.newMealItemDesc,
                enabledBorder: TextInputStyles.enabledDefault,
                focusedBorder: TextInputStyles.focusDefault,
              ),
              onChanged: (value) {
                item.name.value = TextEditingValue(
                  text: value,
                  selection: TextSelection.collapsed(offset: value.length),
                );
              },
            );
          },
    );
  }

  @override
  Widget build(BuildContext context) {
    final recipeNames = ref
        .watch(userRecipesProvider)
        .map((r) => r.title)
        .toList();

    ref.listen<String?>(selectedRecipeForNewMealProvider, (previous, next) {
      if (next == null || next.trim().isEmpty) {
        return;
      }
      _addItem(initialName: next.trim(), asFirst: true);
      ref.read(selectedRecipeForNewMealProvider.notifier).state = null;
    });

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
                      '${NewMealTabText.newMealItem} ${index + 1}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    _buildNameAutocomplete(item, recipeNames),
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
              onPressed: () => _addItem(),
              icon: const Icon(Icons.add),
              label: const Text(NewMealTabText.newMealItemBtn),
            ),
          ],
        ),
      ],
    );
  }
}
