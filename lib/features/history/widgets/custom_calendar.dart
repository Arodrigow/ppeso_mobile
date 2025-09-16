import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ppeso_mobile/core/styles.dart';
import 'package:ppeso_mobile/shared/content.dart';
import 'package:ppeso_mobile/shared/divider.dart';
import 'package:table_calendar/table_calendar.dart';

class CustomCalendar extends StatefulWidget {
  const CustomCalendar({super.key});

  @override
  State<CustomCalendar> createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<CustomCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Meals count per date
  final Map<DateTime, String> _dayNotes = {
    DateTime.utc(2025, 9, 1): "2000",
    DateTime.utc(2025, 9, 8): "2000",
    DateTime.utc(2025, 9, 15): "2 meals",
    DateTime.utc(2025, 9, 16): "1 meal",
    DateTime.utc(2025, 9, 18): "Workout",
  };

  final Map<DateTime, List<String>> _meals = {
    DateTime.utc(2025, 9, 15): ["Breakfast: Eggs", "Lunch: Salad"],
    DateTime.utc(2025, 9, 16): ["Dinner: Pasta"],
  };

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();

    return SingleChildScrollView(
      child: Column(
        children: [
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
                final note =
                    _dayNotes[DateTime.utc(day.year, day.month, day.day)];
                if (note != null) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("${day.day}"),
                      Text(
                        note,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.green,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                }
                return null;
              },
            ),
          ),
          const DividerPPeso(),
          _buildMealList(),
        ],
      ),
    );
  }

  Widget _buildMealList() {
    // Find meals for the selected day safely
    final meals = _meals.entries
        .firstWhere(
          (entry) => _selectedDay != null && isSameDay(entry.key, _selectedDay),
          orElse: () => MapEntry(DateTime.now(), []),
        )
        .value;

    if (meals.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: Text(HistoryTabText.noDailyMeal, style: AppTextStyles.body,)),
      );
    }

    // Limit the height dynamically to avoid overflow
    final height = (meals.length * 60.0).clamp(100.0, 400.0);

    return Column(
      children: [
        Text(HistoryTabText.dailyMeal, style: AppTextStyles.subTitle),
        SizedBox(
          height: height,
          child: ListView.builder(
            itemCount: meals.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.fastfood),
                title: Text(meals[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}
