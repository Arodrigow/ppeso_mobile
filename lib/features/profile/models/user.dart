import 'package:ppeso_mobile/shared/content.dart';

class User {
  int id;
  String email;
  String nome;
  String sobrenome;
  String aniversario;
  double pesoInit;
  double pesoNow;
  double pesoTarget;
  int altura;
  ExerciseLevel atividade;
  String role;
  CalorieStrat regimeCalorico;
  Strategy estrategia;
  String gender;
  int version;
  String createdAt;

  User({
    this.id = 0,
    this.email = '',
    this.nome = '',
    this.sobrenome = '',
    this.aniversario = '',
    this.pesoInit = 0.0,
    this.pesoNow = 0.0,
    this.pesoTarget = 0.0,
    this.altura = 0,
    this.atividade = ExerciseLevel.Basal,
    this.role = '',
    this.regimeCalorico = CalorieStrat.Manter,
    this.estrategia = Strategy.Fixo,
    this.gender = '',
    this.version = 0,
    this.createdAt = '',
  });

  /// Factory constructor to parse JSON into User
  factory User.fromJson(Map<String, dynamic>? json) {
    if (json == null) return User();

    return User(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      nome: json['nome'] ?? '',
      sobrenome: json['sobrenome'] ?? '',
      aniversario: json['aniversario'] ?? '',
      pesoInit: (json['peso_init'] is num) ? (json['peso_init']).toDouble() : 0.0,
      pesoNow: (json['peso_now'] is num) ? (json['peso_now']).toDouble() : 0.0,
      pesoTarget: (json['peso_target'] is num) ? (json['peso_target']).toDouble() : 0.0,
      altura: json['altura'] ?? 0,
      atividade: ExerciseLevel.values.firstWhere(
        (e) => e.toString().split('.').last == json['atividade'],
        orElse: () => ExerciseLevel.Basal,
      ),
      role: json['role'] ?? '',
      regimeCalorico: CalorieStrat.values.firstWhere(
        (e) => e.toString().split('.').last == json['regime_calorico'],
        orElse: () => CalorieStrat.Manter,
      ),
      estrategia: Strategy.values.firstWhere(
        (e) => e.toString().split('.').last == json['estrategia'],
        orElse: () => Strategy.Fixo,
      ),
      gender: json['gender'] ?? '',
      version: json['version'] ?? 0,
      createdAt: json['created_at'] ?? '',
    );
  }

  /// Optional: Convert back to JSON (for updates / API requests)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nome': nome,
      'sobrenome': sobrenome,
      'aniversario': aniversario,
      'peso_init': pesoInit,
      'peso_now': pesoNow,
      'peso_target': pesoTarget,
      'altura': altura,
      'atividade': atividade.toString().split('.').last,
      'role': role,
      'regime_calorico': regimeCalorico.toString().split('.').last,
      'estrategia': estrategia.toString().split('.').last,
      'gender': gender,
      'version': version,
      'created_at': createdAt,
    };
  }

  User copyWith({
  int? id,
  String? email,
  String? nome,
  String? sobrenome,
  String? aniversario,
  double? pesoInit,
  double? pesoNow,
  double? pesoTarget,
  int? altura,
  ExerciseLevel? atividade,
  String? role,
  CalorieStrat? regimeCalorico,
  Strategy? estrategia,
  String? gender,
  int? version,
  String? createdAt,
  }){
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      nome: nome ?? this.nome,
      sobrenome: sobrenome ?? this.sobrenome,
      aniversario: aniversario ?? this.aniversario,
      pesoInit: pesoInit ?? this.pesoInit,
      pesoNow: pesoNow ?? this.pesoNow,
      pesoTarget: pesoTarget ?? this.pesoTarget,
      altura: altura ?? this.altura,
      atividade: atividade ?? this.atividade,
      role: role ?? this.role,
      regimeCalorico: regimeCalorico ?? this.regimeCalorico,
      estrategia: estrategia ?? this.estrategia,
      gender: gender ?? this.gender,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
