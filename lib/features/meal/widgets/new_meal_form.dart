import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ppeso_mobile/core/styles.dart';
import 'package:ppeso_mobile/features/meal/models/meal_item_model.dart';
import 'package:ppeso_mobile/features/meal/providers/user_recipes_provider.dart';
import 'package:ppeso_mobile/providers/user_provider.dart';
import 'package:ppeso_mobile/shared/content.dart';
import 'package:ppeso_mobile/shared/loading_message.dart';
import 'package:ppeso_mobile/shared/requests/daily_requests.dart';
import 'package:ppeso_mobile/shared/requests/new_meal_requests.dart';

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

  Future<void> _submit() async {
    final user = ref.read(userProvider);
    final token = ref.read(authTokenProvider);
    final userId = _parseUserId(user?['id']);

    if (userId == null || token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('SessÃƒÂ£o invÃƒÂ¡lida. FaÃƒÂ§a login novamente.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final lines = <String>[];
    for (int i = 0; i < _items.length; i++) {
      final item = _items[i];
      final desc = item.name.text.trim();
      final value = item.quantity.text.trim();
      if (desc.isEmpty || value.isEmpty) continue;
      lines.add('item ${i + 1}: $desc, $value (${item.unit.title})');
    }

    if (lines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adicione ao menos um item vÃƒÂ¡lido para analisar.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final payloadText = lines.join('; ');
    final analysisPrompt =
        'Faca a analise nutricional em portugues-BR para estes itens: $payloadText';

    try {
      final analysis = await withLoading(
        context,
        () =>
            analyzeMealText(userId: userId, token: token, text: analysisPrompt),
      );

      if (!mounted) return;
      _showAnalysisModal(analysis);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha na anÃƒÂ¡lise nutricional: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _confirmCreateMeal(NutritionAnalysisResult analysis) async {
    final user = ref.read(userProvider);
    final token = ref.read(authTokenProvider);
    final userId = _parseUserId(user?['id']);

    if (userId == null || token == null || token.isEmpty) return;

    try {
      await withLoading(context, () async {
        await ensureDailyForToday(userId: userId, token: token);
        final daily = await getTodayDaily(userId: userId, token: token);
        if (daily == null) {
          throw Exception('Daily not available for today');
        }

        final dailyId = _parseUserId(daily['id']);
        if (dailyId == null) {
          throw Exception('Invalid daily ID');
        }

        final dailyLimit = _toDouble(daily['daily_limit']);
        final mealId = await createMeal(
          userId: userId,
          token: token,
          dailyId: dailyId,
          dailyLimit: dailyLimit,
          total: analysis.total,
        );

        if (analysis.itens.isNotEmpty) {
          await createItems(
            userId: userId,
            token: token,
            mealId: mealId,
            itens: analysis.itens,
          );
        }
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('RefeiÃƒÂ§ÃƒÂ£o e itens criados com sucesso.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha ao criar refeiÃƒÂ§ÃƒÂ£o/itens: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAnalysisModal(NutritionAnalysisResult analysis) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AnÃƒÂ¡lise nutricional', style: AppTextStyles.subTitle),
                  const SizedBox(height: 12),
                  if (analysis.hasWarning)
                    Text(
                      analysis.other!,
                      style: const TextStyle(color: Colors.orange),
                    ),
                  _resultRow(
                    'Calorias totais',
                    '${analysis.total.caloriasKcal.toStringAsFixed(1)} kcal',
                  ),
                  _resultRow(
                    'Carboidratos',
                    '${analysis.total.carboidratosG.toStringAsFixed(1)} g',
                  ),
                  _resultRow(
                    'ProteÃƒÂ­nas',
                    '${analysis.total.proteinasG.toStringAsFixed(1)} g',
                  ),
                  _resultRow(
                    'Gorduras',
                    '${analysis.total.gordurasG.toStringAsFixed(1)} g',
                  ),
                  _resultRow(
                    'Fibras',
                    '${analysis.total.fibrasG.toStringAsFixed(1)} g',
                  ),
                  const SizedBox(height: 12),
                  Text('Itens', style: AppTextStyles.bodyBold),
                  const SizedBox(height: 6),
                  if (analysis.itens.isEmpty)
                    const Text('Nenhum item retornado pela anÃƒÂ¡lise.'),
                  ...analysis.itens.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        '- ${item.alimento}: ${item.porcao} | ${item.caloriasKcal.toStringAsFixed(1)} kcal',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          Navigator.of(ctx).pop();
                          await _confirmCreateMeal(analysis);
                        },
                        style: ButtonStyles.defaultAcceptButton,
                        child: const Text('Confirmar'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Cancelar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
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

  Widget _resultRow(String left, String right) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(left, style: AppTextStyles.bodyBold),
          Text(right, style: AppTextStyles.body),
        ],
      ),
    );
  }

  int? _parseUserId(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value.replaceAll(',', '.')) ?? 0;
    }
    return 0;
  }
}
