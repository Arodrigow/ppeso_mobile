class RecipeAnalysisModel {
  final double calories;
  final double carbo;
  final double proteins;
  final double fat;
  final double fibers;

  const RecipeAnalysisModel({
    required this.calories,
    required this.carbo,
    required this.proteins,
    required this.fat,
    required this.fibers,
  });

  factory RecipeAnalysisModel.fromJson(Map<String, dynamic> json) {
    return RecipeAnalysisModel(
      calories: _toDouble(json['calories']),
      carbo: _toDouble(json['carbo']),
      proteins: _toDouble(json['proteins']),
      fat: _toDouble(json['fat']),
      fibers: _toDouble(json['fibers']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'carbo': carbo,
      'proteins': proteins,
      'fat': fat,
      'fibers': fibers,
    };
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}
