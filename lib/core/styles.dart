import 'package:flutter/material.dart';

class AppTextStyles {
  static const ppesoTitle = TextStyle(
    fontSize: 44,
    color: Color.fromARGB(255, 54, 54, 54),
    fontWeight: FontWeight.bold,
  );
  static const title = TextStyle(
    fontSize: 22,
    color: Color.fromARGB(255, 54, 54, 54),
    fontWeight: FontWeight.bold,
  );
  static const subTitle = TextStyle(
    fontSize: 22,
    color: Color.fromARGB(255, 54, 54, 54),
    fontWeight: FontWeight.w500,
  );
  static const body = TextStyle(
    fontSize: 16,
    color: Color.fromARGB(255, 54, 54, 54),
  );
}

class AppColors {
  static const primary = Color(0xFF087f8a);
  static const accent = Color(0xFF08d4a5);
  static const appBackground = Color.fromARGB(255, 218, 255, 243);
  static const widgetBackground = Colors.white;
}

class TextInputStyles {
  static final enabledDefault = OutlineInputBorder(
    borderSide: BorderSide(color: AppColors.primary, width: 1),
    borderRadius: BorderRadius.circular(20),
  );

  static final focusDefault = OutlineInputBorder(
    borderSide: BorderSide(color: AppColors.accent, width: 1),
    borderRadius: BorderRadius.circular(20),
  );
}

class ButtonStyles {
  static final defaultAcceptButton = ButtonStyle(
    backgroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.hovered)) return AppColors.accent;
      if (states.contains(WidgetState.pressed)) return AppColors.accent;
      return AppColors.primary; // default
    }),
    foregroundColor: WidgetStateProperty.resolveWith((states) => Colors.white),
  );
}
