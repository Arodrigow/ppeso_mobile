import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ppeso_mobile/core/styles.dart';
import 'package:ppeso_mobile/providers/user_provider.dart';
import 'package:ppeso_mobile/shared/loading_message.dart';
import 'package:ppeso_mobile/shared/requests/nutrition_daily_requests.dart';
import 'package:ppeso_mobile/shared/divider.dart';
import 'package:table_calendar/table_calendar.dart';

class CustomCalendar extends ConsumerStatefulWidget {
  const CustomCalendar({super.key});

  @override
  ConsumerState<CustomCalendar> createState() => _CustomCalendarState();
}

class _CustomCalendarState extends ConsumerState<CustomCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isLoading = false;

  final Map<String, DailyCalendarSummary> _summariesByDay = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadCalendarSummaries);
  }

  Future<void> _loadCalendarSummaries() async {
    final user = ref.read(userProvider);
    final token = ref.read(authTokenProvider);
    final userId = _parseUserId(user?['id']);

    if (userId == null || token == null || token.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final summaries = await getDailyCalendarSummaries(
        userId: userId,
        token: token,
      );
      if (!mounted) return;
      setState(() {
        _summariesByDay
          ..clear()
          ..addEntries(summaries.map((s) => MapEntry(_dayKey(s.date), s)));
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _openDateDetails(DateTime selectedDay) async {
    final user = ref.read(userProvider);
    final token = ref.read(authTokenProvider);
    final userId = _parseUserId(user?['id']);

    if (userId == null || token == null || token.isEmpty) return;

    try {
      final dashboard = await withLoading(
        context,
        () => getNutritionDashboardByDate(
          userId: userId,
          token: token,
          localDate: selectedDay,
        ),
      );

      if (!mounted) return;
      _showDayDetailsModal(dashboard);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar dados do dia: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();

    return SingleChildScrollView(
      child: Column(
        children: [
          if (_isLoading) const LinearProgressIndicator(),
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _openDateDetails(selectedDay);
            },
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                color: AppColors.appBackground,
                fontWeight: FontWeight.bold,
              ),
              decoration: BoxDecoration(color: AppColors.primary),
            ),
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            calendarBuilders: CalendarBuilders(
              headerTitleBuilder: (context, day) {
                return Center(
                  child: GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _focusedDay,
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          _focusedDay = picked;
                          _selectedDay = picked;
                        });
                        _openDateDetails(picked);
                      }
                    },
                    child: Text(
                      DateFormat.yMMMM(locale).format(_focusedDay),
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: AppColors.widgetBackground,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
              defaultBuilder: (context, day, focusedDay) {
                return _buildDayCell(day);
              },
              todayBuilder: (context, day, focusedDay) => _buildDayCell(day),
              selectedBuilder: (context, day, focusedDay) => _buildDayCell(day),
            ),
          ),
          const DividerPPeso(),
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'Selecione um dia para abrir os detalhes de calorias, macros e refeições.',
              style: AppTextStyles.description,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCell(DateTime day) {
    final summary = _summariesByDay[_dayKey(day)];
    final isSelected = _selectedDay != null && isSameDay(_selectedDay, day);

    return Container(
      margin: const EdgeInsets.all(2),
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withValues(alpha: 0.18) : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text('${day.day}', style: const TextStyle(fontSize: 11)),
              ),
              if (summary != null)
                SizedBox(
                  width: constraints.maxWidth,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _formatCompactCalendarValue(summary.calories),
                      style: const TextStyle(
                        fontSize: 8,
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              if (summary != null)
                SizedBox(
                  width: constraints.maxWidth,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _formatCompactCalendarValue(summary.dailyLimit),
                      style: const TextStyle(
                        fontSize: 8,
                        color: Color(0xFF8B0000),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _showDayDetailsModal(NutritionDailyDashboard dashboard) {
    final summary = dashboard.summary;
    final meals = dashboard.meals;

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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Detalhes de ${DateFormat('dd/MM/yyyy').format(summary.date)}',
                          style: AppTextStyles.subTitle,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(ctx).pop(),
                        tooltip: 'Fechar',
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _row(
                    'Meta calórica',
                    '${summary.dailyLimit.toStringAsFixed(0)} kcal',
                  ),
                  _row(
                    'Consumido',
                    '${summary.calories.toStringAsFixed(0)} kcal',
                  ),
                  _row('Carboidratos', '${summary.carbs.toStringAsFixed(1)} g'),
                  _row('Proteínas', '${summary.proteins.toStringAsFixed(1)} g'),
                  _row('Gorduras', '${summary.fat.toStringAsFixed(1)} g'),
                  _row('Fibras', '${summary.fibers.toStringAsFixed(1)} g'),
                  const SizedBox(height: 12),
                  Text('Refeições', style: AppTextStyles.bodyBold),
                  const SizedBox(height: 8),
                  if (meals.isEmpty) const Text('Nenhuma refeição nesse dia.'),
                  ...meals.map(
                    (meal) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ExpansionTile(
                        title: Text('Refeição #${meal.id}'),
                        subtitle: Text(
                          '${meal.caloriasKcal.toStringAsFixed(1)} kcal | C ${meal.carboidratosG.toStringAsFixed(1)}g | P ${meal.proteinasG.toStringAsFixed(1)}g | G ${meal.gordurasG.toStringAsFixed(1)}g',
                          style: AppTextStyles.description,
                        ),
                        childrenPadding: const EdgeInsets.fromLTRB(
                          12,
                          0,
                          12,
                          10,
                        ),
                        children: [
                          _row(
                            'Porção',
                            meal.porcao.isEmpty ? '-' : meal.porcao,
                          ),
                          _row(
                            'Fibras',
                            '${meal.fibrasG.toStringAsFixed(1)} g',
                          ),
                          _row(
                            'Sódio',
                            '${meal.sodioMg.toStringAsFixed(1)} mg',
                          ),
                          const SizedBox(height: 6),
                          Text('Itens', style: AppTextStyles.bodyBold),
                          const SizedBox(height: 6),
                          if (meal.itens.isEmpty)
                            const Text('Sem itens detalhados.'),
                          ...meal.itens.map(
                            (item) => Card(
                              margin: const EdgeInsets.only(bottom: 6),
                              child: ExpansionTile(
                                title: Text(item.alimento),
                                subtitle: Text(
                                  '${item.caloriasKcal.toStringAsFixed(1)} kcal',
                                  style: AppTextStyles.description,
                                ),
                                childrenPadding: const EdgeInsets.fromLTRB(
                                  12,
                                  0,
                                  12,
                                  10,
                                ),
                                children: [
                                  _row('Porção', item.porcao),
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
                                  _row(
                                    'Fibras',
                                    '${item.fibrasG.toStringAsFixed(1)} g',
                                  ),
                                  _row(
                                    'Sódio',
                                    '${item.sodioMg.toStringAsFixed(1)} mg',
                                  ),
                                  if (item.fonte.isNotEmpty)
                                    _row('Fonte', item.fonte),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Fechar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _row(String left, String right) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 4, child: Text(left, style: AppTextStyles.bodyBold)),
          const SizedBox(width: 10),
          Expanded(
            flex: 6,
            child: Text(
              right,
              style: AppTextStyles.body,
              textAlign: TextAlign.right,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  String _dayKey(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  int? _parseUserId(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  String _formatCompactCalendarValue(double value) {
    if (value >= 1000) {
      final compact = value / 1000;
      return '${compact.toStringAsFixed(compact >= 10 ? 0 : 1)}k';
    }
    return value.toStringAsFixed(0);
  }
}
