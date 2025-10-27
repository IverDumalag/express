import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../0_components/help_widget.dart';
import '../0_components/popup_information.dart';
import '../00_services/audio_phrases_words_service.dart';
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

    // Show disclaimer popup when entering the screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showDisclaimerPopup();
    });
  }

  void _showDisclaimerPopup() async {
    await PopupInformation.show(
      context,
      title: "Dataset Information",
      message:
          "Note: Our dataset has limited coverage and contains introductory words/phrases and alphabet. Some words may not have sign language matches available.",
    );
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
      final response =
          await AudioPhrasesWordsService.getAudioPhrasesWordsByUserId(userId);
      if (response.success && response.data != null) {
        setState(
          () => _phrases = response.data!,
        ); // Do NOT reverse, keep order as-is (oldest first)
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    } catch (e) {
      // Show user-friendly error for loading phrases
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Unable to load your saved phrases',
              style: GoogleFonts.robotoMono(color: Colors.white),
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _handleSubmit(String text) async {
    if (text.trim().isEmpty) {
      await PopupInformation.show(
        context,
        title: "Input Required",
        message: "Please enter some text before submitting.",
      );
      return;
    }

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
      const trySearchUrl =
          'https://express-nodejs-nc12.onrender.com/api/search';
      final res = await http.get(
        Uri.parse('$trySearchUrl?q=${Uri.encodeComponent(text.trim())}'),
      );
      final searchJson = jsonDecode(res.body);
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
      // Show user-friendly error for search failure (not critical)
      // Search failed, but we'll continue saving without sign language match
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

    try {
      final insertResult =
          await AudioPhrasesWordsService.insertAudioPhrasesWords(
            userId: userId,
            words: text.trim(),
            signLanguage: signLanguageUrl,
            isMatch: matchFound,
          );
      _textController.clear();
      await _loadPhrases();

      // Auto-open the result if submission was successful and match was found
      if (matchFound &&
          signLanguageUrl.isNotEmpty &&
          insertResult.success &&
          insertResult.data != null) {
        final newPhrase = {
          'entry_id': insertResult.data!['entry_id'] ?? '',
          'words': text.trim(),
          'sign_language': signLanguageUrl,
          'created_at': DateTime.now().toIso8601String(),
          'is_match': matchFound,
        };

        // Navigate to the detail screen automatically
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AudioCardDetailScreen(
              phrase: newPhrase,
              scale: MediaQuery.of(context).size.width / 375.0,
            ),
          ),
        );
      }
    } catch (e) {
      // Show user-friendly error for saving phrase
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Unable to save your phrase. Please try again.',
              style: GoogleFonts.robotoMono(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _clearAllPhrases() async {
    final userId = UserSession.user?['user_id']?.toString() ?? "";
    if (userId.isEmpty) return;

    try {
      final result =
          await AudioPhrasesWordsService.deleteAudioPhrasesWordsByUserId(
            userId,
          );
      if (result.success) {
        // Successfully deleted all phrases
        setState(() {
          _phrases.clear();
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'All entries successfully',
              style: GoogleFonts.robotoMono(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${result.message ?? 'Failed to delete entries'}',
              style: GoogleFonts.robotoMono(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Show user-friendly error message for delete failure
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Unable to delete entries. Please try again.',
              style: GoogleFonts.robotoMono(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _startRecording() async {
    if (!await Permission.microphone.isGranted) {
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        // Show user-friendly message for microphone permission denial
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Microphone access is needed to record your voice',
                style: GoogleFonts.robotoMono(color: Colors.white),
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
        }
        return;
      }
    }

    setState(() => _isListening = true);
    _textController.clear(); // Clear previous text

    await _speech.listen(
      onResult: (result) => setState(() {
        _textController.text = result.recognizedWords;
      }),
      listenFor: Duration(seconds: 30),
    );
  }

  Future<void> _stopRecording() async {
    if (!_isListening) return;

    setState(() => _isListening = false);
    await _speech.stop();

    // Perform submit if there's text
    if (_textController.text.trim().isNotEmpty) {
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
                        int selectedIndex = _phrases.isNotEmpty
                            ? _phrases.length - 1
                            : 0;

                        // Show "no match found" message when list is empty
                        if (_phrases.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    "No Entry Yet",
                                    style: GoogleFonts.robotoMono(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "Start typing or speaking to find sign language matches",
                                    style: GoogleFonts.robotoMono(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

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
                                        : Colors.grey[300] ?? Colors.grey,
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
                          style: GoogleFonts.robotoMono(),
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
                    onTapDown: (_) => _startRecording(),
                    onTapUp: (_) => _stopRecording(),
                    onTapCancel: () => _stopRecording(),
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
                          _isListening ? 'Recording...' : 'Hold to speak',
                          style: GoogleFonts.robotoMono(
                            color: Colors.grey[600],
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[50],
                      foregroundColor: Colors.red[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: BorderSide(
                        color: Colors.red[200] ?? Colors.red.shade200,
                        width: 1.2,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                    ),
                    icon: Icon(Icons.delete_forever),
                    label: Text(
                      'Clear All',
                      style: GoogleFonts.robotoMono(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: _phrases.isEmpty
                        ? null
                        : () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text(
                                  'Clear All?',
                                  style: GoogleFonts.robotoMono(),
                                ),
                                content: Text(
                                  'Are you sure you want to delete all entries?',
                                  style: GoogleFonts.robotoMono(),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(false),
                                    child: Text(
                                      'Cancel',
                                      style: GoogleFonts.robotoMono(),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(true),
                                    child: Text(
                                      'Delete',
                                      style: GoogleFonts.robotoMono(
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await _clearAllPhrases();
                            }
                          },
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 56, // Lowered from 16 to 56
            left: 16,
            child: GestureDetector(
              onTap: _showDisclaimerPopup,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.info_outline,
                  color: Color(0xFF334E7B),
                  size: 24,
                ),
              ),
            ),
          ),
          Positioned(
            top: 56, // Lowered from 16 to 56
            right: 16,
            child: HelpIconWidget(
              helpTitle: 'Audio/Text Input',
              helpText:
                  '1. Type or speak to convert to sign language\n'
                  '2. Tap entries to view details',
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
