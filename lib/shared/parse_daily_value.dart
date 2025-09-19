import 'package:ppeso_mobile/features/profile/models/daily_value.dart';

List<DailyValue> parseToDailyValue(List<int> values) {
  return [
    DailyValue(label: "Dom", value: values[0]),
    DailyValue(label: "Seg", value: values[1]),
    DailyValue(label: "Ter", value: values[2]),
    DailyValue(label: "Qua", value: values[3]),
    DailyValue(label: "Qui", value: values[4]),
    DailyValue(label: "Sex", value: values[5]),
    DailyValue(label: "Sáb", value: values[6]),
  ];
}
