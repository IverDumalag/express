import 'package:flutter/material.dart';
import '../00_services/api_services.dart';
import '../global_variables.dart';

class ArchivedCardsPage extends StatefulWidget {
  const ArchivedCardsPage({Key? key}) : super(key: key);

  @override
  State<ArchivedCardsPage> createState() => _ArchivedCardsPageState();
}

class _ArchivedCardsPageState extends State<ArchivedCardsPage> {
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Deleted successfully!')));
    } else {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Delete failed')),
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
      appBar: AppBar(

        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Back',
              style: TextStyle(
                color: Color(0xFF334E7B),
                fontWeight: FontWeight.bold,
                fontFamily: 'RobotoMono',
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF334E7B)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: false, 
      ),
      backgroundColor: Colors.white,
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _archivedCards.isEmpty
          ? Center(
              child: Text(
                'No archived cards.',
                style: TextStyle(
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
                  child: Text(
                    'Archived',
                    style: TextStyle(
                      color: Color(0xFF334E7B),
                      fontWeight: FontWeight.bold,
                      fontSize: 36,
                      fontFamily: 'RobotoMono',
                    ),
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
                          border: Border.all(color: Color(0xFF334E7B), width: 1.5),
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
                            style: TextStyle(
                              fontSize: 22 * scale,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2354C7),
                            ),
                          ),
                          
                          trailing: IconButton(
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
                                  title: Text('Delete Card'),
                                  content: Text(
                                    'Are you sure you want to permanently delete this card?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, false),
                                      child: Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await _deleteCard(card['entry_id'].toString());
                              }
                            },
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
