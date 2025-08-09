import 'package:flutter/material.dart';
import 'package:flutter_express/0_components/media_viewer.dart';
import 'package:google_fonts/google_fonts.dart';
import '../1_home/home_cards.dart';

class AudioCardDetailScreen extends StatelessWidget {
  final Map<String, dynamic> phrase;
  final double scale;

  const AudioCardDetailScreen({
    Key? key,
    required this.phrase,
    this.scale = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final displayText = phrase['words'] ?? '';
    final signLanguagePath = phrase['sign_language'] ?? '';
    final createdAt = phrase['created_at'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text('', style: GoogleFonts.robotoMono()),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [],
      ),
      body: Padding(
        padding: EdgeInsets.all(24 * scale),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    displayText,
                    style: GoogleFonts.robotoMono(
                      fontSize: 28 * scale,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF334E7B),
                    ),
                  ),
                ),
                SizedBox(width: 8 * scale),
                InteractiveSpeakerIcon(
                  scale: scale,
                  text: displayText,
                  color: Color(0xFF334E7B),
                ),
              ],
            ),
            SizedBox(height: 16 * scale),
            Text(
              'Created: $createdAt',
              style: GoogleFonts.robotoMono(
                fontSize: 16 * scale,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 24 * scale),
            if (signLanguagePath.isNotEmpty)
              MediaViewer(filePath: signLanguagePath, scale: scale),
          ],
        ),
      ),
    );
  }
}
