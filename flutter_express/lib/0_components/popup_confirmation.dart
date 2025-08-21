import 'package:flutter/material.dart';

class PopupConfirmation {
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
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Color(0xFF334E7B),
            width: 2,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'RobotoMono',
            fontWeight: FontWeight.bold,
            color: Color(0xFF334E7B),
            fontSize: 22,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'RobotoMono',
            color: Color(0xFF334E7B),
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              cancelText,
              style: const TextStyle(
                fontFamily: 'RobotoMono',
                color: Color(0xFF334E7B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF334E7B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontFamily: 'RobotoMono',
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
