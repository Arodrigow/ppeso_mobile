import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppeso_mobile/core/styles.dart';
import 'package:ppeso_mobile/providers/user_provider.dart';

class LogoutButton extends ConsumerWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      onPressed: () async {
        await clearSession(ref);
        if (context.mounted) {
          context.replace('/login');
        }
      },
      icon: const Icon(Icons.logout),
      style: ButtonStyle(
        iconColor: WidgetStateProperty.all(AppColors.appBackground),
      ),
    );
  }
}
