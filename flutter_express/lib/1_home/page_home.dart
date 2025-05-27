import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../0_components/help_widget.dart';
import '../0_components/popup_information.dart';
import 'popup_home_welcome.dart';
import 'waving_hand.dart';
import 'spinning_star.dart';
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
                // --- USER NAME, GREETING, HELP ICON SECTION ---
                Padding(
                  padding: EdgeInsets.only(
                    top: 30 * scale,
                    left: 20 * scale,
                    right: 20 * scale,
                    bottom: 10 * scale,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userFullName,
                              style: TextStyle(
                                fontSize: 22 * scale,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF334E7B),
                                fontFamily: 'Inter',
                              ),
                            ),
                            SizedBox(height: 4 * scale),
                            Text(
                              greetingMessage,
                              style: TextStyle(
                                fontSize: 16 * scale,
                                color: Colors.black87,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                      ),
                      HelpIconWidget(
                        helpTitle: 'How to Use',
                        helpText:
                            'This section displays all your saved words and phrases. You can search, filter, add new entries, mark them as favorites, or archive them.',
                      ),
                    ],
                  ),
                ),
                _buildHeader(scale),
                SizedBox(height: 40 * scale),
                Row(
                  children: [
                    _buildSectionTitle("Favorites", scale),
                    BlinkingStarIcon(scale: scale),
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
                      return Center(child: Text('Error: ${snapshot.error}'));
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
                              'Still empty, nothing to be found here ^_^',
                              style: TextStyle(
                                fontSize: 18 * scale,
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
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.add, color: Color(0xFF334E7B)),
                                onPressed: () =>
                                    setState(() => showAddModal = true),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.filter_list,
                                  color: Color(0xFF334E7B),
                                ),
                                onPressed: () {
                                  setState(() => showFilter = !showFilter);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10 * scale),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: "Search...",
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
                          SizedBox(
                            width: 10 * scale,
                          ), // Add spacing for dropdowns
                          if (showFilter) // Only show filter dropdowns if showFilter is true
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: sortBy,
                                decoration: InputDecoration(
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
                                ),
                                items: [
                                  DropdownMenuItem(
                                    value: "date-new",
                                    child: Text("Newest"),
                                  ),
                                  DropdownMenuItem(
                                    value: "date-old",
                                    child: Text("Oldest"),
                                  ),
                                  DropdownMenuItem(
                                    value: "alpha",
                                    child: Text("A-Z"),
                                  ),
                                  DropdownMenuItem(
                                    value: "alpha-rev",
                                    child: Text("Z-A"),
                                  ),
                                ],
                                onChanged: (v) {
                                  setState(() => sortBy = v!);
                                  _applyFilters();
                                },
                              ),
                            ),
                          SizedBox(
                            width: 10 * scale,
                          ), // Add spacing for dropdowns
                          if (showFilter) // Only show filter dropdowns if showFilter is true
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: activeTab,
                                decoration: InputDecoration(
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
                                ),
                                items: [
                                  DropdownMenuItem(
                                    value: "wave",
                                    child: Text("All"),
                                  ),
                                  DropdownMenuItem(
                                    value: "favorite",
                                    child: Text("Favorite"),
                                  ),
                                ],
                                onChanged: (v) {
                                  setState(() => activeTab = v!);
                                  _applyFilters();
                                },
                              ),
                            ),
                        ],
                      ),
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
                      return Center(child: Text('Error: ${snapshot.error}'));
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
                              style: TextStyle(
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
                style: TextStyle(color: Color(0xFF334E7B)),
              ),
              content: TextField(
                decoration: InputDecoration(
                  hintText: "Enter word or phrase",
                  hintStyle: TextStyle(color: Colors.grey[600]),
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
                style: TextStyle(color: Color(0xFF334E7B)),
              ),
              actions: [
                TextButton(
                  onPressed: addLoading ? null : _handleAddWord,
                  child: addLoading
                      ? CircularProgressIndicator()
                      : Text("Add", style: TextStyle(color: Color(0xFF2E5C9A))),
                ),
                TextButton(
                  onPressed: () => setState(() => showAddModal = false),
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              backgroundColor: Colors.white,
              elevation: 5,
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(double scale) {
    return Container(
      height: 300 * scale,
      decoration: BoxDecoration(
        color: Color(0xFF2E5C9A),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(230 * scale),
          bottomRight: Radius.circular(230 * scale),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 20 * scale,
            top: 60 * scale,
            child: Text(
              greetingMessage,
              style: TextStyle(
                fontSize: 28 * scale,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
          ),
          Positioned(
            left: 20 * scale,
            top: 110 * scale,
            right: 20 * scale,
            child: Container(
              height: 150 * scale,
              padding: EdgeInsets.all(16 * scale),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16 * scale),
                border: Border.all(color: Colors.black, width: 1 * scale),
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
                  PageView(
                    controller: _pageController,
                    onPageChanged: (int index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    children: [
                      _buildSlide('Welcome to ex', 'Press!', scale),
                      _buildSlide('Discover', 'Our Features!', scale),
                      _buildSlide('Have', 'Fun!', scale),
                    ],
                  ),
                  Positioned(
                    bottom: 8 * scale,
                    right: 8 * scale,
                    child: _buildPageIndicator(scale),
                  ),
                ],
              ),
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

  Widget _buildSlide(String text1, String text2, double scale) {
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
          Text(
            text1,
            style: TextStyle(
              fontSize: 20 * scale,
              fontWeight: FontWeight.w900,
              fontFamily: 'Inter',
            ),
          ),
          SizedBox(width: 5 * scale),
          Text(
            text2,
            style: TextStyle(
              fontSize: 20 * scale,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E5C9A),
              fontFamily: 'Inter',
            ),
          ),
          Spacer(),
          WavingHandIcon(scale: scale),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, double scale) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 25 * scale,
        fontWeight: FontWeight.w900,
        color: Colors.black87,
        fontFamily: 'Inter',
      ),
    );
  }
}
