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
            title: Text(helpTitle),
            content: Text(helpText),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }
}
