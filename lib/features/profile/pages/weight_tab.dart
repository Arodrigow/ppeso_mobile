import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ppeso_mobile/core/styles.dart';
import 'package:ppeso_mobile/features/profile/models/date_model.dart';
import 'package:ppeso_mobile/features/profile/widgets/custom_modal.dart';
import 'package:ppeso_mobile/features/profile/widgets/weight_chart.dart';
import 'package:ppeso_mobile/providers/user_provider.dart';
import 'package:ppeso_mobile/shared/accordion_custom.dart';
import 'package:ppeso_mobile/shared/content.dart';
import 'package:ppeso_mobile/shared/divider.dart';
import 'package:ppeso_mobile/shared/loading_message.dart';
import 'package:ppeso_mobile/shared/requests/weight_requests.dart';
import 'package:ppeso_mobile/shared/tab_structure.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeightTab extends ConsumerStatefulWidget {
  const WeightTab({super.key});

  @override
  ConsumerState<WeightTab> createState() => _WeightTabState();
}

class _WeightTabState extends ConsumerState<WeightTab> {
  static final Map<int, List<DateModel>> _memoryCache = {};
  static final Set<int> _fetchedUsersInSession = {};

  final TextEditingController _controller = TextEditingController(
    text:
        "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
  );

  final List<DateModel> _weightData = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadWeights);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadWeights({bool forceRefresh = false}) async {
    final user = ref.read(userProvider);
    final token = ref.read(authTokenProvider);
    final userId = _parseUserId(user?['id']);

    if (userId == null || token == null || token.isEmpty) return;

    // Fast-path: use in-memory cache first.
    if (!forceRefresh && _memoryCache.containsKey(userId)) {
      setState(() {
        _weightData
          ..clear()
          ..addAll(_memoryCache[userId]!);
      });
    }

    // Persistent cache for cold starts.
    if (!forceRefresh && _weightData.isEmpty) {
      final cached = await _readCachedWeights(userId);
      if (cached.isNotEmpty && mounted) {
        setState(() {
          _weightData
            ..clear()
            ..addAll(cached);
        });
      }
    }

    // Only fetch from server once per session unless a change occurred.
    if (!forceRefresh && _fetchedUsersInSession.contains(userId)) {
      return;
    }

    if (mounted) {
      setState(() => _isLoading = true);
    }
    try {
      final data = await getWeightHistory(
        userId: userId,
        token: token,
      ).timeout(const Duration(seconds: 120));
      if (!mounted) return;
      setState(() {
        _weightData
          ..clear()
          ..addAll(data);
        _isLoading = false;
      });
      await _syncCurrentWeightWithHistory();
      _memoryCache[userId] = List<DateModel>.from(data);
      _fetchedUsersInSession.add(userId);
      await _cacheWeights(userId, data);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to load weights: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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

  DateTime _parseSelectedDate() {
    final parts = _controller.text.split('/');
    if (parts.length != 3) return DateTime.now();
    final day = int.tryParse(parts[0]) ?? DateTime.now().day;
    final month = int.tryParse(parts[1]) ?? DateTime.now().month;
    final year = int.tryParse(parts[2]) ?? DateTime.now().year;
    return DateTime(year, month, day);
  }

  Future<void> _addWeight({required String weightInput}) async {
    final user = ref.read(userProvider);
    final token = ref.read(authTokenProvider);
    final userId = _parseUserId(user?['id']);

    if (userId == null || token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid user session. Please login again."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final weight = double.tryParse(weightInput.replaceAll(',', '.'));
    if (weight == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid weight value"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await withLoading(
        context,
        () => createWeight(
          userId: userId,
          token: token,
          weight: weight,
          date: _parseSelectedDate(),
        ),
      );

      await _loadWeights(forceRefresh: true);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Weight added successfully")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to add weight: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteWeight(DateModel weight) async {
    final user = ref.read(userProvider);
    final token = ref.read(authTokenProvider);
    final userId = _parseUserId(user?['id']);

    if (userId == null || token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid user session. Please login again."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (weight.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("This weight does not have an ID to delete."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await withLoading(
        context,
        () => deleteWeight(userId: userId, weightId: weight.id!, token: token),
      );
      if (!mounted) return;
      setState(() {
        _weightData.removeWhere((e) => e.id == weight.id);
      });
      await _syncCurrentWeightWithHistory();
      _memoryCache[userId] = List<DateModel>.from(_weightData);
      await _cacheWeights(userId, _weightData);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Weight deleted")));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to delete weight: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final targetWeight = (user?['peso_target'] is num)
        ? (user?['peso_target'] as num).toDouble()
        : null;

    return TabStructure(
      children: [
        Text("PPeso", style: AppTextStyles.title),
        const SizedBox(height: 20),
        if (_isLoading) ...[
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: LinearProgressIndicator(),
          ),
        ],
        WeightChart(weightData: _weightData, targetWeight: targetWeight),
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
                final weightController = TextEditingController();
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
                            controller: weightController,
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
                                onPressed: () => _addWeight(
                                  weightInput: weightController.text.trim(),
                                ),
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
        AccordionCustom(weightData: _weightData, onDelete: _deleteWeight),
      ],
    );
  }

  Future<void> _cacheWeights(int userId, List<DateModel> data) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = data
        .map(
          (e) => {
            'id': e.id,
            'date': e.date.toIso8601String(),
            'weight': e.weight,
          },
        )
        .toList();
    await prefs.setString('weights_cache_$userId', jsonEncode(raw));
  }

  Future<List<DateModel>> _readCachedWeights(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('weights_cache_$userId');
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map<String, dynamic>>()
          .map((e) {
            final date = DateTime.tryParse((e['date'] ?? '').toString());
            final weight = e['weight'] is num
                ? (e['weight'] as num).toDouble()
                : double.tryParse((e['weight'] ?? '').toString());
            if (date == null || weight == null) return null;
            final id = e['id'] is num
                ? (e['id'] as num).toInt()
                : int.tryParse((e['id'] ?? '').toString());
            return DateModel(id: id, date: date, weight: weight);
          })
          .whereType<DateModel>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  int? _parseUserId(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  Future<void> _syncCurrentWeightWithHistory() async {
    final userRaw = ref.read(userProvider);
    final token = ref.read(authTokenProvider);
    if (userRaw == null ||
        token == null ||
        token.isEmpty ||
        _weightData.isEmpty) {
      return;
    }

    final latest = _weightData.reduce((a, b) => a.date.isAfter(b.date) ? a : b);

    final currentNow = userRaw['peso_now'];
    final currentNowValue = currentNow is num
        ? currentNow.toDouble()
        : double.tryParse(currentNow?.toString() ?? '');
    if (currentNowValue != null &&
        (currentNowValue - latest.weight).abs() < 0.0001) {
      return;
    }

    final updatedUser = Map<String, dynamic>.from(userRaw);
    updatedUser['peso_now'] = latest.weight;
    await saveSession(ref, token, updatedUser);
  }
}
