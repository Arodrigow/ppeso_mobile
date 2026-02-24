import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ppeso_mobile/core/styles.dart';
import 'package:ppeso_mobile/providers/user_provider.dart';
import 'package:ppeso_mobile/shared/content.dart';
import 'package:ppeso_mobile/shared/requests/nutrition_daily_requests.dart';
import 'package:ppeso_mobile/shared/tab_structure.dart';

class DailyNutritionTab extends ConsumerStatefulWidget {
  const DailyNutritionTab({super.key});

  @override
  ConsumerState<DailyNutritionTab> createState() => _DailyNutritionTabState();
}

class _DailyNutritionTabState extends ConsumerState<DailyNutritionTab> {
  NutritionDailySummary? _summary;
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
      final data = await getTodayNutritionSummary(userId: userId, token: token);
      if (!mounted) return;
      setState(() {
        _summary = data;
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
    final summary = _summary;
    final dayLabel = summary == null
        ? _formatDate(DateTime.now())
        : _formatDate(summary.date);

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
                'Máximo diário',
                '${summary.dailyLimit.toStringAsFixed(0)} kcal',
              ),
              _row(
                'Consumido hoje',
                '${summary.calories.toStringAsFixed(0)} kcal',
              ),
            ],
          ),
          const SizedBox(height: 12),
          _summaryCard(
            title: 'Macros (hoje)',
            rows: [
              _row('Carboidratos', '${summary.carbs.toStringAsFixed(1)} g'),
              _row('Proteínas', '${summary.proteins.toStringAsFixed(1)} g'),
              _row('Gorduras', '${summary.fat.toStringAsFixed(1)} g'),
              _row('Fibras', '${summary.fibers.toStringAsFixed(1)} g'),
            ],
          ),
        ],
        if (summary == null && !_isLoading && _error == null)
          const Text('Sem dados diários disponíveis.'),
      ],
    );
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
