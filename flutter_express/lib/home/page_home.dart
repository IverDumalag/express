import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  final List<String> cardTitles = ["Hello", "Love", "Happy", "Cute", "Sorry"];
  final Color cardColor = const Color(0xFF334E7B); // Updated color for all cards

  final List<String> phrases = [
    "Hello", "Thank You", "Sorry", "Good Morning",
    "Good Night", "Please", "How are you?", "I love you",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 40),
            _buildSectionTitle("Favorites"),
            _buildScrollableCards(context),
            const SizedBox(height: 30),
            _buildSectionTitle("Phrases"),
            _buildPhrasesGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 300,
      decoration: const BoxDecoration(
        color: Color(0xFF2E5C9A),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(230),
          bottomRight: Radius.circular(230),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 20,
            top: 60,
            child: const Text(
              'Good Morning!',
              style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          Positioned(
            left: 20,
            top: 110,
            right: 20,
            child: Container(
              height: 150,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Welcome to ex',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Press!',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  const Spacer(),
                  const Icon(Icons.waving_hand, color: Colors.orange, size: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        title,
        style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  Widget _buildScrollableCards(BuildContext context) {
    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: cardTitles.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CardDetailScreen(
                    title: cardTitles[index],
                    color: cardColor,
                    index: index,
                    items: cardTitles,
                  ),
                ),
              );
            },
            child: Container(
              width: 180,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: cardColor, // Updated color
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Text(
                  cardTitles[index],
                  style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPhrasesGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1,
        ),
        itemCount: phrases.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CardDetailScreen(
                    title: phrases[index],
                    color: cardColor,
                    index: index,
                    items: phrases,
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: cardColor, // Updated color
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Text(
                  phrases[index],
                  style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class CardDetailScreen extends StatefulWidget {
  final String title;
  final Color color;
  final int index;
  final List<String> items;

  const CardDetailScreen({
    Key? key,
    required this.title,
    required this.color,
    required this.index,
    required this.items,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.color,
      appBar: AppBar(
        title: Text(widget.items[currentIndex]),
        backgroundColor: widget.color,
        elevation: 0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Container(
              height: 250,
              width: 250,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  widget.items[currentIndex],
                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: currentIndex > 0 ? _goToPrevious : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
                child: const Text("Back"),
              ),
              ElevatedButton(
                onPressed: currentIndex < widget.items.length - 1 ? _goToNext : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
                child: const Text("Next"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}