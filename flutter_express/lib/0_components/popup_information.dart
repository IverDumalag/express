import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

    final themeBlue = const Color(0xFF334E7B);
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 420),
          child: AlertDialog(
            backgroundColor: themeBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.white, width: 2),
            ),
            title: Text(
              title,
              style: GoogleFonts.robotoMono(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            content: Text(
              message,
              style: GoogleFonts.robotoMono(
                color: Colors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                onPressed: closeDialog,
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                  textStyle: MaterialStateProperty.all(TextStyle(fontWeight: FontWeight.bold, fontFamily: 'RobotoMono')),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  overlayColor: MaterialStateProperty.resolveWith<Color?>((states) {
                    if (states.contains(MaterialState.hovered)) {
                      return Colors.white.withOpacity(0.15);
                    }
                    return null;
                  }),
                ),
                child: Text(buttonText, style: GoogleFonts.robotoMono(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
    timer.cancel();
  }
}
