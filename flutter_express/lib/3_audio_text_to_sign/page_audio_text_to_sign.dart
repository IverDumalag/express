import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:google_fonts/google_fonts.dart';
import '../0_components/help_widget.dart';
import '../00_services/api_services.dart';
import 'audio_home_cards.dart';
import '../global_variables.dart';

class AudioTextToSignPage extends StatefulWidget {
  @override
  _AudioTextToSignPageState createState() => _AudioTextToSignPageState();
}

class _AudioTextToSignPageState extends State<AudioTextToSignPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _phrases = [];
  bool _isListening = false;
  late stt.SpeechToText _speech;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initializeSpeech();
    _loadPhrases();
  }

  Future<void> _initializeSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print('onStatus: $status'),
      onError: (error) => print('onError: $error'),
    );
    if (!available) {
      print("Speech recognition not available");
    }
  }

  Future<void> _loadPhrases() async {
    final userId =
        UserSession.user?['user_id']?.toString() ??
        ""; // Replace with your logic
    try {
      final phrases = await ApiService.fetchAudioPhrases(userId);
      setState(
        () => _phrases = phrases,
      ); // Do NOT reverse, keep order as-is (oldest first)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    } catch (e) {
      // Optionally show error
    }
  }

  Future<void> _handleSubmit(String text) async {
    if (text.trim().isEmpty) return;
    final userId = UserSession.user?['user_id']?.toString() ?? "";

    String signLanguageUrl = '';
    bool matchFound = false;

    // Show "Finding match..." popup
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
          side: BorderSide(color: Color(0xFF334E7B), width: 2),
        ),
        backgroundColor: Colors.white,
        elevation: 8,
        contentPadding: EdgeInsets.all(24),
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text(
              "Finding match...",
              style: GoogleFonts.robotoMono(color: Color(0xFF334E7B)),
            ),
          ],
        ),
      ),
    );

    try {
      final searchJson = await ApiService.trySearch(text.trim());
      if (searchJson != null &&
          searchJson['public_id'] != null &&
          searchJson['all_files'] is List) {
        final file = (searchJson['all_files'] as List).firstWhere(
          (f) => f['public_id'] == searchJson['public_id'],
          orElse: () => null,
        );
        if (file != null && file['url'] != null) {
          signLanguageUrl = file['url'];
          matchFound = true;
        }
      }
    } catch (e) {
      // Optionally show error
    }

    // Close the "Finding match..." popup
    Navigator.of(context, rootNavigator: true).pop();

    // Show result popup
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
          side: BorderSide(color: Color(0xFF334E7B), width: 2),
        ),
        backgroundColor: Colors.white,
        elevation: 8,
        title: Text(
          matchFound ? "Match Found!" : "No Match Found",
          style: GoogleFonts.robotoMono(color: Color(0xFF334E7B), fontSize: 15),
        ),
        content: Text(
          matchFound
              ? "A sign language match was found for your entry."
              : "No match found, but your entry will be saved.",
          style: GoogleFonts.robotoMono(color: Color(0xFF334E7B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              "OK",
              style: GoogleFonts.robotoMono(color: Color(0xFF2E5C9A)),
            ),
          ),
        ],
      ),
    );

    final isMatch = matchFound ? 1 : 0;

    try {
      await ApiService.insertAudioPhrase(
        userId: userId,
        words: text.trim(),
        signLanguage: signLanguageUrl,
        isMatch: isMatch,
      );
      _textController.clear();
      await _loadPhrases();
    } catch (e) {
      // Optionally show error
    }
  }

  Future<void> _toggleRecording() async {
    if (!await Permission.microphone.isGranted) {
      final status = await Permission.microphone.request();
      if (!status.isGranted) return;
    }

    setState(() => _isListening = !_isListening);
    if (_isListening) {
      _startListening();
    } else {
      _stopListening();
    }
  }

  void _startListening() async {
    await _speech.listen(
      onResult: (result) => setState(() {
        _textController.text = result.recognizedWords;
      }),
      listenFor: Duration(seconds: 30),
    );
  }

  void _stopListening() async {
    await _speech.stop();
    if (_textController.text.isNotEmpty) {
      await _handleSubmit(_textController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 110.0,
              left: 16.0,
              right: 16.0,
              bottom: 16.0,
            ),
            child: Column(
              children: [
                // Entries List
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Color(0xFF334E7B), width: 1.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        const double itemHeight = 90.0;
                        final double listViewHeight = constraints.maxHeight;
                        int selectedIndex = _phrases.isNotEmpty
                            ? _phrases.length - 1
                            : 0;

                        return ListView.builder(
                          controller: _scrollController,
                          itemCount: _phrases.length,
                          padding: EdgeInsets.only(bottom: 20.0, top: 40.0),
                          reverse: false, // latest at bottom
                          itemBuilder: (context, index) {
                            final phrase = _phrases[index];
                            final bool isSelected = index == selectedIndex;
                            final createdAt = phrase['created_at'] ?? '';

                            return GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AudioCardDetailScreen(
                                    phrase: phrase,
                                    scale: 1.0,
                                  ),
                                ),
                              ),
                              child: Container(
                                // Removed height: itemHeight
                                alignment: Alignment.centerRight,
                                margin: EdgeInsets.symmetric(vertical: 8),
                                padding: EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.indigo[50]
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF334E7B)
                                        : Colors.grey[300]!,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  boxShadow: [
                                    if (isSelected)
                                      BoxShadow(
                                        color: Color(0xFF334E7B),
                                        blurRadius: 8,
                                        offset: Offset(0, 2),
                                      ),
                                  ],
                                ),
                                child: ListTile(
                                  title: Text(
                                    phrase['words'] ?? '',
                                    style: GoogleFonts.robotoMono(
                                      fontSize: isSelected ? 22 : 22,
                                      color: isSelected
                                          ? const Color(0xFF334E7B)
                                          : Colors.grey[800],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    createdAt,
                                    style: GoogleFonts.robotoMono(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                // Input Section
                SizedBox(height: 18),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.indigo[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFF334E7B), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF334E7B).withOpacity(0.08),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  margin: EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          onSubmitted: _handleSubmit,
                          style:
                              GoogleFonts.robotoMono(), 
                          decoration: InputDecoration(
                            hintText: 'Type to say something...',
                            hintStyle: GoogleFonts.robotoMono(
                              color: Colors.grey[600],
                            ), 
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(8),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.send, color: Color(0xFF334E7B)),
                        onPressed: () => _handleSubmit(_textController.text),
                      ),
                    ],
                  ),
                ),
                // Mic Button
                Container(
                  height: 100,
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(top: 2, bottom: 1),
                  child: GestureDetector(
                    onTap: _toggleRecording,
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: _isListening
                                ? const Color(0xFF334E7B)
                                : Colors.grey[200],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isListening ? Icons.mic : Icons.mic_none,
                            color: _isListening
                                ? Colors.white
                                : Colors.grey[600],
                            size: 32,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tap to speak',
                          style: GoogleFonts.robotoMono(
                            color: Colors.grey[600],
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 56, // Lowered from 16 to 56
            right: 16,
            child: HelpIconWidget(
              helpTitle: 'Audio/Text Input',
              helpText:
                  '1. Type or speak to convert to sign language\n'
                  '2. Tap entries to view details\n'
                  '3. Swipe left to delete entries',
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _speech.stop();
    _scrollController.dispose();
    super.dispose();
  }
}