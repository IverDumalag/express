import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_express/0_components/media_viewer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../00_services/phrases_words_service.dart';
import '../0_components/popup_confirmation.dart';
import '../0_components/popup_information.dart';
import '../3_audio_text_to_sign/audio_home_cards.dart'; // For FullScreenMediaViewer
import 'dart:async';

class InteractiveStarIcon extends StatefulWidget {
  final double scale;
  final bool initialStarred;
  final Function(bool)? onToggle;

  const InteractiveStarIcon({
    Key? key,
    required this.scale,
    this.initialStarred = false,
    this.onToggle,
  }) : super(key: key);

  @override
  _InteractiveStarIconState createState() => _InteractiveStarIconState();
}

class _InteractiveStarIconState extends State<InteractiveStarIcon> {
  late bool isStarred;

  @override
  void initState() {
    super.initState();
    isStarred = widget.initialStarred;
  }

  @override
  void didUpdateWidget(covariant InteractiveStarIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    // This is the crucial part: update internal state if the parent's value changes
    if (widget.initialStarred != oldWidget.initialStarred) {
      isStarred = widget.initialStarred;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isStarred = !isStarred; // Toggle the internal state immediately
        });
        // The onToggle callback should be called with the *intended* new state
        // The parent is still responsible for updating the actual data.
        widget.onToggle?.call(isStarred); // Pass the new internal state
      },
      child: Icon(
        isStarred ? Icons.star : Icons.star_border,
        color: Colors.yellow,
        size: 30 * widget.scale,
      ),
    );
  }
}

/// A reusable icon widget that triggers text-to-speech when tapped.
/// It changes its appearance to indicate when speech is active.
class InteractiveSpeakerIcon extends StatefulWidget {
  final double scale;
  final String text;
  final Color color;

  const InteractiveSpeakerIcon({
    Key? key,
    required this.scale,
    required this.text,
    required this.color,
  }) : super(key: key);

  @override
  _InteractiveSpeakerIconState createState() => _InteractiveSpeakerIconState();
}

class _InteractiveSpeakerIconState extends State<InteractiveSpeakerIcon> {
  bool isLoud = false;
  final FlutterTts flutterTts = FlutterTts();
  Timer? _fallbackTimer;

  @override
  void initState() {
    super.initState();
    flutterTts.awaitSpeakCompletion(true);

    flutterTts.setCompletionHandler(() {
      _resetLoud();
    });
    flutterTts.setCancelHandler(() {
      _resetLoud();
    });
    flutterTts.setErrorHandler((msg) {
      _resetLoud();
      // Show user-friendly error popup
      if (context.mounted) {
        PopupInformation.show(
          context,
          title: "Audio Not Available",
          message:
              "Sorry, we couldn't read this text aloud. Please check your device's audio settings.",
        );
      }
    });
  }

  void _resetLoud() {
    if (mounted) {
      setState(() {
        isLoud = false;
      });
    }
    _fallbackTimer?.cancel();
  }

  @override
  void dispose() {
    flutterTts.stop();
    _fallbackTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (!isLoud) {
          setState(() {
            isLoud = true;
          });
          // Fallback: reset after 3 seconds if TTS doesn't call handler
          _fallbackTimer?.cancel();
          _fallbackTimer = Timer(Duration(seconds: 3), _resetLoud);

          try {
            await flutterTts.speak(widget.text);
          } catch (e) {
            _resetLoud();
            if (context.mounted) {
              PopupInformation.show(
                context,
                title: "Audio Not Available",
                message:
                    "Sorry, we couldn't read this text aloud. Please check your device's audio settings.",
              );
            }
          }
        } else {
          try {
            await flutterTts.stop();
          } catch (e) {
            // Silent fail for stop operation
          }
          _resetLoud();
        }
      },
      child: Icon(
        Icons.volume_up,
        color: isLoud ? const Color(0xFF2E5C9A) : widget.color,
        size: 30 * widget.scale,
      ),
    );
  }
}

/// A screen to display the detailed information of a selected card,
/// including text, sign language media, and navigation controls.
class CardDetailScreen extends StatefulWidget {
  final String title;
  final Color color;
  final int index;
  final List<Map<String, dynamic>> items;
  final double scale;
  final Function(String) onDelete;
  final String entryId;

  // Add onEdit callback to update parent list after edit
  final Function(Map<String, dynamic>)? onEdit;

  const CardDetailScreen({
    Key? key,
    required this.title,
    required this.color,
    required this.index,
    required this.items,
    required this.scale,
    required this.onDelete,
    required this.entryId,
    this.onEdit,
  }) : super(key: key);

  @override
  _CardDetailScreenState createState() => _CardDetailScreenState();
}

class _CardDetailScreenState extends State<CardDetailScreen> {
  late int currentIndex;
  bool editMode = false;
  late TextEditingController _editController;
  bool editLoading = false;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.index;
    _editController = TextEditingController(
      text: widget.items[widget.index]['words'] ?? '',
    );
  }

  @override
  void didUpdateWidget(covariant CardDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items != oldWidget.items || widget.index != oldWidget.index) {
      currentIndex = widget.index;
      _editController.text = widget.items[widget.index]['words'] ?? '';
    }
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  void _goToNext() {
    if (currentIndex < widget.items.length - 1) {
      setState(() {
        currentIndex++;
        _editController.text = widget.items[currentIndex]['words'] ?? '';
        editMode = false;
      });
    }
  }

  void _goToPrevious() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        _editController.text = widget.items[currentIndex]['words'] ?? '';
        editMode = false;
      });
    }
  }

  void _deletePhrase() async {
    final confirmed = await PopupConfirmation.show(
      context,
      title: "Archive Card",
      message: "Are you sure you want to Archive this card?",
      confirmText: "Confirm",
      cancelText: "Cancel",
    );
    if (confirmed) {
      final String currentEntryIdToDelete =
          widget.items[currentIndex]['entry_id'];
      widget.onDelete(currentEntryIdToDelete);
      Navigator.pop(context); // Pop CardDetailScreen
    }
  }

  Future<void> _editPhrase() async {
    setState(() => editLoading = true);
    final entryId = widget.items[currentIndex]['entry_id'];
    final newWords = _editController.text.trim();

    // Prevent empty or duplicate
    if (newWords.isEmpty) {
      setState(() => editLoading = false);
      if (context.mounted) {
        PopupInformation.show(
          context,
          title: "Text Required",
          message: "Please enter some text before saving.",
        );
      }
      return;
    }
    // Check for duplicate in the list (excluding current)
    final isDuplicate = widget.items.any(
      (item) =>
          item['entry_id'] != entryId &&
          (item['words'] ?? '').toString().trim().toLowerCase() ==
              newWords.toLowerCase(),
    );
    if (isDuplicate) {
      setState(() => editLoading = false);
      if (context.mounted) {
        PopupInformation.show(
          context,
          title: "Already Exists",
          message:
              "This text already exists in your collection. Please enter something different.",
        );
      }
      return;
    }

    try {
      // Try to search for a match first
      String signLanguageUrl = '';
      bool matchFound = false;

      try {
        const trySearchUrl =
            'https://express-nodejs-nc12.onrender.com/api/search';
        final res = await http.get(
          Uri.parse('$trySearchUrl?q=${Uri.encodeComponent(newWords)}'),
        );
        final searchJson = jsonDecode(res.body);
        if (searchJson != null &&
            searchJson['public_id'] != null &&
            searchJson['all_files'] is List) {
          final file = (searchJson['all_files'] as List).firstWhere(
            (f) => f['public_id'] == searchJson['public_id'],
            orElse: () => null,
          );
          if (file != null) {
            signLanguageUrl = file['url'];
            matchFound = true;
          }
        }
      } catch (searchError) {
        // Search failed, but we'll continue with empty sign language
        // This is not a critical error - just means no match found
      }

      // Show popup before updating
      if (context.mounted) {
        await PopupInformation.show(
          context,
          title: matchFound ? "Match Found!" : "No Match",
          message: matchFound
              ? "A match was found for your word/phrase."
              : "No match found, but will update your entry.",
        );
      }

      // Call API to update, now with sign_language
      final result = await PhrasesWordsService.editPhrasesWords(
        entryId: entryId,
        words: newWords,
        signLanguage: signLanguageUrl,
      );
      if (result.success && result.data != null) {
        setState(() {
          editMode = false;
          widget.items[currentIndex]['words'] = newWords;
          widget.items[currentIndex]['sign_language'] = signLanguageUrl;
        });
        widget.onEdit?.call(widget.items[currentIndex]);
        if (context.mounted) {
          PopupInformation.show(
            context,
            title: "Success!",
            message: "Your changes have been saved successfully.",
          );
        }
      } else {
        // Error saving - show error message
        if (context.mounted) {
          PopupInformation.show(
            context,
            title: "Save Failed",
            message: result.message ?? "Unable to save your changes.",
          );
        }
      }
    } catch (e) {
      // More user-friendly error messages based on error type
      String errorMessage = "Something went wrong while saving your changes.";
      String errorTitle = "Save Failed";

      // Check for common error types
      if (e.toString().contains('SocketException') ||
          e.toString().contains('TimeoutException') ||
          e.toString().contains('NetworkException')) {
        errorTitle = "Connection Problem";
        errorMessage = "Please check your internet connection and try again.";
      } else if (e.toString().contains('FormatException')) {
        errorTitle = "Invalid Input";
        errorMessage =
            "The text you entered contains invalid characters. Please try different text.";
      }

      if (context.mounted) {
        PopupInformation.show(
          context,
          title: errorTitle,
          message: errorMessage,
        );
      }
    }
    setState(() => editLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final currentPhrase = widget.items[currentIndex];
    final displayText = currentPhrase['words'] as String;
    final signLanguagePath = currentPhrase['sign_language'] as String;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Color(0xFF334E7B), size: 36),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.edit_note, color: Color(0xFF334E7B)),
            onPressed: () {
              setState(() {
                editMode = true;
                _editController.text = displayText;
              });
            },
          ),
          Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: IconButton(
              icon: Icon(Icons.archive, color: Color(0xFF334E7B)),
              onPressed: _deletePhrase,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 0,
            right: 0,
            top: 48 * widget.scale,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20 * widget.scale),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30 * widget.scale),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: editMode
                          ? TextField(
                              controller: _editController,
                              enabled: !editLoading,
                              decoration: InputDecoration(
                                hintText: "Edit word or phrase",
                                hintStyle: GoogleFonts.robotoMono(),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Color(0xFF334E7B),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Color(0xFF2E5C9A),
                                  ),
                                ),
                              ),
                              style: GoogleFonts.robotoMono(
                                fontSize: 24 * widget.scale,
                                color: Color(0xFF2354C7),
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : Text(
                              displayText,
                              style: GoogleFonts.robotoMono(
                                fontSize: 30 * widget.scale,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF334E7B),
                              ),
                              textAlign: TextAlign.center,
                            ),
                    ),
                    SizedBox(width: 2 * widget.scale),
                    if (!editMode)
                      Padding(
                        padding: EdgeInsets.only(
                          left: 0,
                        ), // Changed from 2 to 0
                        child: InteractiveSpeakerIcon(
                          scale: widget.scale,
                          text: displayText,
                          color: Color(0xFF334E7B),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 20 * widget.scale),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 10 * widget.scale,
                  vertical: 10 * widget.scale,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12 * widget.scale),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12 * widget.scale),
                    child: MediaViewer(
                      key: ValueKey(
                        signLanguagePath,
                      ), // Add key to force rebuild when path changes
                      filePath: signLanguagePath,
                      scale: widget.scale,
                      onFullScreenToggle: () =>
                          _enterFullScreen(signLanguagePath, displayText),
                    ),
                  ),
                ),
              ),
              // Source icon and text, left-aligned directly under media viewer
              Padding(
                padding: EdgeInsets.only(
                  left: 1 * widget.scale,
                  top: 0,
                  bottom: 8,
                ),
                child: GestureDetector(
                  onTap: () {
                    String sourceMessage =
                        "Alphabet: Porton, J. G. (2023). FSL Dataset. Kaggle.com. https://www.kaggle.com/datasets/japorton/fsl-dataset\n\n"
                        "Introductionary Words/Phrases: Tupal, I. J. (2023). FSL-105: A dataset for recognizing 105 Filipino sign language videos. Mendeley Data, 2. https://doi.org/10.17632/48y2y99mb9.2";
                    PopupInformation.show(
                      context,
                      title: "Retrieved from:",
                      message: sourceMessage,
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 18 * widget.scale,
                        color: Color(0xFF334E7B),
                      ),
                      SizedBox(width: 6),
                      Text(
                        "Source",
                        style: GoogleFonts.robotoMono(
                          color: Color(0xFF334E7B),
                          fontWeight: FontWeight.w600,
                          fontSize: 16 * widget.scale,
                          decoration: TextDecoration.underline,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24 * widget.scale),
              if (editMode)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20 * widget.scale),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Primary button: Save
                      SizedBox(
                        width: 120 * widget.scale,
                        child: ElevatedButton(
                          onPressed: editLoading ? null : _editPhrase,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF334E7B),
                            foregroundColor: Colors.white,
                            textStyle: GoogleFonts.robotoMono(
                              fontSize: 20 * widget.scale,
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: 12 * widget.scale,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                12 * widget.scale,
                              ),
                            ),
                          ),
                          child: editLoading
                              ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text("Save", style: GoogleFonts.robotoMono()),
                        ),
                      ),
                      SizedBox(width: 10 * widget.scale),
                      // Secondary button: Cancel
                      SizedBox(
                        width: 120 * widget.scale,
                        child: OutlinedButton(
                          onPressed: editLoading
                              ? null
                              : () {
                                  setState(() {
                                    editMode = false;
                                    _editController.text = displayText;
                                  });
                                },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Color(0xFF334E7B),
                            side: BorderSide(
                              color: Color(0xFF334E7B),
                              width: 2 * widget.scale,
                            ),
                            textStyle: GoogleFonts.robotoMono(
                              fontSize: 20 * widget.scale,
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: 12 * widget.scale,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                12 * widget.scale,
                              ),
                            ),
                          ),
                          child: Text(
                            "Cancel",
                            style: GoogleFonts.robotoMono(),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: [
                    SizedBox(height: 15 * widget.scale),
                    // Previous and Next buttons
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20 * widget.scale,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: 140,
                            child: OutlinedButton(
                              onPressed: currentIndex > 0
                                  ? _goToPrevious
                                  : null,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Color(0xFF334E7B),
                                side: BorderSide(
                                  color: Color(0xFF334E7B),
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 0,
                                  vertical: 12,
                                ),
                              ),
                              child: Text(
                                'Previous',
                                style: GoogleFonts.robotoMono(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          SizedBox(
                            width: 140,
                            child: ElevatedButton(
                              onPressed: currentIndex < widget.items.length - 1
                                  ? _goToNext
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF334E7B),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 0,
                                  vertical: 12,
                                ),
                              ),
                              child: Text(
                                'Next',
                                style: GoogleFonts.robotoMono(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _enterFullScreen(String filePath, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            FullScreenMediaViewer(filePath: filePath, title: title),
      ),
    );
  }
}

class Words_Phrases_Cards extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final Color cardColor;
  final double scale;
  final Function(String, bool) onFavoriteToggle;
  final Function(String) onDelete;

  const Words_Phrases_Cards({
    Key? key,
    required this.data,
    required this.cardColor,
    required this.scale,
    required this.onFavoriteToggle,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final phrase = data[index];
        final String displayText = phrase['words'];
        final String entryId = phrase['entry_id'];
        final bool isFavorited = (phrase['is_favorite'] == 1);

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CardDetailScreen(
                  title: displayText,
                  color: cardColor,
                  index: index,
                  items: data,
                  scale: scale,
                  onDelete: onDelete,
                  entryId: entryId,
                ),
              ),
            );
          },
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: 20 * scale,
              vertical: 8 * scale,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15 * scale),
              border: Border.all(color: cardColor, width: 1.5 * scale),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12 * scale),
                    bottomLeft: Radius.circular(12 * scale),
                  ),
                  child: Container(
                    width: 95 * scale,
                    height: 80 * scale,
                    color: const Color(0xFF1C2E4A),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12 * scale,
                      vertical: 8 * scale,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            displayText,
                            style: GoogleFonts.robotoMono(
                              fontSize: 20 * scale,
                              color: cardColor,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        InteractiveStarIcon(
                          scale: scale,
                          initialStarred: isFavorited,
                          onToggle: (bool isStarred) {
                            onFavoriteToggle(entryId, isStarred);
                          },
                        ),
                        SizedBox(width: 8 * scale),
                        InteractiveSpeakerIcon(
                          scale: scale,
                          text: displayText,
                          color: Colors.grey[700] ?? Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class Favorite_Words_Phrases_Cards extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final Color cardColor;
  final double scale;
  final double horizontalCardHeight;
  final double cardWidth;
  final Function(String, bool) onFavoriteToggle;
  final Function(String) onDelete;

  const Favorite_Words_Phrases_Cards({
    Key? key,
    required this.data,
    required this.cardColor,
    required this.scale,
    this.horizontalCardHeight = 180, // Adjusted height
    this.cardWidth = 180,
    required this.onFavoriteToggle,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: horizontalCardHeight * scale,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: 20 * scale,
          vertical: 10 * scale,
        ),
        itemCount: data.length,
        itemBuilder: (context, index) {
          final phrase = data[index];
          final String displayText = phrase['words'];
          final String entryId = phrase['entry_id'];
          final bool isFavorited =
              (phrase['is_favorite'] == 1); // Use 'is_favorite' key

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CardDetailScreen(
                    title: displayText,
                    color: cardColor,
                    index: index,
                    items: data,
                    scale: scale,
                    onDelete: onDelete,
                    entryId: entryId,
                  ),
                ),
              );
            },
            child: Container(
              width: cardWidth * scale,
              margin: EdgeInsets.only(right: 10 * scale),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(15 * scale),
                border: Border.all(
                  color: Color.fromARGB(255, 253, 253, 253),
                  width: 2 * scale,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2 * scale,
                    blurRadius: 5 * scale,
                    offset: Offset(0, 3 * scale),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(8 * scale),
                      child: Text(
                        displayText,
                        style: GoogleFonts.robotoMono(
                          fontSize: 20 * scale,
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8 * scale,
                    right: 8 * scale,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InteractiveSpeakerIcon(
                          scale: scale,
                          text: displayText,
                          color: Colors.white,
                        ),
                        SizedBox(width: 5 * scale),
                        InteractiveStarIcon(
                          scale: scale,
                          initialStarred: isFavorited,
                          onToggle: (bool isStarred) {
                            onFavoriteToggle(entryId, isStarred);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
