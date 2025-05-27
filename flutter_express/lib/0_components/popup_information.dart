import 'dart:async';
import 'package:flutter/material.dart';

class PopupInformation {
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = "OK",
    Duration autoClose = const Duration(seconds: 5),
    VoidCallback? onOk,
  }) async {
    Timer? timer;
    bool closed = false;

    void closeDialog() {
      if (!closed) {
        closed = true;
        Navigator.of(context, rootNavigator: true).pop();
        if (onOk != null) onOk();
      }
    }

    timer = Timer(autoClose, closeDialog);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: TextStyle(color: Color(0xFF334E7B))),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: closeDialog,
            child: Text(
              buttonText,
              style: TextStyle(
                color: Color(0xFF334E7B),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    timer.cancel();
  }
}
