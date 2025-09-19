int calculateAge(String birthdayString) {
  final birthDate = DateTime.parse(birthdayString);
  final now = DateTime.now();

  int age = now.year - birthDate.year;

  if (now.month < birthDate.month ||
      (now.month == birthDate.month && now.day < birthDate.day)) {
    age--;
  }
  return age;
}
