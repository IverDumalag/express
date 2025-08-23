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
        centerTitle: true,
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
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FAQPage(),
                              ),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Frequently Asked Questions',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF334E7B),
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: Color(0xFF334E7B)),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                        Divider(height: 1, color: Color(0xFF334E7B)),
                        SizedBox(height: 16),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HowToUsePage(),
                              ),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'How to use exPress?',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF334E7B),
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: Color(0xFF334E7B)),
                            ],
                          ),
                        ),
          ],
        ),
      ),
    );
  }
}

// FAQ Page
class FAQPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Color(0xFF334E7B), size: 32),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'FAQ',
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
        
            const SizedBox(height: 20),
            Text(
              'Q: What is exPress?\nA: exPress is a mobile and web application designed to allow abled people to connect within deaf-mute communities seamlessly and vice-versa. With features like sign language to text and text/audio to sign language conversion.\n\nQ: How does exPress work?\nA: exPress works by converting sign language to text and text/audio to sign language using advanced machine learning algorithms.\n\nQ: How can I provide feedback?\nA: You can provide feedback through the feedback section in the app menu.',
              style: GoogleFonts.robotoMono(
                fontSize: 15,
                color: Colors.blueGrey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// How To Use Page
class HowToUsePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Color(0xFF334E7B), size: 32),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'How to use exPress',
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
            
            const SizedBox(height: 20),
            Text(
              'To use exPress, simply navigate through the app menu to access features like sign language to text, text/audio to sign language, and more. Each feature provides on-screen instructions for ease of use.',
              style: GoogleFonts.robotoMono(
                fontSize: 15,
                color: Colors.blueGrey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
