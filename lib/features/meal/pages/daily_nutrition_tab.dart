import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ppeso_mobile/core/styles.dart';
import 'package:ppeso_mobile/providers/user_provider.dart';
import 'package:ppeso_mobile/shared/content.dart';
import 'package:ppeso_mobile/shared/loading_message.dart';
import 'package:ppeso_mobile/shared/requests/nutrition_daily_requests.dart';
import 'package:ppeso_mobile/shared/tab_structure.dart';

class DailyNutritionTab extends ConsumerStatefulWidget {
  const DailyNutritionTab({super.key});

  @override
  ConsumerState<DailyNutritionTab> createState() => _DailyNutritionTabState();
}

class _DailyNutritionTabState extends ConsumerState<DailyNutritionTab> {
  NutritionDailyDashboard? _dashboard;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    final user = ref.read(userProvider);
    final token = ref.read(authTokenProvider);
    final userId = _parseUserId(user?['id']);

    if (userId == null || token == null || token.isEmpty) {
      if (!mounted) return;
      setState(() => _error = 'Invalid user session.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await getTodayNutritionDashboard(
        userId: userId,
        token: token,
      );
      if (!mounted) return;
      setState(() {
        _dashboard = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final summary = _dashboard?.summary;
    final meals = _dashboard?.meals ?? const <MealDetails>[];
    final dayLabel = summary == null
        ? _formatDate(DateTime.now())
        : _formatDate(summary.date);

    final limits = _macroLimits(summary?.dailyLimit ?? 0);

    return TabStructure(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(MealPageText.dailyNutritionTitle, style: AppTextStyles.title),
            IconButton(
              onPressed: _isLoading ? null : _load,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text('Hoje: $dayLabel', style: AppTextStyles.bodyBold),
        const SizedBox(height: 20),
        if (_isLoading) const LinearProgressIndicator(),
        if (_error != null && !_isLoading)
          Text(_error!, style: const TextStyle(color: Colors.red)),
        if (summary != null) ...[
          _summaryCard(
            title: 'Calorias',
            rows: [
              _row(
                'Maximo diario',
                '${summary.dailyLimit.toStringAsFixed(0)} kcal',
              ),
              _row(
                'Consumido hoje',
                '${summary.calories.toStringAsFixed(0)} kcal',
              ),
              const SizedBox(height: 6),
              _progressRow(
                label: 'Progresso calorias',
                current: summary.calories,
                limit: summary.dailyLimit,
                color: AppColors.primary,
                unit: 'kcal',
              ),
            ],
          ),
          const SizedBox(height: 12),
          _summaryCard(
            title: 'Macros (hoje)',
            rows: [
              _row('Carboidratos', '${summary.carbs.toStringAsFixed(1)} g'),
              _progressRow(
                label: 'Meta carbos',
                current: summary.carbs,
                limit: limits.carbs,
                color: Colors.orange,
                unit: 'g',
              ),
              const SizedBox(height: 8),
              _row('Proteinas', '${summary.proteins.toStringAsFixed(1)} g'),
              _progressRow(
                label: 'Meta proteinas',
                current: summary.proteins,
                limit: limits.proteins,
                color: Colors.blue,
                unit: 'g',
              ),
              const SizedBox(height: 8),
              _row('Gorduras', '${summary.fat.toStringAsFixed(1)} g'),
              _progressRow(
                label: 'Meta gorduras',
                current: summary.fat,
                limit: limits.fat,
                color: Colors.deepPurple,
                unit: 'g',
              ),
              const SizedBox(height: 8),
              _row('Fibras', '${summary.fibers.toStringAsFixed(1)} g'),
            ],
          ),
          const SizedBox(height: 12),
          _summaryCard(
            title: 'Refeições de hoje',
            rows: [
              if (meals.isEmpty)
                const Text('Nenhuma refeição cadastrada hoje.'),
              ...meals.map(
                (meal) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Refeição #${meal.id}',
                    style: AppTextStyles.bodyBold,
                  ),
                  subtitle: Text(
                    '${meal.caloriasKcal.toStringAsFixed(1)} kcal | '
                    'C ${meal.carboidratosG.toStringAsFixed(1)}g | '
                    'P ${meal.proteinasG.toStringAsFixed(1)}g | '
                    'G ${meal.gordurasG.toStringAsFixed(1)}g',
                    style: AppTextStyles.description,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _openMealDetails(meal),
                ),
              ),
            ],
          ),
        ],
        if (summary == null && !_isLoading && _error == null)
          const Text('Sem dados diarios disponiveis.'),
      ],
    );
  }

  void _openMealDetails(MealDetails meal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Refeição #${meal.id}', style: AppTextStyles.subTitle),
                const SizedBox(height: 10),
                _row('Porção', meal.porcao.isEmpty ? '-' : meal.porcao),
                _row(
                  'Calorias',
                  '${meal.caloriasKcal.toStringAsFixed(1)} kcal',
                ),
                _row(
                  'Carboidratos',
                  '${meal.carboidratosG.toStringAsFixed(1)} g',
                ),
                _row('Proteínas', '${meal.proteinasG.toStringAsFixed(1)} g'),
                _row('Gorduras', '${meal.gordurasG.toStringAsFixed(1)} g'),
                _row('Fibras', '${meal.fibrasG.toStringAsFixed(1)} g'),
                _row('Sódio', '${meal.sodioMg.toStringAsFixed(1)} mg'),
                const SizedBox(height: 12),
                Text('Itens', style: AppTextStyles.bodyBold),
                const SizedBox(height: 6),
                if (meal.itens.isEmpty) const Text('Sem itens detalhados.'),
                ...meal.itens.map(
                  (item) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ExpansionTile(
                      title: Text(item.alimento, style: AppTextStyles.bodyBold),
                      subtitle: Text(
                        '${item.caloriasKcal.toStringAsFixed(1)} kcal',
                        style: AppTextStyles.description,
                      ),
                      childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                      children: [
                        _row('Porção', item.porcao),
                        _row(
                          'Calorias',
                          '${item.caloriasKcal.toStringAsFixed(1)} kcal',
                        ),
                        _row(
                          'Carboidratos',
                          '${item.carboidratosG.toStringAsFixed(1)} g',
                        ),
                        _row(
                          'Proteínas',
                          '${item.proteinasG.toStringAsFixed(1)} g',
                        ),
                        _row(
                          'Gorduras',
                          '${item.gordurasG.toStringAsFixed(1)} g',
                        ),
                        _row('Fibras', '${item.fibrasG.toStringAsFixed(1)} g'),
                        _row('Sódio', '${item.sodioMg.toStringAsFixed(1)} mg'),
                        if (item.fonte.isNotEmpty) _row('Fonte', item.fonte),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () => _deleteMeal(meal.id, ctx),
                      style: ButtonStyles.defaultAcceptButton.copyWith(
                        backgroundColor: WidgetStateProperty.all(Colors.red),
                      ),
                      child: const Text('Deletar refeição'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Fechar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteMeal(int mealId, BuildContext sheetContext) async {
    final user = ref.read(userProvider);
    final token = ref.read(authTokenProvider);
    final userId = _parseUserId(user?['id']);
    if (userId == null || token == null || token.isEmpty) return;

    try {
      await withLoading(
        context,
        () => deleteMealById(userId: userId, mealId: mealId, token: token),
      );
      if (!mounted) return;
      if (!sheetContext.mounted) return;
      Navigator.of(sheetContext).pop();
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Refeição deletada com sucesso.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao deletar refeição: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _summaryCard({required String title, required List<Widget> rows}) {
    return Card(
      color: AppColors.widgetBackground,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.subTitle),
            const SizedBox(height: 10),
            ...rows,
          ],
        ),
      ),
    );
  }

  Widget _row(String left, String right) {
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

  Widget _progressRow({
    required String label,
    required double current,
    required double limit,
    required Color color,
    required String unit,
  }) {
    final safeLimit = limit <= 0 ? 0 : limit;
    final ratio = safeLimit == 0 ? 0.0 : (current / safeLimit);
    final normalized = ratio.clamp(0.0, 1.0);
    final percent = (ratio * 100).clamp(0, 999).toStringAsFixed(0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.description),
            Text(
              safeLimit == 0
                  ? '-'
                  : '${current.toStringAsFixed(1)} / ${safeLimit.toStringAsFixed(1)} $unit ($percent%)',
              style: AppTextStyles.description,
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            minHeight: 8,
            value: normalized,
            color: color,
            backgroundColor: Colors.grey.shade300,
          ),
        ),
      ],
    );
  }

  _MacroLimits _macroLimits(double caloriesLimit) {
    if (caloriesLimit <= 0) {
      return const _MacroLimits(proteins: 0, fat: 0, carbs: 0);
    }

    // Protein = (Calories * 0.32) / 4
    // Fat     = (Calories * 0.28) / 9
    // Carbs   = (Calories * 0.40) / 4
    final proteins = (caloriesLimit * 0.32) / 4;
    final fat = (caloriesLimit * 0.28) / 9;
    final carbs = (caloriesLimit * 0.40) / 4;

    return _MacroLimits(proteins: proteins, fat: fat, carbs: carbs);
  }

  String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString().padLeft(4, '0');
    return '$d/$m/$y';
  }

  int? _parseUserId(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}

class _MacroLimits {
  final double proteins;
  final double fat;
  final double carbs;

  const _MacroLimits({
    required this.proteins,
    required this.fat,
    required this.carbs,
  });
}
