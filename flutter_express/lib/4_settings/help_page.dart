import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'faq_item.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Color(0xFF334E7B), size: 32),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Help',
          style: GoogleFonts.poppins(
            color: const Color(0xFF334E7B),
            fontWeight: FontWeight.w700,
            fontSize: 22,
            letterSpacing: 0.2,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF334E7B),
        elevation: 0,
        surfaceTintColor: Colors.white,
        shadowColor: Colors.transparent,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Frequently Asked Questions',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF334E7B),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 15,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: ListView(
                  children: [
                    FAQItem(
                      question: 'What is exPress?',
                      answer:
                          'exPress is a mobile and web application designed to allow abled people to connect within deaf-mute communities seamlessly and vice-versa. With features like sign language to text and text/audio to sign language conversion.',
                      questionFontSize: 15,
                      answerFontSize: 13,
                    ),
                    Divider(height: 1, color: Colors.grey[100]),
                    FAQItem(
                      question: 'How does exPress work?',
                      answer:
                          'exPress works by converting sign language to text and text/audio to sign language using advanced machine learning algorithms.',
                      questionFontSize: 15,
                      answerFontSize: 13,
                    ),
                    Divider(height: 1, color: Colors.grey[100]),
                    FAQItem(
                      question: 'How can I provide feedback?',
                      answer:
                          'You can provide feedback through the feedback section in the app menu.',
                      questionFontSize: 15,
                      answerFontSize: 13,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
