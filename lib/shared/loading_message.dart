import 'package:flutter/material.dart';

Future<T> withLoading<T>(
  BuildContext context,
  Future<T> Function() future,
) async {
  // Show loading dialog
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    },
  );

  try {
    return await future();
  } finally {
    // Only pop if the context is still valid
    if (context.mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }
}
