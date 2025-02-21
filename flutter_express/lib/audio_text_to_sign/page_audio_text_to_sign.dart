import 'package:flutter/material.dart';

class AudioTextToSignPage extends StatefulWidget {
  @override
  _AudioTextToSignPageState createState() => _AudioTextToSignPageState();
}

class _AudioTextToSignPageState extends State<AudioTextToSignPage> {
  List<String> _userInputs = [];
  String _currentInput = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set the background color to white
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: ListView.builder(
                    reverse: true,
                    itemCount: _userInputs.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            _currentInput,
                            style: TextStyle(
                              fontSize: 50,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                        );
                      } else {
                        int reversedIndex = _userInputs.length - index;
                        return Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            _userInputs[reversedIndex],
                            style: TextStyle(
                              fontSize: 30,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
                SizedBox(height: 15), // Add extra space below the text and icon
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.mic, color: Colors.grey, size: 55),
                    SizedBox(height: 8),
                    Text(
                      'Tap to speak',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        fontSize: 35, // Adjust the font size as needed
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20), // Add extra space below the text and icon
                Padding(
                  padding: const EdgeInsets.only(bottom: 40.0), // Move the TextField up
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: (text) {
                        setState(() {
                          _currentInput = text;
                        });
                      },
                      onSubmitted: (text) {
                        setState(() {
                          _userInputs.add(text);
                          _currentInput = '';
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Type to say something',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: IconButton(
              icon: Icon(Icons.help, size: 30, color: Color(0xFF334E7B)), // Changed to filled icon
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('How to Use'),
                      content: Text(
                        '1. Tap the microphone icon to start speaking.\n'
                        '2. Your speech will be converted to text and displayed on the screen.\n'
                        '3. The translation of your speech will appear in the output container below.',
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: Text('Close'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}