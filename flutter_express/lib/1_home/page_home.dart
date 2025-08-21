import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../0_components/help_widget.dart';
import '../0_components/popup_information.dart';
import 'popup_home_welcome.dart';
import 'waving_hand.dart';
import '../main.dart';
import '../global_variables.dart';
import 'home_cards.dart';
import '../00_services/api_services.dart';

class Home extends StatefulWidget {
  final VoidCallback onRefresh;

  Home({required this.onRefresh});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Color cardColor = const Color(0xFF334E7B);

  String greetingMessage = '';
  String search = '';
  String sortBy = 'date-new';
  String activeTab = 'wave';
  bool showFilter = false;
  bool loading = true;
  bool showAddModal = false;
  bool addLoading = false;
  String addInput = '';

  List<Map<String, dynamic>> cards = [];
  List<Map<String, dynamic>> filteredCards = [];

  late final PageController _pageController;
  int _currentPage = 0;
  late Timer _timer;
  final int _numSlides = 3;

  bool _popupShown = false;
  bool _needsRefresh = true;

  String userFullName = '';

  @override
  void initState() {
    super.initState();
    _updateGreetingMessage();
    _fetchCards();
    _setUserFullName();

    _pageController = PageController(initialPage: _currentPage);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _popupShown = prefs.getBool('popupShown') ?? false;
      if (!_popupShown) {
        _showPopupNotice(context);
      }
    });

    _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      int nextPage = _currentPage + 1;
      if (nextPage >= _numSlides) {
        nextPage = 0;
      }
      _pageController.animateToPage(
        nextPage,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _setUserFullName() {
    final user = UserSession.user;
    if (user != null) {
      final fName = user['f_name'] ?? '';
      final mName = user['m_name'] ?? '';
      final lName = user['l_name'] ?? '';
      userFullName = [
        fName,
        mName,
        lName,
      ].where((s) => s.trim().isNotEmpty).join(' ');
    }
  }

  void _updateGreetingMessage() {
    final hour = DateTime.now().hour;
    final user = UserSession.user;
    String name = '';
    if (user != null) {
      final fName = user['f_name'] ?? '';
      name = fName.toString().trim().isNotEmpty ? fName : '';
    }
    if (hour < 12) {
      greetingMessage = 'Good Morning${name.isNotEmpty ? ', $name' : ''}!';
    } else if (hour < 17) {
      greetingMessage = 'Good Afternoon${name.isNotEmpty ? ', $name' : ''}!';
    } else {
      greetingMessage = 'Good Evening${name.isNotEmpty ? ', $name' : ''}!';
    }
  }

  Future<void> _fetchCards() async {
    setState(() => loading = true);
    final userId = UserSession.user?['user_id']?.toString() ?? "";
    final data = await ApiService.fetchCards(userId);
    setState(() {
      cards = data.where((c) => c['status'] == 'active').toList();
      loading = false;
    });
    _applyFilters();
  }

  void _applyFilters() {
    List<Map<String, dynamic>> result = List.from(cards);
    if (activeTab == 'favorite') {
      result = result.where((c) => c['is_favorite'] == 1).toList();
    }
    if (search.trim().isNotEmpty) {
      result = result
          .where(
            (c) => (c['words'] ?? '').toString().toLowerCase().contains(
              search.toLowerCase(),
            ),
          )
          .toList();
    }
    int naturalCompare(String a, String b) =>
        a.toLowerCase().compareTo(b.toLowerCase());
    if (sortBy == 'alpha') {
      result.sort(
        (a, b) => naturalCompare(
          (a['words'] ?? '').toString(),
          (b['words'] ?? '').toString(),
        ),
      );
    } else if (sortBy == 'alpha-rev') {
      result.sort(
        (a, b) => naturalCompare(
          (b['words'] ?? '').toString(),
          (a['words'] ?? '').toString(),
        ),
      );
    } else if (sortBy == 'date-new') {
      result.sort(
        (a, b) => DateTime.parse(
          b['created_at'],
        ).compareTo(DateTime.parse(a['created_at'])),
      );
    } else if (sortBy == 'date-old') {
      result.sort(
        (a, b) => DateTime.parse(
          a['created_at'],
        ).compareTo(DateTime.parse(b['created_at'])),
      );
    }
    setState(() => filteredCards = result);
  }

  void _showPopupNotice(BuildContext context) async {
    WelcomePopup.show(context);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('popupShown', true);
  }

  void _showFeedbackPopup(String message, String type) async {
    await PopupInformation.show(
      context,
      title: type == "success"
          ? "Success!"
          : type == "error"
          ? "Error"
          : "Information",
      message: message,
    );
  }

  Future<void> _handleAddWord() async {
    if (addInput.trim().isEmpty) return;
    setState(() => addLoading = true);

    final normalizedInput = addInput.trim().toLowerCase();
    if (cards.any(
      (c) =>
          (c['words'] ?? '').toString().trim().toLowerCase() == normalizedInput,
    )) {
      _showFeedbackPopup("Duplicate entry not allowed.", "error");
      setState(() => addLoading = false);
      return;
    }

    String signLanguageUrl = '';
    int isMatch = 0;
    bool matchFound = false;
    try {
      final searchJson = await ApiService.trySearch(addInput);
      if (searchJson?['public_id'] != null &&
          searchJson?['all_files'] is List) {
        final file = (searchJson!['all_files'] as List).firstWhere(
          (f) => f['public_id'] == searchJson['public_id'],
          orElse: () => null,
        );
        if (file != null) {
          signLanguageUrl = file['url'];
          isMatch = 1;
          matchFound = true;
        }
      }
      final userId = UserSession.user?['user_id']?.toString() ?? "";
      final insertJson = await ApiService.addCard(
        userId: userId,
        words: addInput,
        signLanguageUrl: signLanguageUrl,
        isMatch: isMatch,
      );
      if (insertJson['status'] == 201 || insertJson['status'] == "201") {
        setState(() {
          cards.insert(0, {
            'entry_id': insertJson['entry_id'],
            'words': addInput,
            'sign_language': signLanguageUrl,
            'is_favorite': 0,
            'created_at': DateTime.now().toIso8601String(),
            'status': 'active',
          });
          addInput = '';
          showAddModal = false;
          _needsRefresh = true; // Trigger refresh for Words/Phrases section
        });
        _applyFilters();
        _showFeedbackPopup(
          matchFound
              ? "Match Found!"
              : "No match found, but added to your list.",
          matchFound ? "success" : "info",
        );
      } else {
        _showFeedbackPopup("Failed to add.", "error");
      }
    } catch (e) {
      _showFeedbackPopup("Error adding word/phrase.", "error");
    }
    setState(() => addLoading = false);
  }

  Future<void> _handleArchive(String entryId) async {
    await ApiService.updateStatus(entryId: entryId, status: "archived");
    setState(() {
      cards.removeWhere((c) => c['entry_id'] == entryId);
      _needsRefresh = true; // Trigger refresh for Words/Phrases section
    });
    _applyFilters();
    _showFeedbackPopup("Archived!", "info");
  }

  Future<void> _handleFavorite(String entryId, bool isFavorite) async {
    // Call your API to update favorite status
    await ApiService.updateFavoriteStatus(
      entryId: entryId,
      isFavorite: isFavorite ? 1 : 0,
    );
    setState(() {
      cards = cards.map((c) {
        if (c['entry_id'] == entryId) {
          return {...c, 'is_favorite': isFavorite ? 1 : 0};
        }
        return c;
      }).toList();
      _needsRefresh = true; // Trigger refresh for both sections
    });
    _applyFilters(); // Re-apply filters to update favorite list if activeTab is 'favorite'
  }

  double scaleFactor(BuildContext context) {
    final baseWidth = 375.0;
    return MediaQuery.of(context).size.width / baseWidth;
  }

  @override
  Widget build(BuildContext context) {
    final scale = scaleFactor(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ...existing code...
                _buildHeader(scale),
                SizedBox(height: 40 * scale),
                Row(
                  children: [
                    SizedBox(width: 20 * scale),
                    _buildSectionTitle("Favorites", scale),
                  ],
                ),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _needsRefresh
                      ? ApiService.fetchCards(
                          UserSession.user?['user_id']?.toString() ?? "",
                        )
                      : null,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: GoogleFonts.robotoMono(),
                        ),
                      );
                    } else {
                      _needsRefresh = false;
                      final favoritePhrases = snapshot.data!
                          .where(
                            (phrase) =>
                                phrase['is_favorite'] == 1 &&
                                phrase['status'] == 'active',
                          )
                          .toList();
                      if (favoritePhrases.isEmpty) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20 * scale),
                          child: Container(
                            margin: EdgeInsets.only(top: 10 * scale),
                            child: Text(
                              'Still empty, nothing to be found here',
                              style: GoogleFonts.robotoMono(
                                fontSize: 15 * scale,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        );
                      }
                      return Favorite_Words_Phrases_Cards(
                        data: favoritePhrases,
                        cardColor: cardColor,
                        scale: scale,
                        onFavoriteToggle: _handleFavorite,
                        onDelete: _handleArchive,
                      );
                    }
                  },
                ),
                SizedBox(height: 30 * scale),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20 * scale),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSectionTitle("Words/Phrases", scale),
                          // Icons removed as they are now present beside the search bar
                        ],
                      ),
                      SizedBox(height: 10 * scale),
                      Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.62,
                            child: TextField(
                              style: GoogleFonts.robotoMono(),
                              decoration: InputDecoration(
                                hintText: "Search",
                                hintStyle: GoogleFonts.robotoMono(),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Color(0xFF334E7B),
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,                        
                                  vertical: 8,
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: Color(0xFF334E7B),
                                ),
                              ),
                              onChanged: (v) {
                                setState(() => search = v);
                                _applyFilters();
                              },
                            ),
                          ),
                          SizedBox(width: 10 * scale),
                          IconButton(
                            icon: Icon(Icons.add, color: Color(0xFF334E7B)),
                            onPressed: () => setState(() => showAddModal = true),
                          ),
                          IconButton(
                            icon: Icon(Icons.filter_list, color: Color(0xFF334E7B)),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                                  side: BorderSide(color: Color(0xFF334E7B)),
                                ),
                                builder: (context) {
                                  return Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Theme(
                                      data: Theme.of(context).copyWith(
                                        canvasColor: Colors.white,
                                        dialogBackgroundColor: Colors.white,
                                        inputDecorationTheme: InputDecorationTheme(
                                          fillColor: Colors.white,
                                          filled: true,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            borderSide: BorderSide(color: Color(0xFF334E7B)),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            borderSide: BorderSide(color: Color(0xFF334E7B)),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            borderSide: BorderSide(color: Color(0xFF334E7B), width: 2),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("Sort by", style: GoogleFonts.robotoMono(fontWeight: FontWeight.bold)),
                                          DropdownButtonFormField<String>(
                                            value: sortBy,
                                            style: GoogleFonts.robotoMono(color: Colors.black),
                                            dropdownColor: Colors.white,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(8),
                                                borderSide: BorderSide(color: Color(0xFF334E7B)),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(8),
                                                borderSide: BorderSide(color: Color(0xFF334E7B)),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(8),
                                                borderSide: BorderSide(color: Color(0xFF334E7B), width: 2),
                                              ),
                                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                              fillColor: Colors.white,
                                              filled: true,
                                            ),
                                            items: [
                                              DropdownMenuItem(value: "date-new", child: Text("Newest", style: GoogleFonts.robotoMono())),
                                              DropdownMenuItem(value: "date-old", child: Text("Oldest", style: GoogleFonts.robotoMono())),
                                              DropdownMenuItem(value: "alpha", child: Text("A-Z", style: GoogleFonts.robotoMono())),
                                              DropdownMenuItem(value: "alpha-rev", child: Text("Z-A", style: GoogleFonts.robotoMono())),
                                            ],
                                            onChanged: (v) {
                                              setState(() => sortBy = v!);
                                              _applyFilters();
                                              Navigator.pop(context);
                                            },
                                          ),
                                          SizedBox(height: 20),
                                          Text("Show", style: GoogleFonts.robotoMono(fontWeight: FontWeight.bold)),
                                          DropdownButtonFormField<String>(
                                            value: activeTab,
                                            style: GoogleFonts.robotoMono(color: Colors.black),
                                            dropdownColor: Colors.white,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(8),
                                                borderSide: BorderSide(color: Color(0xFF334E7B)),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(8),
                                                borderSide: BorderSide(color: Color(0xFF334E7B)),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(8),
                                                borderSide: BorderSide(color: Color(0xFF334E7B), width: 2),
                                              ),
                                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                              fillColor: Colors.white,
                                              filled: true,
                                            ),
                                            items: [
                                              DropdownMenuItem(value: "wave", child: Text("All", style: GoogleFonts.robotoMono())),
                                              DropdownMenuItem(value: "favorite", child: Text("Favorite", style: GoogleFonts.robotoMono())),
                                            ],
                                            onChanged: (v) {
                                              setState(() => activeTab = v!);
                                              _applyFilters();
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 20 * scale), // Add space between search/filter and cards
                    ],
                  ),
                ),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _needsRefresh
                      ? ApiService.fetchCards(
                          UserSession.user?['user_id']?.toString() ?? "",
                        )
                      : null,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: GoogleFonts.robotoMono(),
                        ),
                      );
                    } else {
                      _needsRefresh = false;
                      // Ensure filteredCards is populated based on fresh data
                      // This might cause a slight delay, but ensures consistency
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _fetchCards(); // Re-fetch to apply filters based on latest data
                      });

                      if (filteredCards.isEmpty) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20 * scale),
                          child: Container(
                            margin: EdgeInsets.only(top: 10 * scale),
                            child: Text(
                              'No matching words or phrases found. Try adjusting your search or filters.',
                              style: GoogleFonts.robotoMono(
                                fontSize: 18 * scale,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        );
                      }
                      return Words_Phrases_Cards(
                        data:
                            filteredCards, // Use filteredCards for this section
                        cardColor: cardColor,
                        scale: scale,
                        onFavoriteToggle: _handleFavorite,
                        onDelete: _handleArchive,
                      );
                    }
                  },
                ),
                SizedBox(height: 20 * scale), // Add some bottom padding
              ],
            ),
          ),
          if (showAddModal)
            AlertDialog(
              title: Text(
                "Add Word/Phrase",
                style: GoogleFonts.robotoMono(
                  color: Color(0xFF334E7B),
                  fontWeight: FontWeight.w500,
                  fontSize: 15 * scale,
                ),
              ),
              insetPadding: EdgeInsets.symmetric(
                horizontal: 40 * scale,
              ), // Increase horizontal padding for wider dialog
              contentPadding: EdgeInsets.all(
                24 * scale,
              ), // Optional: more spacious content
              content: TextField(
                style: GoogleFonts.robotoMono(
                  color: Color(0xFF334E7B),
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: "Enter word or phrase",
                  hintStyle: GoogleFonts.robotoMono(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xFF334E7B)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xFF2E5C9A)),
                  ),
                ),
                onChanged: (v) => addInput = v,
              ),
              actions: [
                TextButton(
                  onPressed: addLoading ? null : _handleAddWord,
                  child: addLoading
                      ? CircularProgressIndicator()
                      : Text(
                          "Add",
                          style: GoogleFonts.robotoMono(
                            color: Color(0xFF2E5C9A),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
                TextButton(
                  onPressed: () => setState(() => showAddModal = false),
                  child: Text(
                    "Cancel",
                    style: GoogleFonts.robotoMono(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
                side: BorderSide(color: Color(0xFF334E7B), width: 2),
              ),
              backgroundColor: Colors.white,
              elevation: 8,
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(double scale) {
    return Container(
      padding: EdgeInsets.only(
        top: 50 * scale,
        left: 20 * scale,
        right: 20 * scale,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add a tappable Row for the tip icon above the greeting
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: Colors.white,
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    side: BorderSide(color: Color(0xFF334E7B), width: 2),
                  ),
                  title: Text(
                    'Hi!',
                    style: GoogleFonts.robotoMono(
                      color: Color(0xFF334E7B),
                      fontWeight: FontWeight.bold,
                      fontSize: 18 * scale,
                    ),
                  ),
                    content: Text(
                    'This is the homepage. Explore to use your favorites, words, and phrases. You may add words and phrases by navigating through this section.',
                    style: GoogleFonts.robotoMono(
                      color: Color(0xFF334E7B),
                      fontSize: 15 * scale,
                    ),
                    textAlign: TextAlign.justify,
                    ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Close',
                        style: GoogleFonts.robotoMono(
                          color: Color(0xFF2E5C9A),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.help, // Filled question mark tip icon
                  color: Color(0xFF2E5C9A),
                  size: 28 * scale,
                ),
              ],
            ),
          ),
          SizedBox(height: 10 * scale),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/graphichome1.png',
                width: 80 * scale,
                height: 80 * scale,
              ),
              SizedBox(width: 16 * scale),
              Expanded(
                child: RichText(
                  textAlign: TextAlign.left,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: greetingMessage.split(',').first,
                        style: GoogleFonts.robotoMono(
                          fontSize: 21 * scale,
                          color: Color(0xFF2E5C9A),
                          fontWeight: FontWeight.w300,
                          shadows: [
                            Shadow(
                              blurRadius: 4,
                              color: Colors.white,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                      if (greetingMessage.contains(','))
                        TextSpan(
                          text: greetingMessage.substring(
                            greetingMessage.indexOf(','),
                          ),
                          style: GoogleFonts.robotoMono(
                            fontSize: 22 * scale,
                            color: Color(0xFF2E5C9A),
                            fontWeight: FontWeight.w600,
                            shadows: [
                              Shadow(
                                blurRadius: 4,
                                color: Colors.white,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 0.1 * scale),
          Container(
            height: 120 * scale, // Reduced height
            padding: EdgeInsets.all(8 * scale), // Reduced padding
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16 * scale),
              border: Border.all(color: Color(0xFF334E7B), width: 2 * scale),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 1 * scale,
                  blurRadius: 6 * scale,
                  offset: Offset(0, 3 * scale),
                ),
              ],
            ),
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: 20 * scale,
                  ), // Move slides a bit to the right
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (int index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    children: [

                        _buildSlide('Welcome to ex', 'Press!', scale, fontSize: 16),
                        _buildSlide('Discover', 'Our Features!', scale, fontSize: 16),
                        _buildSlide('Have', 'Fun!', scale, fontSize: 18),

                    ],
                  ),
                ),
                Positioned(
                  bottom: 8 * scale,
                  right: 8 * scale,
                  child: _buildPageIndicator(scale),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(double scale) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_numSlides, (index) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 2 * scale),
          width: 8 * scale,
          height: 8 * scale,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index ? Colors.blue : Colors.grey,
          ),
        );
      }),
    );
  }

  Widget _buildSlide(String text1, String text2, double scale, {double fontSize = 14}) {

    if (text1 == 'Welcome to ex' && text2 == 'Press!') {
      return GestureDetector(
        onTap: () {
          // Keep your navigation logic here if needed
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome to',
                    style: GoogleFonts.robotoMono(
                      fontSize: 23 * scale,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4 * scale),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'ex',
                          style: GoogleFonts.robotoMono(
                            fontSize: 23 * scale,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: 'Press!',
                          style: GoogleFonts.robotoMono(
                            fontSize: 23 * scale,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF2E5C9A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12 * scale),
            WavingHandIcon(scale: scale),
          ],
        ),
      );
    }
    if (text1 == 'Discover' && text2 == 'Our Features!') {
      return GestureDetector(
        onTap: () {
          GlobalVariables.currentIndex = 1;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MainScreen(setIndex: 1)),
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Discover',
                    style: GoogleFonts.robotoMono(
                      fontSize: 23 * scale,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4 * scale),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Our ',
                          style: GoogleFonts.robotoMono(
                            fontSize: 23 * scale,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: 'Features!',
                          style: GoogleFonts.robotoMono(
                            fontSize: 23 * scale,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF2E5C9A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12 * scale),
            WavingHandIcon(scale: scale),
          ],
        ),
      );
    }
    if (text1 == 'Have' && text2 == 'Fun!') {
      return GestureDetector(
        onTap: () {
          GlobalVariables.currentIndex = 2;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MainScreen(setIndex: 2)),
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Have ',
                      style: GoogleFonts.robotoMono(
                        fontSize: 23 * scale,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: 'Fun!',
                      style: GoogleFonts.robotoMono(
                        fontSize: 23 * scale,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2E5C9A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 12 * scale),

            WavingHandIcon(scale: scale),
          ],
        ),
      );
    }
    return GestureDetector(
      onTap: () {
        if (text1 == 'Discover' && text2 == 'Our Features!') {
          GlobalVariables.currentIndex = 1;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MainScreen(setIndex: 1)),
          );
        } else if (text1 == 'Have' && text2 == 'Fun!') {
          GlobalVariables.currentIndex = 2;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MainScreen(setIndex: 2)),
          );
        }
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    text1,
                    style: GoogleFonts.robotoMono(

                      fontSize: fontSize * scale,

                      fontWeight: FontWeight.w900,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 4 * scale),
                Flexible(
                  child: Text(
                    text2,
                    style: GoogleFonts.robotoMono(

                      fontSize: fontSize * scale,

                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E5C9A),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          WavingHandIcon(scale: scale),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, double scale) {
    return Text(
      title,
      style: GoogleFonts.robotoMono(

        fontSize: 18 * scale,

        fontWeight: FontWeight.w900,
        color: Colors.black87,
      ),
    );
  }
}