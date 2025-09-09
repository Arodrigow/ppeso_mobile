import 'package:flutter/material.dart';
import 'package:ppeso_mobile/core/styles.dart';

class DividerPPeso extends StatelessWidget {
  const DividerPPeso({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        const Divider(
          color: AppColors.primary,
          thickness: 1,
          indent: 16,
          endIndent: 16,
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
