import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left,
            color: Color(0xFF334E7B),
            size: 32,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Help',
          style: GoogleFonts.poppins(
            color: const Color(0xFF334E7B),
            fontWeight: FontWeight.w700,
            fontSize: 22,
            letterSpacing: 0.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF334E7B),
        elevation: 0,
        surfaceTintColor: Colors.white,
        shadowColor: Colors.transparent,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FAQPage()),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Frequently Asked Questions',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334E7B),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Color(0xFF334E7B)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// FAQ Page
class FAQPage extends StatefulWidget {
  @override
  _FAQPageState createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _currentPage = 0;
  static const int _itemsPerPage = 5;
  
  final List<Map<String, String>> faqData = [
    {
      'question': 'What is exPress?',
      'answer': 'exPress is a mobile and web-based communication tool that translates sign language into text and text or audio into sign language animations, helping bridge conversations between deaf individuals and non-signers.'
    },
    {
      'question': 'Is exPress an e-learning app?',
      'answer': 'No. exPress is not an e-learning platform. Its main purpose is to support real-time communication, not structured teaching.'
    },
    {
      'question': 'Which languages does exPress support?',
      'answer': 'Currently, exPress supports international sign language datasets from Kaggle and Filipino Sign Language (FSL) data from Mendeley. More sign languages will be added in future updates.'
    },
    {
      'question': 'Do I need internet access to use exPress?',
      'answer': 'Most features require internet to ensure accuracy, but we are working on adding offline capabilities in upcoming versions.'
    },
    {
      'question': 'Why is the Roboto Mono font used in the system?',
      'answer': 'Roboto Mono is chosen because it is optimized for readability across different screens and devices, making text easy to read in both web and mobile environments. Its clean, monospaced design ensures consistent alignment and clear distinction of characters, which improves the overall user experience and interface clarity.'
    },
    {
      'question': 'What are the colors used in the system and why were they chosen?',
      'answer': 'The colors White (#FFFFFF), Cyan-Blue (#334E7B), and Ultramarine Blue (#4C75F2) were chosen to create a clean, modern, and professional visual style. White provides a neutral and spacious background that enhances readability, Cyan-Blue conveys trust and stability suitable for formal systems, and Ultramarine Blue adds vibrancy to highlight key elements. Together, these colors create a balanced contrast that improves user focus and ensures a visually appealing and consistent interface across web and mobile platforms.'
    },
    {
      'question': 'How accurate is exPress?',
      'answer': 'exPress uses machine learning trained on both international and Filipino datasets. While accuracy improves with each update, variations in signing style may affect results.'
    },
    {
      'question': 'How can I send feedback?',
      'answer': 'You can easily share feedback through the Feedback Section in the app menu. We welcome your ideas to improve exPress.'
    },
    {
      'question': 'Does exPress work on all devices?',
      'answer': 'exPress is designed to run on most modern Android as well as web browsers. Some older devices may have limited functionality due to camera or processing restrictions.'
    },
    {
      'question': 'Will exPress work in low-light environments?',
      'answer': 'For best results, use the app in good lighting. Poor lighting may affect gesture recognition accuracy, but improvements are being developed to handle more conditions.'
    },
    {
      'question': 'Can exPress be used in schools or workplaces?',
      'answer': 'Yes. exPress is a communication support tool that can help in classrooms, offices, healthcare, and public service settings where inclusive interaction is needed.'
    },
    {
      'question': 'How often is the app updated?',
      'answer': 'The development team regularly releases updates to improve accuracy, add new features, and expand language support. Make sure to keep your app updated for the best experience.'
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, String>> get filteredFAQs {
    if (_searchQuery.isEmpty) {
      return faqData;
    }
    return faqData.where((faq) {
      return faq['question']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             faq['answer']!.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  List<Map<String, String>> get paginatedFAQs {
    final filtered = filteredFAQs;
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, filtered.length);
    
    if (startIndex >= filtered.length) return [];
    
    return filtered.sublist(startIndex, endIndex);
  }

  int get totalPages {
    return (filteredFAQs.length / _itemsPerPage).ceil();
  }

  void _goToPage(int page) {
    setState(() {
      _currentPage = page.clamp(0, totalPages - 1);
    });
  }

  void _resetPagination() {
    setState(() {
      _currentPage = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final horizontalPadding = isTablet ? 24.0 : 16.0;
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left,
            color: Color(0xFF334E7B),
            size: 32,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'FAQ',
          style: GoogleFonts.poppins(
            color: const Color(0xFF334E7B),
            fontWeight: FontWeight.w700,
            fontSize: isTablet ? 24 : 22,
            letterSpacing: 0.2,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF334E7B),
        elevation: 0,
        surfaceTintColor: Colors.white,
        shadowColor: Colors.transparent,
      ),
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.all(horizontalPadding),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: isTablet ? 600 : double.infinity,
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                    _resetPagination(); // Reset to first page when searching
                  });
                },
                style: GoogleFonts.robotoMono(
                  fontSize: isTablet ? 16 : 14,
                ),
                decoration: InputDecoration(
                  hintText: 'Search FAQs...',
                  hintStyle: GoogleFonts.robotoMono(
                    color: Colors.grey[600],
                    fontSize: isTablet ? 16 : 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: const Color(0xFF334E7B),
                    size: isTablet ? 24 : 20,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: Colors.grey[600],
                            size: isTablet ? 24 : 20,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                              _resetPagination(); // Reset pagination when clearing search
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: const Color(0xFF334E7B).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: const Color(0xFF334E7B).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF4C75F2),
                      width: 2,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: isTablet ? 16 : 12,
                  ),
                ),
              ),
            ),
          ),
          
          // Results count and FAQ list
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Results count and pagination info
                  if (filteredFAQs.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _searchQuery.isNotEmpty 
                              ? '${filteredFAQs.length} result${filteredFAQs.length != 1 ? 's' : ''} found'
                              : 'Showing ${paginatedFAQs.length} of ${filteredFAQs.length} FAQs',
                            style: GoogleFonts.robotoMono(
                              fontSize: isTablet ? 14 : 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (totalPages > 1)
                            Text(
                              'Page ${_currentPage + 1} of $totalPages',
                              style: GoogleFonts.robotoMono(
                                fontSize: isTablet ? 14 : 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ),
                  
                  // FAQ Cards
                  if (paginatedFAQs.isNotEmpty)
                    ...paginatedFAQs.map((faq) => Container(
                      constraints: BoxConstraints(
                        maxWidth: isTablet ? 800 : double.infinity,
                      ),
                      child: FAQCard(
                        question: faq['question']!,
                        answer: faq['answer']!,
                        isTablet: isTablet,
                        searchQuery: _searchQuery,
                      ),
                    )).toList()
                  else if (_searchQuery.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.search_off,
                            size: isTablet ? 64 : 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No results found',
                            style: GoogleFonts.poppins(
                              fontSize: isTablet ? 20 : 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try searching with different keywords',
                            style: GoogleFonts.robotoMono(
                              fontSize: isTablet ? 14 : 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Pagination Controls
                  if (totalPages > 1 && paginatedFAQs.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Previous button
                          IconButton(
                            onPressed: _currentPage > 0 ? () => _goToPage(_currentPage - 1) : null,
                            icon: Icon(
                              Icons.chevron_left,
                              color: _currentPage > 0 ? const Color(0xFF334E7B) : Colors.grey[400],
                              size: isTablet ? 28 : 24,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: _currentPage > 0 
                                  ? Colors.white 
                                  : Colors.grey[100],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: _currentPage > 0 
                                      ? const Color(0xFF334E7B).withOpacity(0.2)
                                      : Colors.grey[300]!,
                                ),
                              ),
                              padding: EdgeInsets.all(isTablet ? 12 : 8),
                            ),
                          ),
                          
                          const SizedBox(width: 16),
                          
                          // Page numbers
                          ...List.generate(totalPages, (index) {
                            final isCurrentPage = index == _currentPage;
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: GestureDetector(
                                onTap: () => _goToPage(index),
                                child: Container(
                                  width: isTablet ? 40 : 32,
                                  height: isTablet ? 40 : 32,
                                  decoration: BoxDecoration(
                                    color: isCurrentPage 
                                        ? const Color(0xFF334E7B) 
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isCurrentPage 
                                          ? const Color(0xFF334E7B)
                                          : const Color(0xFF334E7B).withOpacity(0.2),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: GoogleFonts.robotoMono(
                                        fontSize: isTablet ? 14 : 12,
                                        fontWeight: FontWeight.w600,
                                        color: isCurrentPage 
                                            ? Colors.white 
                                            : const Color(0xFF334E7B),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).take(5), // Limit to 5 page numbers for mobile
                          
                          const SizedBox(width: 16),
                          
                          // Next button
                          IconButton(
                            onPressed: _currentPage < totalPages - 1 ? () => _goToPage(_currentPage + 1) : null,
                            icon: Icon(
                              Icons.chevron_right,
                              color: _currentPage < totalPages - 1 ? const Color(0xFF334E7B) : Colors.grey[400],
                              size: isTablet ? 28 : 24,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: _currentPage < totalPages - 1 
                                  ? Colors.white 
                                  : Colors.grey[100],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: _currentPage < totalPages - 1 
                                      ? const Color(0xFF334E7B).withOpacity(0.2)
                                      : Colors.grey[300]!,
                                ),
                              ),
                              padding: EdgeInsets.all(isTablet ? 12 : 8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FAQCard extends StatefulWidget {
  final String question;
  final String answer;
  final bool isTablet;
  final String searchQuery;

  const FAQCard({
    Key? key,
    required this.question,
    required this.answer,
    this.isTablet = false,
    this.searchQuery = '',
  }) : super(key: key);

  @override
  _FAQCardState createState() => _FAQCardState();
}

class _FAQCardState extends State<FAQCard> with SingleTickerProviderStateMixin {
  bool isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      isExpanded = !isExpanded;
      if (isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  Widget _buildHighlightedText(String text, String searchQuery, TextStyle style) {
    if (searchQuery.isEmpty) {
      return Text(text, style: style);
    }

    final spans = <TextSpan>[];
    final lowerText = text.toLowerCase();
    final lowerQuery = searchQuery.toLowerCase();
    int start = 0;

    while (start < text.length) {
      final index = lowerText.indexOf(lowerQuery, start);
      if (index == -1) {
        spans.add(TextSpan(text: text.substring(start), style: style));
        break;
      }

      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index), style: style));
      }

      spans.add(TextSpan(
        text: text.substring(index, index + searchQuery.length),
        style: style.copyWith(
          backgroundColor: const Color(0xFF4C75F2).withOpacity(0.3),
          fontWeight: FontWeight.bold,
        ),
      ));

      start = index + searchQuery.length;
    }

    return RichText(text: TextSpan(children: spans));
  }

  @override
  Widget build(BuildContext context) {
    final cardPadding = widget.isTablet ? 20.0 : 16.0;
    final questionFontSize = widget.isTablet ? 18.0 : 16.0;
    final answerFontSize = widget.isTablet ? 16.0 : 14.0;
    
    return Container(
      margin: EdgeInsets.only(bottom: widget.isTablet ? 16.0 : 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(widget.isTablet ? 16 : 12),
        border: Border.all(
          color: isExpanded ? const Color(0xFF4C75F2) : const Color(0xFF334E7B).withOpacity(0.2),
          width: isExpanded ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isExpanded ? const Color(0xFF4C75F2) : const Color(0xFF334E7B)).withOpacity(0.08),
            blurRadius: isExpanded ? (widget.isTablet ? 12 : 8) : (widget.isTablet ? 6 : 4),
            offset: Offset(0, widget.isTablet ? 3 : 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: _toggleExpansion,
            borderRadius: BorderRadius.circular(widget.isTablet ? 16 : 12),
            child: Container(
              padding: EdgeInsets.all(cardPadding),
              child: Row(
                children: [
                  Container(
                    width: widget.isTablet ? 8 : 6,
                    height: widget.isTablet ? 32 : 24,
                    decoration: BoxDecoration(
                      color: isExpanded ? const Color(0xFF4C75F2) : const Color(0xFF334E7B),
                      borderRadius: BorderRadius.circular(widget.isTablet ? 4 : 3),
                    ),
                  ),
                  SizedBox(width: widget.isTablet ? 16 : 12),
                  Expanded(
                    child: _buildHighlightedText(
                      widget.question,
                      widget.searchQuery,
                      GoogleFonts.poppins(
                        fontSize: questionFontSize,
                        fontWeight: FontWeight.w600,
                        color: isExpanded ? const Color(0xFF4C75F2) : const Color(0xFF334E7B),
                        height: 1.3,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: isExpanded ? const Color(0xFF4C75F2) : const Color(0xFF334E7B),
                      size: widget.isTablet ? 28 : 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                cardPadding + (widget.isTablet ? 24 : 18), 
                0, 
                cardPadding, 
                cardPadding
              ),
              child: Container(
                padding: EdgeInsets.all(cardPadding),
                decoration: BoxDecoration(
                  color: Colors.indigo[25],
                  borderRadius: BorderRadius.circular(widget.isTablet ? 12 : 8),
                  border: Border.all(
                    color: const Color(0xFF334E7B).withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: _buildHighlightedText(
                  widget.answer,
                  widget.searchQuery,
                  GoogleFonts.robotoMono(
                    fontSize: answerFontSize,
                    color: Colors.blueGrey[700],
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
