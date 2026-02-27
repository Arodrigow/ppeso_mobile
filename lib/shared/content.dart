class LoginText {
  static const register = 'Não possui registro? ';
  static const registerButton = 'Registrar';
  static const loginButton = 'Entrar';
}

class ProfilePageText {
  static const info = 'Informações';
  static const health = 'Estratégia';
  static const weight = 'Peso';
  static const profileTile = 'Informações pessoais';
  static const updateButton = 'Atualizar';
  static const clearButton = 'Limpar';
}

class UserTextFields {
  // Information Content
  static const name = 'Nome completo';
  static const email = 'E-mail';
  static const password = 'Senha';
  static const birthday = 'Aniversário';
  static const height = 'Altura (cm)';
  static const initWeigth = 'Peso inicial (kg)';
  static const nowWeigth = 'Peso atual (kg)';
  static const targetWeigth = 'Peso alvo (kg)';

  // Exercise levels content
  static const activityLevel = 'Nível de atividade: ';
  static const basalExercies = 'Basal';
  static const basalExerciesDesc = 'Taxa Metabólica Basal (TMB).';
  static const sedentaryExercies = 'Sedentário';
  static const sedentaryExerciesDesc = 'Pouco ou nenhum exercício.';
  static const lowExercies = 'Leve';
  static const lowExerciesDesc = 'Exercita entre 1 e 3 vezes por semana.';
  static const mediumExercies = 'Moderado';
  static const mediumExerciesDesc = 'Exercita entre 4 e 5 vezes por semana.';
  static const activeExercies = 'Ativo';
  static const activeExerciesDesc =
      'Exercício diário ou exercício intenso entre 3 e 4 vezes por semana.';
  static const veryActiveExercies = 'Muito ativo';
  static const veryActiveExerciesDesc =
      'Exercício intenso entre 5 e 7 vezes por semana.';
  static const extremeActiveExercies = 'Extremamente ativo';
  static const extremeActiveExerciesDesc =
      'Exercício superintensivo diário ou trabalho braçal.';

  // Calorie regime content
  static const colorieTiTle = 'Regime calórico: ';
  static const maintainCalories = 'Manter';
  static const maintainCaloriesDesc = 'Mantém peso';
  static const lowCalories = 'Leve';
  static const lowCaloriesDesc = '0,25 kg/semana.';
  static const moderateCalories = 'Moderado';
  static const moderateCaloriesDesc = '0,5 kg/semana.';
  static const extremeCalories = 'Extremo';
  static const extremeCaloriesDesc = '1 kg/semana.';

  // Weight loss strategy content
  static const strategyTitle = 'Estratégia: ';
  static const fixed = 'Fixo (kCal)';
  static const fixedDesc = 'Valor calórico diário fixo.';
  static const zigZag1 = 'Zig Zag fixo (kCal)';
  static const zigZag1Desc =
      'Valor calórico varia entre dia da semana e fim de semana.';
  static const zigZag2 = 'Zig Zag variável (kCal)';
  static const zigZag2Desc = 'Valor calórico varia diariamente.';
  static const sCustom = 'Customizado';
  static const sCustomDesc = 'Inserir os valores diários manualmente.';
}

class ModalText {
  static const chooseOption = 'Escolha uma opção';
  static const updateOption = 'Confirmar';
  static const cancelOption = 'Cancelar';
}

class WeightTabContent {
  static const addWeightButton = 'Adicionar peso';
  static const addDate = 'Data';
  static const addWeight = 'Peso';
  static const addWeightData = 'Adicionar';
  static const closeWeightModal = 'Cancelar';
  static const historicWeightTitle = 'Listar pesos';
}

class MealPageText {
  static const dailyNutritionTabTitle = 'Nutrição';
  static const dailyNutritionTitle = 'Resumo diário';
  static const newMealTabTitle = 'Nova';
  static const registerMealTabTitle = 'Registrar';
  static const recipesMealTabTitle = 'Receitas';
  static const newMealTitle = 'Nova refeição';
  static const registerMealTitle = 'Registrar prato';
  static const recipesMealTitle = 'Receitas cadastradas';
}

class NewMealTabText {
  static const newMealItem = 'Item';
  static const newMealItemDesc = 'Descreva seu item';
  static const newMealItemUnitTitle = 'Unidade';
  static const newMealItemValueTitle = 'Valor';
  static const newMealItemSubmitBtn = 'Enviar';
  static const newMealItemBtn = 'Adicionar item';
}

class HistoryTabText {
  static const historyTabTitle = 'Histórico';
  static const dailyMeal = 'Refeições do dia';
  static const noDailyMeal = 'Sem refeições cadastradas para hoje.';
}

enum ExerciseLevel {
  Basal,
  Sedentario,
  Leve,
  Moderado,
  Ativo,
  Muito_Ativo,
  Extremamente_Ativo,
}

extension ExerciseLeveExtensions on ExerciseLevel {
  String get title {
    switch (this) {
      case ExerciseLevel.Basal:
        return UserTextFields.basalExercies;
      case ExerciseLevel.Sedentario:
        return UserTextFields.sedentaryExercies;
      case ExerciseLevel.Leve:
        return UserTextFields.lowExercies;
      case ExerciseLevel.Moderado:
        return UserTextFields.mediumExercies;
      case ExerciseLevel.Ativo:
        return UserTextFields.activeExercies;
      case ExerciseLevel.Muito_Ativo:
        return UserTextFields.veryActiveExercies;
      case ExerciseLevel.Extremamente_Ativo:
        return UserTextFields.extremeActiveExercies;
    }
  }

  String get description {
    switch (this) {
      case ExerciseLevel.Basal:
        return UserTextFields.basalExerciesDesc;
      case ExerciseLevel.Sedentario:
        return UserTextFields.sedentaryExerciesDesc;
      case ExerciseLevel.Leve:
        return UserTextFields.lowExerciesDesc;
      case ExerciseLevel.Moderado:
        return UserTextFields.mediumExerciesDesc;
      case ExerciseLevel.Ativo:
        return UserTextFields.activeExerciesDesc;
      case ExerciseLevel.Muito_Ativo:
        return UserTextFields.veryActiveExerciesDesc;
      case ExerciseLevel.Extremamente_Ativo:
        return UserTextFields.extremeActiveExerciesDesc;
    }
  }
}

enum CalorieStrat { Manter, Leve, Moderado, Extremo }

extension CalorieStratExtensions on CalorieStrat {
  String get title {
    switch (this) {
      case CalorieStrat.Manter:
        return UserTextFields.maintainCalories;
      case CalorieStrat.Leve:
        return UserTextFields.lowCalories;
      case CalorieStrat.Moderado:
        return UserTextFields.moderateCalories;
      case CalorieStrat.Extremo:
        return UserTextFields.extremeCalories;
    }
  }

  String get description {
    switch (this) {
      case CalorieStrat.Manter:
        return UserTextFields.maintainCaloriesDesc;
      case CalorieStrat.Leve:
        return UserTextFields.lowCaloriesDesc;
      case CalorieStrat.Moderado:
        return UserTextFields.moderateCaloriesDesc;
      case CalorieStrat.Extremo:
        return UserTextFields.extremeCaloriesDesc;
    }
  }
}

enum Strategy { Fixo, ZigZag_UM, ZigZag_DOIS, sCustom }

extension StrategyExtensions on Strategy {
  String get title {
    switch (this) {
      case Strategy.ZigZag_UM:
        return UserTextFields.zigZag1;
      case Strategy.ZigZag_DOIS:
        return UserTextFields.zigZag2;
      case Strategy.sCustom:
        return UserTextFields.sCustom;
      default:
        return UserTextFields.fixed;
    }
  }

  String get description {
    switch (this) {
      case Strategy.ZigZag_UM:
        return UserTextFields.zigZag1Desc;
      case Strategy.ZigZag_DOIS:
        return UserTextFields.zigZag2Desc;
      case Strategy.sCustom:
        return UserTextFields.sCustomDesc;
      default:
        return UserTextFields.fixedDesc;
    }
  }
}

enum Measurements {
  grams,
  kilograms,
  miligram,
  litter,
  milliliter,
  teaSpn,
  dessertSpn,
  tableSpn,
  cup,
  pinch,
  portion,
  unit,
}

class MealMeasurementsText {
  static const grams = 'g';
  static const kilograms = 'kg';
  static const miligram = 'mg';
  static const litter = 'l';
  static const milliliter = 'ml';
  static const teaSpn = 'Colher de chá';
  static const dessertSpn = 'Colher de sobremesa';
  static const tableSpn = 'Colher de sopa';
  static const cup = 'Copo americano';
  static const pinch = 'Pitada';
  static const portion = 'Porção';
  static const unit = 'Unidade';
}

extension MeasurementsExtensions on Measurements {
  String get title {
    switch (this) {
      case Measurements.kilograms:
        return MealMeasurementsText.kilograms;
      case Measurements.miligram:
        return MealMeasurementsText.miligram;
      case Measurements.litter:
        return MealMeasurementsText.litter;
      case Measurements.milliliter:
        return MealMeasurementsText.milliliter;
      case Measurements.teaSpn:
        return MealMeasurementsText.teaSpn;
      case Measurements.dessertSpn:
        return MealMeasurementsText.dessertSpn;
      case Measurements.tableSpn:
        return MealMeasurementsText.tableSpn;
      case Measurements.cup:
        return MealMeasurementsText.cup;
      case Measurements.pinch:
        return MealMeasurementsText.pinch;
      case Measurements.portion:
        return MealMeasurementsText.portion;
      case Measurements.unit:
        return MealMeasurementsText.unit;
      default:
        return MealMeasurementsText.grams;
    }
  }
}

