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
  //Exercise levels content
  static const activityLevel = "Nível de atividade: ";
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
  static const colorieTiTle = "Regime calórico: ";
  static const maintainCalories = "Manter";
  static const maintainCaloriesDesc = "Mantém peso";
  static const lowCalories = "Leve";
  static const lowCaloriesDesc = "0,25 kg/semana.";
  static const moderateCalories = "Moderado";
  static const moderateCaloriesDesc = "0,5 kg/semana.";
  static const extremeCalories = "Extremo";
  static const extremeCaloriesDesc = "1 kg/semana.";
  //Weight loss strategy content
  static const strategyTitle = "Estratégia: ";
  static const fixed = "Fixo (kCal)";
  static const fixedDesc = "Valor calórico diário fixo.";
  static const zigZag1 = "Zig Zag Fixo (kCal)";
  static const zigZag1Desc = "Valor calórico varia entre dia da semana e fim de semana.";
  static const zigZag2 = "Zig Zag Variável (kCal)";
  static const zigZag2Desc = "Valor calórico varia diariamente.";
  static const sCustom = "Customizado";
  static const sCustomDesc = "Entrar os valores diários manualmente.";

}

class ModalText {
  static const chooseOption = "Escolha uma opção";
  static const updateOption = "Confirmar";
  static const cancelOption = "Cancelar";
}

class WeightTabContent {
  static const addWeightButton = "Adicionar ppeso";
  static const addDate = "Data";
  static const addWeight= "PPeso";
  static const addWeightData= "Adicionar";
  static const closeWeightModal= "Cancelar";
  static const historicWeightTitle= "Listar ppesos";
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

enum CalorieStrat { manter, leve, moderado, extremo }

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
        return UserTextFields.extremeCaloriesDesc;
    }
  }
}

enum Strategy { fixo, zigZag1, zigZag2, sCustom }

extension StrategyExtensions on Strategy {
  String get title {
    switch (this) {
      case Strategy.zigZag1:
        return UserTextFields.zigZag1;
      case Strategy.zigZag2:
        return UserTextFields.zigZag2;
      case Strategy.sCustom:
        return UserTextFields.sCustom;
      default:
        return UserTextFields.fixed;
    }
  }

  String get description {
    switch (this) {
      case Strategy.zigZag1:
        return UserTextFields.zigZag1Desc;
      case Strategy.zigZag2:
        return UserTextFields.zigZag2Desc;
      case Strategy.sCustom:
        return UserTextFields.sCustomDesc;
      default:
        return UserTextFields.fixedDesc;
    }
  }
}
