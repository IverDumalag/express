import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../00_services/api_services.dart';
import '../global_variables.dart';

class ArchivedCardsPage extends StatefulWidget {
  const ArchivedCardsPage({Key? key}) : super(key: key);

  @override
  State<ArchivedCardsPage> createState() => _ArchivedCardsPageState();
}

class _ArchivedCardsPageState extends State<ArchivedCardsPage> {
  Future<void> _restoreCard(String entryId) async {
    setState(() => _loading = true);
    final result = await ApiService.restoreCard(entryId: entryId);
    if (result['status'] == 200 || result['status'] == "200") {
      setState(() {
        _archivedCards.removeWhere((c) => c['entry_id'] == entryId);
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Card restored!')),
      );
    } else {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Restore failed')),
      );
    }
  }
  List<Map<String, dynamic>> _archivedCards = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchArchivedCards();
  }

  Future<void> _fetchArchivedCards() async {
    setState(() => _loading = true);
    final userId = UserSession.user?['user_id']?.toString() ?? "";
    final allCards = await ApiService.fetchCards(userId);
    setState(() {
      _archivedCards = allCards
          .where((c) => c['status'] == 'archived')
          .toList();
      _loading = false;
    });
  }

  Future<void> _deleteCard(String entryId) async {
    setState(() => _loading = true);
    final result = await ApiService.deleteCard(entryId: entryId);
    if (result['status'] == 200 || result['status'] == "200") {
      setState(() {
        _archivedCards.removeWhere((c) => c['entry_id'] == entryId);
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Deleted successfully!',
            style: GoogleFonts.robotoMono(),
          ),
        ),
      );
    } else {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message'] ?? 'Delete failed',
            style: GoogleFonts.robotoMono(),
          ),
        ),
      );
    }
  }

  double _scaleFactor(BuildContext context) {
    final baseWidth = 375.0;
    return MediaQuery.of(context).size.width / baseWidth;
  }

  @override
  Widget build(BuildContext context) {
    final scale = _scaleFactor(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(

        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shadowColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Back',
              style: GoogleFonts.robotoMono(
                color: Color(0xFF334E7B),
                fontWeight: FontWeight.bold,
              ),
            ),

          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF334E7B)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: false,
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _archivedCards.isEmpty
          ? Center(
              child: Text(
                'No archived cards.',
                style: GoogleFonts.robotoMono(
                  color: Colors.blueGrey,
                  fontSize: 20 * scale,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(24, 24, 24, 8),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Archived',
                        style: TextStyle(
                          color: Color(0xFF334E7B),
                          fontWeight: FontWeight.bold,
                          fontSize: 36,
                          fontFamily: 'RobotoMono',
                        ),
                      ),
                      
                    ],

                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(16 * scale),
                    itemCount: _archivedCards.length,
                    itemBuilder: (context, index) {
                      final card = _archivedCards[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 16 * scale),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Color(0xFF334E7B),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF2354C7).withOpacity(0.08),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20 * scale,
                            vertical: 12 * scale,
                          ),
                          title: Text(
                            card['words'] ?? '',
                            style: GoogleFonts.robotoMono(
                              fontSize: 22 * scale,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2354C7),
                            ),
                          ),

                          
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.restore,
                                  color: Color(0xFF334E7B),
                                  size: 28 * scale,
                                ),
                                tooltip: 'Restore',
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15.0),
                                        side: BorderSide(
                                          color: Color(0xFF334E7B),
                                          width: 2,
                                        ),
                                      ),
                                      backgroundColor: Colors.white,
                                      elevation: 8,
                                      title: Text(
                                        'Restore Card',
                                        style: TextStyle(
                                          color: Color(0xFF334E7B),
                                          fontFamily: 'RobotoMono',
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15,
                                        ),
                                      ),
                                      content: Text(
                                        'Do you want to use this card again?',
                                        style: TextStyle(
                                          color: Color(0xFF334E7B),
                                          fontFamily: 'RobotoMono',
                                          fontWeight: FontWeight.w500,

                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx, false),
                                          child: Text('Cancel', style: TextStyle(color: Colors.grey[600], fontFamily: 'RobotoMono', fontWeight: FontWeight.w500)),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx, true),
                                          child: Text('Restore', style: TextStyle(color: Color(0xFF334E7B), fontFamily: 'RobotoMono', fontWeight: FontWeight.w500)),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    await _restoreCard(card['entry_id'].toString());
                                  }
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  color: Colors.red[700],
                                  size: 28 * scale,
                                ),
                                tooltip: 'Delete',
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15.0),
                                        side: BorderSide(
                                          color: Color(0xFF334E7B),
                                          width: 2,
                                        ),
                                      ),
                                      backgroundColor: Colors.white,
                                      elevation: 8,
                                      title: Text(
                                        'Delete Card',
                                        style: TextStyle(
                                          color: Color(0xFF334E7B),
                                          fontFamily: 'RobotoMono',
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15,
                                        ),
                                      ),
                                      content: Text(
                                        'Are you sure you want to permanently delete this card?',
                                        style: TextStyle(
                                          color: Color(0xFF334E7B),
                                          fontFamily: 'RobotoMono',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx, false),
                                          child: Text('Cancel', style: TextStyle(color: Colors.grey[600], fontFamily: 'RobotoMono', fontWeight: FontWeight.w500)),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx, true),
                                          child: Text('Delete', style: TextStyle(color: Colors.red, fontFamily: 'RobotoMono', fontWeight: FontWeight.w500)),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    await _deleteCard(card['entry_id'].toString());
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
