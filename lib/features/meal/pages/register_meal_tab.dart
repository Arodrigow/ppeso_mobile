import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ppeso_mobile/core/styles.dart';
import 'package:ppeso_mobile/features/meal/models/recipe_analysis_model.dart';
import 'package:ppeso_mobile/features/meal/providers/user_recipes_provider.dart';
import 'package:ppeso_mobile/features/profile/widgets/custom_modal.dart';
import 'package:ppeso_mobile/providers/user_provider.dart';
import 'package:ppeso_mobile/shared/content.dart';
import 'package:ppeso_mobile/shared/loading_message.dart';
import 'package:ppeso_mobile/shared/requests/new_meal_requests.dart';
import 'package:ppeso_mobile/shared/requests/recipe_requests.dart';
import 'package:ppeso_mobile/shared/tab_structure.dart';

class RegisterMealTab extends ConsumerStatefulWidget {
  const RegisterMealTab({super.key});

  @override
  ConsumerState<RegisterMealTab> createState() => _RegisterMealTabState();
}

class _RegisterMealTabState extends ConsumerState<RegisterMealTab> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _recipeController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );
  NutritionAnalysisResult? _lastAnalysis;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _recipeController.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  void _clearForm() {
    setState(() {
      _titleController.clear();
      _descriptionController.clear();
      _recipeController.clear();
      _lastAnalysis = null;
    });
  }

  Future<void> _askOcrSource() async {
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Ler com camera'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _readTextFromImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Escolher da galeria'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _readTextFromImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _readTextFromImage(ImageSource source) async {
    try {
      final image = await _imagePicker.pickImage(source: source);
      if (image == null) return;
      if (!mounted) return;

      final text = await withLoading(
        context,
        () async {
          final inputImage = InputImage.fromFilePath(image.path);
          final recognized = await _textRecognizer.processImage(inputImage);
          return recognized.text.trim();
        },
      );

      if (!mounted) return;
      if (text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nenhum texto encontrado na imagem.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        final current = _recipeController.text.trim();
        _recipeController.text = current.isEmpty ? text : '$current\n\n$text';
        _recipeController.selection = TextSelection.fromPosition(
          TextPosition(offset: _recipeController.text.length),
        );
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha ao ler imagem: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _analyzeRecipe() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final recipe = _recipeController.text.trim();
    final user = ref.read(userProvider);
    final token = ref.read(authTokenProvider);
    final userId = _parseUserId(user?['id']);

    if (title.isEmpty || description.isEmpty || recipe.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fill title, description and recipe before analyzing.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (userId == null || token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid user session.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final analysisPrompt =
        'Faca a analise nutricional em portugues-BR para a seguinte receita. '
        'Titulo: $title. Descricao: $description. Receita: $recipe';

    try {
      final result = await withLoading(
        context,
        () =>
            analyzeMealText(userId: userId, token: token, text: analysisPrompt),
      );

      if (!mounted) return;
      setState(() {
        _lastAnalysis = result;
      });
      _showResultModal(result);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to analyze recipe: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _askSaveRecipe(NutritionAnalysisResult result) async {
    await CustomModal.dialog(
      context,
      title: 'Save recipe',
      message: 'Do you want to send this recipe to the database?',
      cancelText: 'No',
      confirmText: 'Yes',
      onConfirm: () async {
        try {
          final user = ref.read(userProvider);
          final token = ref.read(authTokenProvider);
          final userId = _parseUserId(user?['id']);
          if (userId == null || token == null || token.isEmpty) {
            throw Exception('Invalid user session');
          }
          final nutrition = RecipeAnalysisModel(
            calories: result.total.caloriasKcal,
            carbo: result.total.carboidratosG,
            proteins: result.total.proteinasG,
            fat: result.total.gordurasG,
            fibers: result.total.fibrasG,
          );
          final createdRecipe = await withLoading(
            context,
            () => saveRecipe(
              userId: userId,
              title: _titleController.text.trim(),
              description: _descriptionController.text.trim(),
              recipe: _recipeController.text.trim(),
              nutrition: nutrition,
              token: token,
            ),
          );

          prependRecipeToUserList(ref, createdRecipe);

          if (!mounted) return;
          final popped = await Navigator.of(context).maybePop();
          if (!mounted) return;
          if (!popped) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Recipe saved successfully.')),
            );
          }
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save recipe: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

  void _showResultModal(NutritionAnalysisResult result) {
    CustomModal.bottomSheet(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nutritional values', style: AppTextStyles.subTitle),
          const SizedBox(height: 16),
          if (result.hasWarning) ...[
            Text(result.other!, style: const TextStyle(color: Colors.orange)),
            const SizedBox(height: 10),
          ],
          _nutritionRow(
            'Calories',
            '${result.total.caloriasKcal.toStringAsFixed(2)} kcal',
          ),
          _nutritionRow(
            'Carbo',
            '${result.total.carboidratosG.toStringAsFixed(2)} g',
          ),
          _nutritionRow(
            'Proteins',
            '${result.total.proteinasG.toStringAsFixed(2)} g',
          ),
          _nutritionRow(
            'Fat',
            '${result.total.gordurasG.toStringAsFixed(2)} g',
          ),
          _nutritionRow(
            'Fibers',
            '${result.total.fibrasG.toStringAsFixed(2)} g',
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _askSaveRecipe(result);
                },
                style: ButtonStyles.defaultAcceptButton,
                child: const Text('Send to database'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _nutritionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyBold),
          Text(value, style: AppTextStyles.body),
        ],
      ),
    );
  }

  int? _parseUserId(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TabStructure(
      children: [
        Text(MealPageText.registerMealTitle, style: AppTextStyles.title),
        const SizedBox(height: 20),
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            labelText: 'Title',
            enabledBorder: TextInputStyles.enabledDefault,
            focusedBorder: TextInputStyles.focusDefault,
          ),
        ),
        const SizedBox(height: 15),
        TextFormField(
          controller: _descriptionController,
          minLines: 2,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: 'Description',
            enabledBorder: TextInputStyles.enabledDefault,
            focusedBorder: TextInputStyles.focusDefault,
          ),
        ),
        const SizedBox(height: 15),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: _askOcrSource,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              visualDensity: VisualDensity.compact,
            ),
            icon: const Icon(Icons.document_scanner, size: 18),
            label: const Text('Ler imagem'),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _recipeController,
          minLines: 6,
          maxLines: 10,
          decoration: InputDecoration(
            labelText: 'Food recipe',
            enabledBorder: TextInputStyles.enabledDefault,
            focusedBorder: TextInputStyles.focusDefault,
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: _analyzeRecipe,
              icon: const Icon(Icons.analytics),
              label: const Text('Analyze'),
              style: ButtonStyles.defaultAcceptButton,
            ),
            ElevatedButton.icon(
              onPressed: _clearForm,
              icon: const Icon(Icons.clear),
              label: const Text(ProfilePageText.clearButton),
            ),
          ],
        ),
        if (_lastAnalysis != null) ...[
          const SizedBox(height: 20),
          Text('Latest analysis available', style: AppTextStyles.description),
        ],
      ],
    );
  }
}
