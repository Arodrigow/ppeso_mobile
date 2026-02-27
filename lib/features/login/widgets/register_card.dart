import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:ppeso_mobile/core/styles.dart';
import 'package:ppeso_mobile/shared/content.dart';
import 'package:ppeso_mobile/shared/loading_message.dart';

class RegisterCard extends ConsumerStatefulWidget {
  const RegisterCard({super.key});

  @override
  ConsumerState<RegisterCard> createState() => _RegisterCardState();
}

class _RegisterCardState extends ConsumerState<RegisterCard> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final surnameController = TextEditingController();
  final weightController = TextEditingController();
  final targetWeightController = TextEditingController();
  final heightController = TextEditingController();
  final invitationController = TextEditingController();
  final birthdayController = TextEditingController();

  String _selectedGender = 'Male';
  ExerciseLevel _selectedActivity = ExerciseLevel.Basal;
  DateTime? _birthday;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    surnameController.dispose();
    weightController.dispose();
    targetWeightController.dispose();
    heightController.dispose();
    invitationController.dispose();
    birthdayController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthday() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1900, 1, 1),
      lastDate: DateTime.now(),
    );

    if (picked == null) return;

    setState(() {
      _birthday = picked;
      birthdayController.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    });
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_birthday == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione a data de nascimento.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final birthdayIso =
        '${_birthday!.year.toString().padLeft(4, '0')}-${_birthday!.month.toString().padLeft(2, '0')}-${_birthday!.day.toString().padLeft(2, '0')}';

    final payload = {
      'email': emailController.text.trim(),
      'password': passwordController.text,
      'nome': nameController.text.trim(),
      'sobrenome': surnameController.text.trim(),
      'gender': _selectedGender,
      'aniversario': birthdayIso,
      'peso_init': double.parse(weightController.text.replaceAll(',', '.')),
      'peso_now': double.parse(weightController.text.replaceAll(',', '.')),
      'peso_target': double.parse(
        targetWeightController.text.replaceAll(',', '.'),
      ),
      'altura': int.parse(heightController.text),
      'atividade': _selectedActivity.name,
      'convite': invitationController.text.trim(),
      'captchaToken': dotenv.env['CAPTCHA_TOKEN'] ?? 'mobile-client',
    };

    try {
      final apiUrl =
          dotenv.env['NEXT_PUBLIC_API_URL'] ?? dotenv.env['API_URL'] ?? '';
      final response = await withLoading(
        context,
        () => http.post(
          Uri.parse('$apiUrl/user'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        ),
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cadastro realizado com sucesso.')),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Falha no cadastro: ${response.body}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro no cadastro: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      enabledBorder: TextInputStyles.enabledDefault,
      focusedBorder: TextInputStyles.focusDefault,
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obrigatório';
    }
    return null;
  }

  String? _numberValidator(String? value) {
    if (_requiredValidator(value) != null) return 'Campo obrigatório';
    final normalized = value!.replaceAll(',', '.');
    if (double.tryParse(normalized) == null) {
      return 'Número inválido';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(18),
      color: AppColors.widgetBackground,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                children: [
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('Voltar'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'REGISTRAR',
                style: AppTextStyles.ppesoTitle.copyWith(fontSize: 42),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration('E-mail'),
                validator: _requiredValidator,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: _inputDecoration('Senha'),
                validator: _requiredValidator,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: nameController,
                decoration: _inputDecoration('Nome'),
                validator: _requiredValidator,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: surnameController,
                decoration: _inputDecoration('Sobrenome'),
                validator: _requiredValidator,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _selectedGender,
                decoration: _inputDecoration('Sexo'),
                items: const [
                  DropdownMenuItem(value: 'Male', child: Text('Masculino')),
                  DropdownMenuItem(value: 'Female', child: Text('Feminino')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedGender = value);
                  }
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: birthdayController,
                readOnly: true,
                onTap: _pickBirthday,
                decoration: _inputDecoration(
                  'Aniversário',
                ).copyWith(suffixIcon: const Icon(Icons.calendar_month)),
                validator: _requiredValidator,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: weightController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: _inputDecoration('Peso (kg)'),
                validator: _numberValidator,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: targetWeightController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: _inputDecoration('Peso alvo (kg)'),
                validator: _numberValidator,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: heightController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('Altura (cm)'),
                validator: (value) {
                  if (_requiredValidator(value) != null) {
                    return 'Campo obrigatório';
                  }
                  if (int.tryParse(value!) == null) return 'Número inválido';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<ExerciseLevel>(
                initialValue: _selectedActivity,
                decoration: _inputDecoration('Nível de atividade física'),
                items: ExerciseLevel.values
                    .map(
                      (level) => DropdownMenuItem(
                        value: level,
                        child: Text(level.title),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedActivity = value);
                  }
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: invitationController,
                decoration: _inputDecoration('Convite'),
                validator: _requiredValidator,
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _register,
                  style: ButtonStyles.defaultAcceptButton,
                  child: const Text('Registrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


