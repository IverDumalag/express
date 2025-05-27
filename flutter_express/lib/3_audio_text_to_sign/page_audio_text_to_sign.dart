import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
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
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text("Finding match..."),
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
        title: Text(matchFound ? "Match Found!" : "No Match Found"),
        content: Text(
          matchFound
              ? "A sign language match was found for your entry."
              : "No match found, but your entry will be saved.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text("OK"),
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Entries List
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.indigo[100]!, width: 1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        const double itemHeight = 90.0;
                        final double listViewHeight = constraints.maxHeight;
                        int selectedIndex = 0;

                        if (_scrollController.hasClients &&
                            _phrases.isNotEmpty) {
                          double offset = _scrollController.offset;
                          selectedIndex =
                              ((offset + listViewHeight) / itemHeight).floor();
                          selectedIndex = selectedIndex.clamp(
                            0,
                            _phrases.length - 1,
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
                                height: itemHeight,
                                alignment: Alignment.centerRight,
                                margin: EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.indigo[50]
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.indigo
                                        : Colors.grey[300]!,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  boxShadow: [
                                    if (isSelected)
                                      BoxShadow(
                                        color: Colors.indigo.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: Offset(0, 2),
                                      ),
                                  ],
                                ),
                                child: ListTile(
                                  title: Text(
                                    phrase['words'] ?? '',
                                    style: TextStyle(
                                      fontSize: isSelected ? 32 : 22,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Colors.indigo[900]
                                          : Colors.grey[800],
                                    ),
                                  ),
                                  subtitle: Text(
                                    createdAt,
                                    style: TextStyle(
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
                    border: Border.all(color: Colors.indigo, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.indigo.withOpacity(0.08),
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
                          decoration: InputDecoration(
                            hintText: 'Type to say something...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.send, color: Colors.indigo),
                        onPressed: () => _handleSubmit(_textController.text),
                      ),
                    ],
                  ),
                ),
                // Mic Button
                Container(
                  height: 100,
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(top: 8, bottom: 8),
                  child: GestureDetector(
                    onTap: _toggleRecording,
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: _isListening
                                ? Colors.indigo[800]
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
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 20,
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
            top: 16,
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
