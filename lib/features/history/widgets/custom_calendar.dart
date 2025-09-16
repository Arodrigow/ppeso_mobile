import 'package:flutter/material.dart';
import 'package:ppeso_mobile/core/styles.dart';
import 'package:table_calendar/table_calendar.dart';

class CustomCalendar extends StatefulWidget {
  const CustomCalendar({super.key});

  @override
  State<CustomCalendar> createState() => _CustomCalendar();
}

class _CustomCalendar extends State<CustomCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Example: Meals count per date
  final Map<DateTime, String> _dayNotes = {
    DateTime.utc(2025, 9, 15): "2 meals",
    DateTime.utc(2025, 9, 15): "2 meals",
    DateTime.utc(2025, 9, 16): "1 meal",
    DateTime.utc(2025, 9, 18): "Workout",
  };

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
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
        decoration: BoxDecoration(
          color: AppColors.primary,
        )
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
        defaultBuilder: (context, day, focusedDay) {
          final note = _dayNotes[DateTime.utc(day.year, day.month, day.day)];
          if (note != null) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("${day.day}"),
                Text(
                  note,
                  style: const TextStyle(fontSize: 10, color: Colors.green),
                  textAlign: TextAlign.center,
                ),
              ],
            );
          }
          return null; // fallback to default
        },
      ),
    );
  }
}
