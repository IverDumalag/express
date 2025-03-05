import 'package:flutter/material.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({Key? key}) : super(key: key);

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  // Keep track of which rating is selected. Let's default to "Satisfied" (index 3).
  int _selectedIndex = 3;

  // A controller for the comments TextField
  final TextEditingController _commentController = TextEditingController();

  // You can adjust the labels to match your preferred text
  final List<String> _ratingLabels = [
    'Very Dissatisfied',
    'Dissatisfied',
    'Neutral',
    'Satisfied',
    'Very Satisfied',
  ];

  // Corresponding icons from Flutter's Material library
  final List<IconData> _ratingIcons = [
    Icons.sentiment_very_dissatisfied,
    Icons.sentiment_dissatisfied,
    Icons.sentiment_neutral,
    Icons.sentiment_satisfied,
    Icons.sentiment_very_satisfied,
  ];

  // Some colors for each icon (optional)
  final List<Color> _ratingColors = [
    Colors.red,
    Colors.orange,
    Colors.amber,
    Colors.lightGreen,
    Colors.green,
  ];

  @override
  Widget build(BuildContext context) {
    final currentColor = _ratingColors[_selectedIndex];
    final currentLabel = _ratingLabels[_selectedIndex];
    final currentIcon = _ratingIcons[_selectedIndex];

    return Scaffold(
      backgroundColor: Colors.white, // Set the background of the page to white
      appBar: AppBar(
        title: const Text(
          'Feedback',
          style: TextStyle(
            fontFamily: 'Inter',
            color: Color.fromARGB(255, 0, 0, 0), // Set text color to white
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color.fromARGB(
                  255, 0, 0, 0)), // Set arrow back color to white
          onPressed: () {
            Navigator.pop(context); // Handle back navigation
          },
        ),
        backgroundColor: const Color.fromARGB(
            255, 255, 255, 255), // Set the app bar color to 0xFF334E7B
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Large icon and label for the currently selected rating
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  currentIcon,
                  color: currentColor,
                  size: 80,
                ),
                const SizedBox(height: 8),
                Text(
                  currentLabel,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 20,
                    color: currentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Row of smaller icons that the user can tap to select rating
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(_ratingIcons.length, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  child: Column(
                    children: [
                      Icon(
                        _ratingIcons[index],
                        color: _ratingColors[index],
                        size: 40,
                      ),
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),

            // "Help us improve" text
            Text(
              'Help us to improve',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontFamily: 'Inter',
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 8),

            // Comment TextField with modern look
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _commentController,
                decoration: const InputDecoration(
                  hintText: 'Comment here...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16.0),
                ),
                maxLines: 4,
                style: const TextStyle(fontFamily: 'Inter'),
              ),
            ),
            const SizedBox(height: 24),

            // Submit button
            ElevatedButton(
              onPressed: () {
                // Handle submit action
                // You can read _selectedIndex for rating,
                // and _commentController.text for user comment
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Submitted: ${_ratingLabels[_selectedIndex]} - '
                      'Comment: ${_commentController.text}',
                      style: const TextStyle(fontFamily: 'Inter'),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(
                    0xFF334E7B), // Set the button color to 0xFF334E7B
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12.0), // Set border radius
                ),
                elevation: 5, // Add drop shadow
                shadowColor: Colors.grey.withOpacity(0.5), // Set shadow color
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                child: Text(
                  'Submit',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: Colors.white, // Set text color to white
                    fontWeight: FontWeight.w900, // Set text to bold
                    fontSize: 20.0, // Increase text size
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
