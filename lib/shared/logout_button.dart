import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:ppeso_mobile/core/styles.dart';
import 'package:ppeso_mobile/providers/user_provider.dart';

class LogoutButton extends ConsumerWidget  {
  const LogoutButton({super.key});
  
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const storage = FlutterSecureStorage();
    return IconButton(
      onPressed: () async {
        await loadSession(ref);
        await storage.delete(key: 'auth_token');
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
