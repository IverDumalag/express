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
            Row(
              children: [
                Icon(Icons.sign_language, size: 40, color: Color(0xFF334E7B)),
                SizedBox(width: 12),
                Text('exPress', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 22, color: Color(0xFF334E7B))),
              ],
            ),
            SizedBox(height: 8),
            Text('A modern sign language app.', style: GoogleFonts.robotoMono()),
            SizedBox(height: 24),
            ListTile(
              leading: Icon(Icons.privacy_tip_outlined, color: Color(0xFF334E7B)),
              title: Text('Privacy Policy', style: GoogleFonts.robotoMono()),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => _InfoDialog(
                    title: 'Privacy Policy',
                    content: 'Privacy Policy details go here.',
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.description_outlined, color: Color(0xFF334E7B)),
              title: Text('Terms & Conditions', style: GoogleFonts.robotoMono()),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => _InfoDialog(
                    title: 'Terms & Conditions',
                    content: 'Terms & Conditions details go here.',
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoDialog extends StatelessWidget {
  final String title;
  final String content;
  const _InfoDialog({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      insetPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 22,
                color: Color(0xFF334E7B),
              ),
            ),
            SizedBox(height: 16),
            Container(
              width: double.maxFinite,
              child: Text(
                content,
                style: GoogleFonts.robotoMono(
                  color: Colors.grey[700],
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
            SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: [Color(0xFF334E7B), Color(0xFF4A6BA5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Close',
                    style: GoogleFonts.robotoMono(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
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
