import 'package:flutter/material.dart';

Future<T> withLoading<T>(
  BuildContext context,
  Future<T> Function() future,
) async {
  // Show loading dialog on root navigator so nested sheets/routes are unaffected.
  showDialog(
    context: context,
    useRootNavigator: true,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const Center(child: CircularProgressIndicator());
    },
  );

  try {
    return await future();
  } finally {
    // Always close the loading dialog, even when requests fail/throw.
    if (context.mounted) {
      final navigator = Navigator.of(context, rootNavigator: true);
      if (navigator.canPop()) {
        navigator.pop();
      }
    }
  }
}
