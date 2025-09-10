import 'package:flutter/material.dart';
import 'package:ppeso_mobile/core/styles.dart';

class TabStructure extends StatelessWidget {
  final List<Widget> children;

  const TabStructure({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.widgetBackground,
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 30,
                  bottom: 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [const SizedBox(height: 20), ...children],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
