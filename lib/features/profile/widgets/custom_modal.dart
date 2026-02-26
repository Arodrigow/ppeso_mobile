import 'package:flutter/material.dart';

class CustomModal {
  /// Show a reusable bottom sheet modal
  static Future<T?> bottomSheet<T>(
    BuildContext context, {
    required Widget child,
    bool isScrollControlled = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom, // handle keyboard
          left: 16,
          right: 16,
          top: 20,
        ),
        child: SingleChildScrollView(child: child),
      ),
    );
  }

  /// Show a reusable alert dialog
  static Future<T?> dialog<T>(
    BuildContext context, {
    required String title,
    required String message,
    String cancelText = "Cancel",
    String confirmText = "OK",
    VoidCallback? onConfirm,
  }) {
    return showDialog<T>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (onConfirm != null) onConfirm();
            },
            child: Text(confirmText),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(cancelText),
          ),
        ],
      ),
    );
  }
}
