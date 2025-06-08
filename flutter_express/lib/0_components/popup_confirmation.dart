import 'package:flutter/material.dart';

class PopupConfirmation {
  /// Shows a confirmation dialog with customizable title, message, and actions.
  /// Returns true if confirmed, false if cancelled or dismissed.
  static Future<bool> show(
    BuildContext context, {
    String title = "Confirmation",
    String message = "Are you sure?",
    String confirmText = "Confirm",
    String cancelText = "Cancel",
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: TextStyle(color: Color(0xFF334E7B))),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(cancelText, style: TextStyle(color: Colors.grey[700])),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              confirmText,
              style: TextStyle(color: Color(0xFF2E5C9A)),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
      ),
    );
    return result ?? false;
  }
}
