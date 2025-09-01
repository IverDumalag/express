import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          '''What is exPress?
- exPress is a mobile and web-based communication tool that translates sign language into text and text or audio into sign language animations, helping bridge conversations between deaf-mute individuals and non-signers.

Is exPress an e-learning app?
- No. exPress is not an e-learning platform. Its main purpose is to support real-time communication, not structured teaching.

Which languages does exPress support?
- Currently, exPress supports international sign language datasets from Kaggle and Filipino Sign Language (FSL) data from Mendeley. More sign languages will be added in future updates.

Do I need internet access to use exPress?
- Most features require internet to ensure accuracy, but we are working on adding offline capabilities in upcoming versions.

How accurate is exPress?
- exPress uses machine learning trained on both international and Filipino datasets. While accuracy improves with each update, variations in signing style may affect results.

How can I send feedback?
- You can easily share feedback through the Feedback Section in the app menu. We welcome your ideas to improve exPress.

Does exPress work on all devices?
- exPress is designed to run on most modern Android as well as web browsers. Some older devices may have limited functionality due to camera or processing restrictions.

Will exPress work in low-light environments?
- For best results, use the app in good lighting. Poor lighting may affect gesture recognition accuracy, but improvements are being developed to handle more conditions.

Can exPress be used in schools or workplaces?
- Yes. exPress is a communication support tool that can help in classrooms, offices, healthcare, and public service settings where inclusive interaction is needed.

How often is the app updated?
- The development team regularly releases updates to improve accuracy, add new features, and expand language support. Make sure to keep your app updated for the best experience.''',
          style: GoogleFonts.robotoMono(
            fontSize: 15,
            color: Colors.blueGrey[800],
            height: 1.5,
          ),
        ),
      ),
    );
  }
}
