import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isStarred = !isStarred;
        });
        if (widget.onToggle != null) {
          widget.onToggle!(isStarred);
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

class InteractiveSpeakerIcon extends StatefulWidget {
  final double scale;
  final String text;

  const InteractiveSpeakerIcon({
    Key? key,
    required this.scale,
    required this.text,
  }) : super(key: key);

  @override
  _InteractiveSpeakerIconState createState() => _InteractiveSpeakerIconState();
}

class _InteractiveSpeakerIconState extends State<InteractiveSpeakerIcon> {
  bool isLoud = false;
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    flutterTts.awaitSpeakCompletion(true);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (!isLoud) {
          setState(() {
            isLoud = true;
          });
          await flutterTts.speak(widget.text);
          if (mounted) {
            setState(() {
              isLoud = false;
            });
          }
        } else {
          await flutterTts.stop();
          if (mounted) {
            setState(() {
              isLoud = false;
            });
          }
        }
      },
      child: Icon(
        isLoud ? Icons.speaker : Icons.speaker_phone,
        color: Colors.white,
        size: 30 * widget.scale,
      ),
    );
  }
}

class CardDetailScreen extends StatefulWidget {
  final String title;
  final Color color;
  final int index;
  final List<String> items;
  final double scale;
  final Function(String) onDelete;
  final String entryId;

  const CardDetailScreen({
    Key? key,
    required this.title,
    required this.color,
    required this.index,
    required this.items,
    required this.scale,
    required this.onDelete,
    required this.entryId,
  }) : super(key: key);

  @override
  _CardDetailScreenState createState() => _CardDetailScreenState();
}

class _CardDetailScreenState extends State<CardDetailScreen> {
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.index;
  }

  void _goToNext() {
    if (currentIndex < widget.items.length - 1) {
      setState(() {
        currentIndex++;
      });
    }
  }

  void _goToPrevious() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
    }
  }

  void _deletePhrase() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Phrase'),
        content: Text('Are you sure you want to delete this phrase?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              widget.onDelete(widget.entryId);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.color,
      appBar: AppBar(
        title: Text(widget.items[currentIndex],
            style: TextStyle(fontSize: 20 * widget.scale)),
        backgroundColor: widget.color,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _deletePhrase,
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 20 * widget.scale),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.items[currentIndex],
                style: TextStyle(
                  fontSize: 30 * widget.scale,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 10 * widget.scale),
              InteractiveSpeakerIcon(
                  scale: widget.scale, text: widget.items[currentIndex]),
            ],
          ),
          SizedBox(height: 20 * widget.scale),
          Center(
            child: Container(
              height: 350 * widget.scale,
              width: 300 * widget.scale,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/nerd.png'),
                  fit: BoxFit.fitHeight,
                ),
                borderRadius: BorderRadius.circular(20 * widget.scale),
                border: Border.all(
                    color: Color(0xFF051B4E), width: 2 * widget.scale),
              ),
            ),
          ),
          SizedBox(height: 60 * widget.scale),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: currentIndex > 0 ? _goToPrevious : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  textStyle: TextStyle(
                      fontSize: 20 * widget.scale, fontFamily: 'Inter'),
                  padding: EdgeInsets.symmetric(
                      horizontal: 24 * widget.scale,
                      vertical: 12 * widget.scale),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5 * widget.scale),
                    side: BorderSide(
                        color: Color(0xFF051B4E), width: 2 * widget.scale),
                  ),
                ),
                child: Text("Back"),
              ),
              ElevatedButton(
                onPressed:
                    currentIndex < widget.items.length - 1 ? _goToNext : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  textStyle: TextStyle(
                      fontSize: 20 * widget.scale, fontFamily: 'Inter'),
                  padding: EdgeInsets.symmetric(
                      horizontal: 24 * widget.scale,
                      vertical: 12 * widget.scale),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5 * widget.scale),
                    side: BorderSide(
                        color: Color(0xFF051B4E), width: 2 * widget.scale),
                  ),
                ),
                child: Text("Next"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Words_Phrases_Cards extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final Color cardColor;
  final double scale;
  final double cardWidth;
  final int gridCrossAxisCount;
  final double gridSpacing;
  final double gridChildAspectRatio;
  final Function(String, bool) onFavoriteToggle;
  final Function(String) onDelete;

  const Words_Phrases_Cards({
    Key? key,
    required this.data,
    required this.cardColor,
    required this.scale,
    this.cardWidth = 180,
    this.gridCrossAxisCount = 2,
    this.gridSpacing = 10,
    this.gridChildAspectRatio = 1,
    required this.onFavoriteToggle,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 20 * scale,
        vertical: 10 * scale,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: gridCrossAxisCount,
          crossAxisSpacing: gridSpacing * scale,
          mainAxisSpacing: gridSpacing * scale,
          childAspectRatio: gridChildAspectRatio,
        ),
        itemCount: data.length,
        itemBuilder: (context, index) {
          final phrase = data[index];
          final String displayText = phrase['words'];
          final String entryId = phrase['entry_id'];
          final bool isFavorited = (phrase['favorite'] == 1);
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CardDetailScreen(
                    title: displayText,
                    color: cardColor,
                    index: index,
                    items: data.map((e) => e['words'] as String).toList(),
                    scale: scale,
                    onDelete: onDelete,
                    entryId: entryId,
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(15 * scale),
                border: Border.all(color: Color(0xFF051B4E), width: 2 * scale),
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
                    child: Text(
                      displayText,
                      style: TextStyle(
                        fontSize: 20 * scale,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Positioned(
                    bottom: 8 * scale,
                    right: 8 * scale,
                    child: Row(
                      children: [
                        InteractiveSpeakerIcon(scale: scale, text: displayText),
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
                  Positioned(
                    top: 8 * scale,
                    right: 8 * scale,
                    child: Container(
                      width: 20 * scale,
                      height: 20 * scale,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.5),
                      ),
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
    this.horizontalCardHeight = 300,
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
          final bool isFavorited = (phrase['favorite'] == 1);
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CardDetailScreen(
                    title: displayText,
                    color: cardColor,
                    index: index,
                    items: data.map((e) => e['words'] as String).toList(),
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
                border: Border.all(color: Color(0xFF051B4E), width: 2 * scale),
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
                    child: Text(
                      displayText,
                      style: TextStyle(
                        fontSize: 20 * scale,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Positioned(
                    bottom: 8 * scale,
                    right: 8 * scale,
                    child: Row(
                      children: [
                        InteractiveSpeakerIcon(scale: scale, text: displayText),
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
                  Positioned(
                    top: 8 * scale,
                    right: 8 * scale,
                    child: Container(
                      width: 20 * scale,
                      height: 20 * scale,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.5),
                      ),
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
