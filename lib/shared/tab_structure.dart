import 'package:flutter/material.dart';
import 'package:ppeso_mobile/core/styles.dart';

class TabStructure extends StatelessWidget {
  final List<Widget> children;

  const TabStructure({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.widgetBackground,
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: children,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
