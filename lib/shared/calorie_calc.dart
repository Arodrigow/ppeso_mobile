import 'package:ppeso_mobile/shared/content.dart';

double calorieCalculator(
  double weight,
  int height,
  int age,
  String gender,
  ExerciseLevel exerciseLevel,
  CalorieStrat calorieStrat,
) {
  double bmr = basalMetabolicRate(weight, height, age, gender);
  double tdee = adjustForActivityLevel(bmr, exerciseLevel);
  double goal = calorieGoal(tdee, calorieStrat);

  return goal;
}

double basalMetabolicRate(double weight, int height, int age, String gender) {
  if (gender == 'Male') {
    return 10 * weight + 6.25 * height - 5 * age + 5;
  }

  return 10 * weight + 6.25 * height - 5 * age + 161;
}

double adjustForActivityLevel(double bmr, ExerciseLevel exerciseLevel) {
  switch (exerciseLevel) {
    case ExerciseLevel.Sedentario:
      return bmr * 1.2;
    case ExerciseLevel.Leve:
      return bmr * 1.375;
    case ExerciseLevel.Moderado:
      return bmr * 1.55;
    case ExerciseLevel.Ativo:
      return bmr * 1.725;
    case ExerciseLevel.Muito_Ativo:
      return bmr * 1.9;
    case ExerciseLevel.Extremamente_Ativo:
      return bmr * 2.0;
    default:
      return bmr;
  }
}

double calorieGoal(double tdee, CalorieStrat calorieStrat) {
  switch (calorieStrat) {
    case CalorieStrat.Leve:
      return tdee - 250;
    case CalorieStrat.Moderado:
      return tdee - 500;
    case CalorieStrat.Extremo:
      return tdee - 1000;
    default:
      return tdee;
  }
}

class WeekGoalMinimumType {
  int weekGoal;
  int typeOneWeekGoal;

  WeekGoalMinimumType({required this.weekGoal, required this.typeOneWeekGoal});
}

WeekGoalMinimumType _weekGoalMinimum(
  int calorieGoal,
  int manterCal,
  String gender,
) {
  int weekGoal = manterCal;
  double fixedWeekGoal = calorieGoal * 7;
  int typeOneWeekGoal = ((fixedWeekGoal - (2 * manterCal)) / 5).floor();

  if (typeOneWeekGoal < 1500 && gender == 'Male') {
    typeOneWeekGoal = 1500;
    weekGoal = ((fixedWeekGoal - (typeOneWeekGoal * 5)) / 2).round();
  }

  if (typeOneWeekGoal < 1200 && gender == 'Female') {
    typeOneWeekGoal = 1200;
    weekGoal = ((fixedWeekGoal - (typeOneWeekGoal * 5)) / 2).round();
  }

  return WeekGoalMinimumType(
    weekGoal: weekGoal,
    typeOneWeekGoal: typeOneWeekGoal,
  );
}

double getDailyCal(CalorieStrat calorieStrat, int weekGoal, String gender) {
  switch (calorieStrat) {
    case CalorieStrat.Leve:
      return 500 / 6;
    case CalorieStrat.Moderado:
      return 1000 / 6;
    case CalorieStrat.Extremo:
      return gender == 'Male'
          ? (weekGoal - 10500) / 21
          : (weekGoal - 8400) / 21;
    default:
      return 0;
  }
}

List<int> _generateWeeklyCalorieCycle(
  int manterCal,
  String gender,
  CalorieStrat calorieStrat,
  int weekGoal,
) {
  int minCalories = gender == "Male" ? 1500 : 1200;
  double dailyVar = getDailyCal(calorieStrat, weekGoal, gender);

  List<int> zigzag = [
    (manterCal - dailyVar * 4).round(),
    (manterCal - dailyVar * 1).round(),
    (manterCal - dailyVar * 5).round(),
    (manterCal).round(),
    (manterCal - dailyVar * 3).round(),
    (manterCal - dailyVar * 2).round(),
    (manterCal - dailyVar * 6).round(),
  ];

  if (calorieStrat == CalorieStrat.Extremo) {
    return [
      (minCalories + dailyVar * 4).round(),
      (minCalories + dailyVar * 1).round(),
      (minCalories + dailyVar * 5).round(),
      (minCalories).round(),
      (minCalories + dailyVar * 3).round(),
      (minCalories + dailyVar * 2).round(),
      (minCalories + dailyVar * 6).round(),
    ];
  }

  return zigzag;
}

List<int> calculateZigZagCalories(
  num calorieGoal,
  double manterCal,
  String gender,
  CalorieStrat calorieStrat,
  Strategy strategy,
) {
  WeekGoalMinimumType weekGoalMin = _weekGoalMinimum(
    calorieGoal.ceil(),
    manterCal.ceil(),
    gender,
  );
  List<int> typeOne = List.filled(7, 0);
  List<int> typeTwo = List.filled(7, 0);

  for (var i = 0; i < 7; i++) {
    if (i == 0) {
      // typeOne[i] = (weekGoalMin.weekGoal * 0.75).ceil();
      typeOne[i] = (weekGoalMin.weekGoal).ceil();
    } else if (i == 6) {
      typeOne[i] = weekGoalMin.weekGoal;
    } else {
      // typeOne[i] = (weekGoalMin.typeOneWeekGoal * 1.05).ceil();
      typeOne[i] = (weekGoalMin.typeOneWeekGoal ).ceil();
    }

    typeTwo = _generateWeeklyCalorieCycle(
      manterCal.ceil(),
      gender,
      calorieStrat,
      calorieGoal.ceil() * 7,
    );
  }

  if (strategy == Strategy.ZigZag_UM) return typeOne;
  return typeTwo;
}
