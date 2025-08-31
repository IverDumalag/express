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
              'Version: 1.0.0\nBuild Number: basta number d2 \nRelease Date: Di ko pa sure',
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
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           
            const SizedBox(height: 20),
            Text(
              'exPress is developed by Owlets. We are passionate about developing and designing an inclusive communication tool for the deaf-mute community and the general public. Our mission is to bridge the gap between different communities through technology.\n\nWe believe in creating accessible solutions that empower people to communicate freely regardless of their abilities.',
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
      body: Padding(
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
              'Your privacy is important to us. This Privacy Policy explains how exPress collects, uses, and protects your personal information.\n\n• We collect minimal data necessary for app functionality\n• Your conversations are processed locally when possible\n• We never sell your personal information to third parties\n• You can request data deletion at any time',
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