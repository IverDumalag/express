import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Color(0xFF334E7B), size: 32),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'About',
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
            // App Information
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AppInfoPage(),
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'App Information',
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
            
            // About Us
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AboutUsPage(),
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'About Us',
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
            
            // Privacy Policy
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PrivacyPolicyPage(),
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Privacy Policy',
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
            
            // Terms & Conditions
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TermsConditionsPage(),
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Terms',
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

// App Information Page
class AppInfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Color(0xFF334E7B), size: 32),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'App Information',
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
           
            const SizedBox(height: 20),
            Text(
              'Version: 1.0.0\nBuild Number: basta number d2 \nRelease Date: Di ko pa sure\n\nexPress is a communication app designed to bridge the gap between the deaf-mute community and the general public. It offers real-time speech-to-text and text-to-speech functionalities, making conversations seamless and inclusive.\n\nFor support or inquiries, contact us at @exPress@gmail.com',
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

// About Us Page
class AboutUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Color(0xFF334E7B), size: 32),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'About Us',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              'BEHIND EXPRESS',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[900],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'We are the team behind exPress— Alyssa, Aisha, and Iver, a group of developers, innovators, and advocates for inclusivity. Our journey began with one simple question: how can technology help break down the barriers that keep people from understanding one another?\n\n'
              'We realized that communication challenges, especially for the deaf-mute community, often go unnoticed. Many people struggle to express themselves or be understood, simply because sign language is not universally known. This inspired us to create exPress, a tool that empowers individuals to connect, learn, and communicate without limits.\n\n'
              'Together, we bring our knowledge as college students in the course of Information Technology specialized in Mobile and Web Application. But more importantly, we bring empathy, curiosity, and a strong belief that technology should serve everyone. To make exPress possible, we combined global and local knowledge by training our models with international sign language datasets from Kaggle and Filipino Sign Language data from Mendeley. This ensures that the app is not only accurate on a global scale but also deeply relevant to the needs of the Filipino community.\n\n'
              'Behind every feature in exPress are months of research and data gathering, and collaboration with members of the deaf-mute community. We worked hard to ensure that the app feels intuitive, supportive, and impactful in real-world use.\n\n'
              'At our core, we believe that communication is a human right. No one should feel left out because of a language barrier. exPress is our way of helping create a world where inclusivity is not just an option, it’s the standard.',
              style: GoogleFonts.robotoMono(
                fontSize: 15,
                color: Colors.blueGrey[800],
                height: 1.5,
              ),
            ),

            const SizedBox(height: 24),
            Text(
              'OUR MISSION',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[900],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Our mission is to develop innovative technologies that empower the deaf-mute community and foster inclusive communication for all. We believe that breaking down communication barriers is not just a technical goal, but a human responsibility, one that can create stronger connections, greater understanding, and equal opportunities for everyone.',
              style: GoogleFonts.robotoMono(
                fontSize: 15,
                color: Colors.blueGrey[800],
                height: 1.5,
              ),
            ),

            const SizedBox(height: 24),
            Text(
              'OUR VISION',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[900],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'We envision a future where communication knows no limits. A world where people, regardless of their ability, background, or language, can connect, learn, and share freely. exPress aims to be at the forefront of this future, serving as both a tool and a movement toward universal inclusivity.',
              style: GoogleFonts.robotoMono(
                fontSize: 15,
                color: Colors.blueGrey[800],
                height: 1.5,
              ),
            ),

            const SizedBox(height: 24),
            Text(
              'OUR VALUES',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[900],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'At the heart of exPress are the values that guide everything we do. We believe in inclusivity, ensuring that every individual has the right to be heard, understood, and fully included in conversations and communities. Our approach is grounded in innovation with purpose. We do not create technology for its own sake, but rather to address meaningful human challenges and deliver real impact. We also embrace a community-first mindset, listening to the people we serve, learning from their experiences, and growing alongside them to continuously improve. Finally, we value empowerment, building tools that give individuals the confidence and freedom to express themselves without limits. These principles shape not only the exPress app, but also the mission and vision of our entire team.',
              style: GoogleFonts.robotoMono(
                fontSize: 15,
                color: Colors.blueGrey[800],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// Privacy Policy Page
class PrivacyPolicyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Color(0xFF334E7B), size: 32),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Privacy Policy',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'exPress Privacy Policy',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF334E7B),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Last Updated: August 22, 2025',
              style: GoogleFonts.robotoMono(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Color(0xFF334E7B),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'exPress is committed to protecting your privacy. '
              'This Privacy Policy explains how we collect, use, and safeguard your personal information when you use our mobile and web applications.\n\n'
              '• We collect only the minimum data necessary to provide and improve functionality.\n'
              '• Conversations are processed locally whenever possible to maximize privacy.\n'
              '• We never sell or trade your personal information to third parties.\n'
              '• You may request access, correction, or deletion of your data at any time.\n\n'
              'We apply industry-standard security measures to protect your information. '
              'If data must be stored in the cloud, it is encrypted and handled with strict safeguards.\n\n'
              'By using exPress, you consent to this Privacy Policy. Updates to this policy will be reflected with a revised “Last Updated” date above. '
              'For questions or requests regarding your data, please contact us at @exPress@gmail.com.',
              style: GoogleFonts.robotoMono(
                fontSize: 15,
                color: Colors.blueGrey[800],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// Terms & Conditions Page
class TermsConditionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Color(0xFF334E7B), size: 32),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Terms',
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
            Text(
              'exPress Terms of Use',
              style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF334E7B),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Last Updated: August 22, 2025',
              style: GoogleFonts.robotoMono(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: Color(0xFF334E7B),
              ),
            ),
        
            const SizedBox(height: 40),
            Text(
              'By using exPress, you agree to the following terms:\n\n• Use the app for lawful purposes only\n• Respect other users and their privacy\n• Do not attempt to reverse engineer the app\n• We reserve the right to update these terms\n• Continued use constitutes acceptance of changes',
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