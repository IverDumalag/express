import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../0_components/help_widget.dart';
import '../00_services/database_services.dart';
import '../00_services/file_search_services.dart';
import '../1_home/home_cards.dart';

class AudioTextToSignPage extends StatefulWidget {
  @override
  _AudioTextToSignPageState createState() => _AudioTextToSignPageState();
}

class _AudioTextToSignPageState extends State<AudioTextToSignPage> {
  final DatabaseService _dbService = DatabaseService.instance;
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
    final phrases = await _dbService.getAudioTextPhrases();
    setState(() => _phrases = phrases.reversed.toList());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  Future<void> _handleSubmit(String text) async {
    if (text.isEmpty) return;
    final filePath =
        await FileSearchService.findBestMatchFile(text, 'assets/dataset/');
    _dbService.addAudioTextPhrase(text, filePath ?? '');
    _textController.clear();
    await _loadPhrases();
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
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      const double itemHeight = 90.0;
                      final double listViewHeight = constraints.maxHeight;
                      int selectedIndex = 0;

                      // Check if the ScrollController is attached and there are phrases
                      if (_scrollController.hasClients && _phrases.isNotEmpty) {
                        double offset = _scrollController.offset;
                        selectedIndex =
                            ((offset + listViewHeight) / itemHeight).floor();
                        selectedIndex =
                            selectedIndex.clamp(0, _phrases.length - 1);
                      }

                      return ListView.builder(
                        controller: _scrollController,
                        itemCount: _phrases.length,
                        padding: EdgeInsets.only(bottom: 20.0, top: 40.0),
                        itemBuilder: (context, index) {
                          final phrase = _phrases[index];
                          final bool isSelected = index == selectedIndex;

                          return GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CardDetailScreen(
                                  title: phrase['words'],
                                  color: Color(0xFF334E7B),
                                  index: index,
                                  items: _phrases,
                                  scale: 1.0,
                                  onDelete: (entryId) async {
                                    await _dbService
                                        .deleteAudioTextPhrase(entryId);
                                    _loadPhrases();
                                  },
                                  entryId: phrase['entry_id'],
                                ),
                              ),
                            ),
                            child: Container(
                              height: itemHeight,
                              alignment: Alignment.centerRight,
                              child: Text(
                                phrase['words'],
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: isSelected ? 58 : 38,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.black
                                      : Colors.grey[700],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Container(
                  height: 120,
                  alignment: Alignment.center,
                  margin: EdgeInsets.all(20),
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
                            color:
                                _isListening ? Colors.white : Colors.grey[600],
                            size: 32,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tap to speak',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _buildInputSection(),
              ],
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: HelpIconWidget(
              helpTitle: 'Audio/Text Input',
              helpText: '1. Type or speak to convert to sign language\n'
                  '2. Tap entries to view details\n'
                  '3. Swipe left to delete entries',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 3,
                    blurRadius: 2,
                  ),
                ],
              ),
              child: TextField(
                controller: _textController,
                onSubmitted: _handleSubmit,
                decoration: InputDecoration(
                  hintText: 'Type to say something...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () => _handleSubmit(_textController.text),
                  ),
                ),
              ),
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
