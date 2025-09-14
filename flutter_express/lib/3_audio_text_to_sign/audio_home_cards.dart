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
              Center(
                child: MediaViewer(filePath: signLanguagePath, scale: scale),
              )
            else
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(32 * scale),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12 * scale),
                  border: Border.all(color: Colors.grey[300]!, width: 1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 48 * scale,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 12 * scale),
                    Text(
                      "No Match Found",
                      style: GoogleFonts.robotoMono(
                        fontSize: 18 * scale,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 6 * scale),
                    Text(
                      "No sign language equivalent available for this phrase",
                      style: GoogleFonts.robotoMono(
                        fontSize: 12 * scale,
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
