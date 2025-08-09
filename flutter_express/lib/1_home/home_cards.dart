import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_express/0_components/media_viewer.dart';
import 'package:google_fonts/google_fonts.dart';
import '../00_services/api_services.dart';
import '../0_components/popup_confirmation.dart';
import '../0_components/popup_information.dart';
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
        if (widget.onToggle != null) {
          widget.onToggle!(isStarred); // Pass the new internal state
        }
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
          await flutterTts.speak(widget.text);
        } else {
          await flutterTts.stop();
          _resetLoud();
        }
      },
      child: Icon(
        isLoud ? Icons.speaker_phone : Icons.speaker,
        color: widget.color,
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
      title: "Delete Phrase",
      message: "Are you sure you want to delete this phrase?",
      confirmText: "Yes, I am sure",
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
      PopupInformation.show(
        context,
        title: "Error",
        message: "Word/Phrase cannot be empty.",
      );
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
      PopupInformation.show(
        context,
        title: "Error",
        message: "Duplicate entry not allowed.",
      );
      return;
    }

    try {
      // Try to search for a match first
      final searchJson = await ApiService.trySearch(newWords);
      String signLanguageUrl = '';
      bool matchFound = false;
      if (searchJson?['public_id'] != null &&
          searchJson?['all_files'] is List) {
        final file = (searchJson!['all_files'] as List).firstWhere(
          (f) => f['public_id'] == searchJson['public_id'],
          orElse: () => null,
        );
        if (file != null) {
          signLanguageUrl = file['url'];
          matchFound = true;
        }
      }

      // Show popup before updating
      await PopupInformation.show(
        context,
        title: matchFound ? "Match Found!" : "No Match",
        message: matchFound
            ? "A match was found for your word/phrase."
            : "No match found, but will update your entry.",
      );

      // Call API to update, now with sign_language
      final result = await ApiService.editCard(
        entryId: entryId,
        words: newWords,
        signLanguage: signLanguageUrl,
      );
      if (result['status'] == 200 || result['status'] == "200") {
        setState(() {
          editMode = false;
          widget.items[currentIndex]['words'] = newWords;
          widget.items[currentIndex]['sign_language'] = signLanguageUrl;
        });
        if (widget.onEdit != null) {
          widget.onEdit!(widget.items[currentIndex]);
        }
        PopupInformation.show(
          context,
          title: "Success!",
          message: "Updated successfully.",
        );
      } else {
        PopupInformation.show(
          context,
          title: "Error",
          message: "Failed to update.",
        );
      }
    } catch (e) {
      PopupInformation.show(
        context,
        title: "Error",
        message: "Error updating phrase.",
      );
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
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),

        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Color(0xFF334E7B)),
            onPressed: () {
              setState(() {
                editMode = true;
                _editController.text = displayText;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Color(0xFF334E7B)),
            onPressed: _deletePhrase,
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 20 * widget.scale),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20 * widget.scale),
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
                              borderSide: BorderSide(color: Color(0xFF334E7B)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Color(0xFF2E5C9A)),
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
                            color: Color(0xFF2354C7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                ),
                SizedBox(width: 4 * widget.scale),
                if (!editMode)
                  Padding(
                    padding: EdgeInsets.only(
                      left: 2 * widget.scale,
                    ), // Move icon closer to text
                    child: InteractiveSpeakerIcon(
                      scale: widget.scale,
                      text: displayText,
                      color: Color(0xFF2354C7),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 20 * widget.scale),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20 * widget.scale),
            child: MediaViewer(filePath: signLanguagePath, scale: widget.scale),
          ),
          SizedBox(height: 60 * widget.scale),
          if (editMode)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20 * widget.scale),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: editLoading ? null : _editPhrase,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xF1C2E4A),
                      foregroundColor: Colors.white,
                      textStyle: GoogleFonts.robotoMono(
                        fontSize: 20 * widget.scale,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 24 * widget.scale,
                        vertical: 12 * widget.scale,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5 * widget.scale),
                        side: BorderSide(
                          color: Colors.white,
                          width: 2 * widget.scale,
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
                  SizedBox(width: 10 * widget.scale),
                  ElevatedButton(
                    onPressed: editLoading
                        ? null
                        : () {
                            setState(() {
                              editMode = false;
                              _editController.text = displayText;
                            });
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Color(0xF1C2E4A),
                      textStyle: GoogleFonts.robotoMono(
                        fontSize: 20 * widget.scale,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 24 * widget.scale,
                        vertical: 12 * widget.scale,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5 * widget.scale),
                        side: BorderSide(
                          color: Color(0xF1C2E4A),
                          width: 2 * widget.scale,
                        ),
                      ),
                    ),
                    child: Text("Cancel", style: GoogleFonts.robotoMono()),
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20 * widget.scale),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: currentIndex > 0 ? _goToPrevious : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xF1C2E4A),
                        foregroundColor: Colors.white,
                        textStyle: GoogleFonts.robotoMono(
                          fontSize: 20 * widget.scale,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 24 * widget.scale,
                          vertical: 12 * widget.scale,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5 * widget.scale),
                          side: BorderSide(
                            color: Colors.white,
                            width: 2 * widget.scale,
                          ),
                        ),
                      ),
                      child: Text("Previous", style: GoogleFonts.robotoMono()),
                    ),
                  ),
                  SizedBox(width: 10 * widget.scale),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: currentIndex < widget.items.length - 1
                          ? _goToNext
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF334E7B),
                        foregroundColor: Colors.white,
                        textStyle: GoogleFonts.robotoMono(
                          fontSize: 20 * widget.scale,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 24 * widget.scale,
                          vertical: 12 * widget.scale,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5 * widget.scale),
                          side: BorderSide(
                            color: Colors.white,
                            width: 2 * widget.scale,
                          ),
                        ),
                      ),
                      child: Text("Next", style: GoogleFonts.robotoMono()),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// A widget that displays a grid of word/phrase cards.
/// Each card can be tapped to view details, has a speaker icon, and a favorite star.
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
                          color: Colors.grey[700]!,
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
