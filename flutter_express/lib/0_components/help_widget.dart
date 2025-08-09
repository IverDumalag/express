import 'package:flutter/material.dart';

class HelpIconWidget extends StatelessWidget {
  final String helpTitle;
  final String helpText;

  const HelpIconWidget({
    Key? key,
    required this.helpTitle,
    required this.helpText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.help, size: 30, color: Color(0xFF334E7B)),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
              side: BorderSide(
                color: Color(0xFF334E7B),
                width: 2,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 8,
            title: Text(
              helpTitle,
              style: TextStyle(
                color: Color(0xFF334E7B),
                fontFamily: 'RobotoMono',
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
            content: Text(
              helpText,
              style: TextStyle(
                color: Color(0xFF334E7B),
                fontFamily: 'RobotoMono',
                fontWeight: FontWeight.w500,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK', style: TextStyle(color: Color(0xFF2E5C9A), fontFamily: 'RobotoMono', fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        );
      },
    );
  }
}
