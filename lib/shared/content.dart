class LoginText {
  static const register = 'Não possui registo? ';
  static const registerButton = 'Registrar';
  static const loginButton = 'Entrar';
}

class ProfilePageText {
  static const info = "Informações";
  static const health = "Estratégia";
  static const weight = "Peso";
  static const profileTile = "Informações pessoais";
  static const updateButton = 'Atualizar';
  static const clearButton = 'Limpar';
}

class UserTextFields {
  //Information Content
  static const name = 'Nome Completo';
  static const email = 'Email';
  static const password = 'Senha';
  static const birthday = "Aniversário";
  static const height = "Altura (cm)";
  //Strategy Content
  static const strategyTitle = "";
  //Exercise levels content
  static const activityLevel = "Nível de atividade";
  static const basalExercies = "Basal";
  static const basalExerciesDesc = "Taxa Metabólica Basal (TMB).";
  static const sedentaryExercies = "Sedentário";
  static const sedentaryExerciesDesc = "Pouco ou nenhum exercício.";
  static const lowExercies = "Leve";
  static const lowExerciesDesc = "Exercita entre 1 e 3 vezes por semana.";
  static const mediumExercies = "Moderado";
  static const mediumExerciesDesc = "Exercita entre 4 e 5 vezes por semana.";
  static const activeExercies = "Ativo";
  static const activeExerciesDesc =
      "Exercício diário ou exercício intenso entre 3 e 4 vezes por semana.";
  static const veryActiveExercies = "Muito Ativo";
  static const veryActiveExerciesDesc =
      "Exercício intenso entre 5 e 7 vezes por semana.";
  static const extremeActiveExercies = "Extremamente Ativo";
  static const extremeActiveExerciesDesc =
      "Exercício super intensivo diário ou trabalho braçal.";
  //Calorie regime content
  static const colorieTiTle = "Regime calórico";
  static const maintainCalories = "Manter";
  static const maintainCaloriesDesc = "Mantém peso";
  static const lowCalories = "Leve";
  static const lowCaloriesDesc = "0,25 kg/semana.";
  static const moderateCalories = "Moderado";
  static const moderateCaloriesDesc = "0,5 kg/semana.";
  static const extremeCalories = "Moderado";
  static const extremeCaloriesDesc = "1 kg/semana.";
}

enum ExerciseLevel {
  basal,
  sedentario,
  leve,
  moderado,
  ativo,
  muitoAtivo,
  extremamenteAtivo,
}

extension ExerciseLeveExtensions on ExerciseLevel {
  String get title {
    switch (this) {
      case ExerciseLevel.basal:
        return UserTextFields.basalExercies;
      case ExerciseLevel.sedentario:
        return UserTextFields.sedentaryExercies;
      case ExerciseLevel.leve:
        return UserTextFields.lowExercies;
      case ExerciseLevel.moderado:
        return UserTextFields.mediumExercies;
      case ExerciseLevel.ativo:
        return UserTextFields.activeExercies;
      case ExerciseLevel.muitoAtivo:
        return UserTextFields.veryActiveExercies;
      case ExerciseLevel.extremamenteAtivo:
        return UserTextFields.extremeActiveExercies;
    }
  }

    String get description {
    switch (this) {
      case ExerciseLevel.basal:
        return UserTextFields.basalExerciesDesc;
      case ExerciseLevel.sedentario:
        return UserTextFields.sedentaryExerciesDesc;
      case ExerciseLevel.leve:
        return UserTextFields.lowExerciesDesc;
      case ExerciseLevel.moderado:
        return UserTextFields.mediumExerciesDesc;
      case ExerciseLevel.ativo:
        return UserTextFields.activeExerciesDesc;
      case ExerciseLevel.muitoAtivo:
        return UserTextFields.veryActiveExerciesDesc;
      case ExerciseLevel.extremamenteAtivo:
        return UserTextFields.extremeActiveExerciesDesc;
    }
  }
}


enum CalorieStrat {
  manter,
  leve,
  moderado,
  extremo
}

extension CalorieStratExtensions on CalorieStrat {
  String get title {
    switch (this) {
      case CalorieStrat.manter:
        return UserTextFields.maintainCalories;
      case CalorieStrat.leve:
        return UserTextFields.lowCalories;
      case CalorieStrat.moderado:
        return UserTextFields.moderateCalories;
      case CalorieStrat.extremo:
        return UserTextFields.extremeCalories;
    }
  }

    String get description {
    switch (this) {
      case CalorieStrat.manter:
        return UserTextFields.maintainCaloriesDesc;
      case CalorieStrat.leve:
        return UserTextFields.lowCaloriesDesc;
      case CalorieStrat.moderado:
        return UserTextFields.moderateCaloriesDesc;
      case CalorieStrat.extremo:
        return UserTextFields.extremeActiveExerciesDesc;
    }
  }
}