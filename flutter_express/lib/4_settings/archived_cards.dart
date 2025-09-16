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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Card restored!')));
    } else {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Restore failed')),
      );
    }
  }

  List<Map<String, dynamic>> _archivedCards = [];
  bool _loading = true;
  Set<String> _selectedCards = {};
  bool _selectMode = false;

  void _toggleSelectAll() {
    setState(() {
      _selectMode = !_selectMode;
      if (_selectMode) {
        _selectedCards = _archivedCards
            .map((c) => c['entry_id'].toString())
            .toSet();
      } else {
        _selectedCards.clear();
      }
    });
  }

  Future<void> _deleteSelectedCards() async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Color(0xFF334E7B), width: 2.0),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 350, maxHeight: 220),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Delete Selected Cards',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Color(0xFF334E7B),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Divider(height: 1, color: Color(0xFF334E7B)),
                const SizedBox(height: 16),
                Text(
                  'Are you sure you want to delete the selected cards?',
                  style: GoogleFonts.robotoMono(
                    fontSize: 15,
                    color: Color(0xFF334E7B),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Color(0xFF334E7B),
                        side: BorderSide(color: Color(0xFF334E7B), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.robotoMono(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF334E7B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        'Delete',
                        style: GoogleFonts.robotoMono(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (confirm == true) {
      final toDelete = _selectedCards.toList();
      setState(() => _loading = true);
      for (final entryId in toDelete) {
        await ApiService.deleteCard(entryId: entryId);
        _archivedCards.removeWhere((c) => c['entry_id'].toString() == entryId);
      }
      setState(() {
        _selectedCards.clear();
        _selectMode = false;
        _loading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Selected cards deleted!')));
    }
  }

  Future<void> _restoreSelectedCards() async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Color(0xFF334E7B), width: 2.0),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 350, maxHeight: 220),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Restore Selected Cards',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Color(0xFF334E7B),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Divider(height: 1, color: Color(0xFF334E7B)),
                const SizedBox(height: 16),
                Text(
                  'Are you sure you want to restore the selected cards?',
                  style: GoogleFonts.robotoMono(
                    fontSize: 15,
                    color: Color(0xFF334E7B),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Color(0xFF334E7B),
                        side: BorderSide(color: Color(0xFF334E7B), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.robotoMono(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF334E7B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        'Restore',
                        style: GoogleFonts.robotoMono(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (confirm == true) {
      final toRestore = _selectedCards.toList();
      setState(() => _loading = true);
      for (final entryId in toRestore) {
        await ApiService.restoreCard(entryId: entryId);
        _archivedCards.removeWhere((c) => c['entry_id'].toString() == entryId);
      }
      setState(() {
        _selectedCards.clear();
        _selectMode = false;
        _loading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Selected cards restored!')));
    }
  }

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
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left,
            color: Color(0xFF334E7B),
            size: 32,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Archived Cards',
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
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _archivedCards.isEmpty
          ? Center(
              child: Text(
                'No archived cards yet',
                style: GoogleFonts.robotoMono(
                  color: Color(0xFF334E7B),
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
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (_selectMode) ...[
                        Text(
                          _selectedCards.length == _archivedCards.length
                              ? 'All selected'
                              : '${_selectedCards.length} selected',
                          style: GoogleFonts.robotoMono(
                            fontSize: 14,
                            color: Color(0xFF334E7B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ] else ...[
                        Text(
                          'Select All Cards',
                          style: GoogleFonts.robotoMono(
                            fontSize: 14,
                            color: Color(0xFF334E7B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      IconButton(
                        icon: Icon(
                          _selectMode
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color: Color(0xFF334E7B),
                        ),
                        tooltip: _selectMode ? 'Deselect All' : 'Select All',
                        onPressed: _archivedCards.isEmpty
                            ? null
                            : _toggleSelectAll,
                      ),
                      if (_selectMode) ...[
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red[700]),
                          tooltip: 'Delete Selected Cards',
                          onPressed: _selectedCards.isEmpty
                              ? null
                              : _deleteSelectedCards,
                        ),
                        IconButton(
                          icon: Icon(Icons.restore, color: Color(0xFF334E7B)),
                          tooltip: 'Restore Selected Cards',
                          onPressed: _selectedCards.isEmpty
                              ? null
                              : _restoreSelectedCards,
                        ),
                      ],
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(16 * scale),
                    itemCount: _archivedCards.length,
                    itemBuilder: (context, index) {
                      final card = _archivedCards[index];
                      final entryId = card['entry_id'].toString();
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
                          leading: _selectMode
                              ? Checkbox(
                                  value: _selectedCards.contains(entryId),
                                  onChanged: (checked) {
                                    setState(() {
                                      if (checked == true) {
                                        _selectedCards.add(entryId);
                                      } else {
                                        _selectedCards.remove(entryId);
                                      }
                                    });
                                  },
                                  activeColor: Color(0xFF334E7B),
                                )
                              : null,
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
                          trailing: LayoutBuilder(
                            builder: (context, constraints) {
                              double buttonSize =
                                  (constraints.maxWidth / 2).clamp(36.0, 48.0) *
                                  scale;
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: buttonSize,
                                    height: buttonSize,
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.restore,
                                        color: Color(0xFF334E7B),
                                        size: 24 * scale,
                                      ),
                                      tooltip: 'Restore',
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (ctx) => Dialog(
                                            backgroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              side: BorderSide(
                                                color: Color(0xFF334E7B),
                                                width: 2.0,
                                              ),
                                            ),
                                            child: ConstrainedBox(
                                              constraints: BoxConstraints(
                                                maxWidth: 350,
                                                maxHeight: 220,
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  16.0,
                                                ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      'Restore Card',
                                                      style: TextStyle(
                                                        fontFamily: 'Poppins',
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Color(
                                                          0xFF334E7B,
                                                        ),
                                                        fontSize: 22,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                    const SizedBox(height: 12),
                                                    Divider(
                                                      height: 1,
                                                      color: Color(0xFF334E7B),
                                                    ),
                                                    const SizedBox(height: 16),
                                                    Text(
                                                      'Do you want to use this card again?',
                                                      style: TextStyle(
                                                        fontFamily:
                                                            'RobotoMono',
                                                        color: Color(
                                                          0xFF334E7B,
                                                        ),
                                                        fontSize: 15,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                    const SizedBox(height: 24),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        OutlinedButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                ctx,
                                                                false,
                                                              ),
                                                          style: OutlinedButton.styleFrom(
                                                            foregroundColor:
                                                                Color(
                                                                  0xFF334E7B,
                                                                ),
                                                            side: BorderSide(
                                                              color: Color(
                                                                0xFF334E7B,
                                                              ),
                                                              width: 1.5,
                                                            ),
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    8,
                                                                  ),
                                                            ),
                                                            padding:
                                                                EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      30,
                                                                  vertical: 12,
                                                                ),
                                                          ),
                                                          child: Text(
                                                            'Cancel',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'RobotoMono',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 16,
                                                        ),
                                                        ElevatedButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                ctx,
                                                                true,
                                                              ),
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                Color(
                                                                  0xFF334E7B,
                                                                ),
                                                            foregroundColor:
                                                                Colors.white,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    8,
                                                                  ),
                                                            ),
                                                            padding:
                                                                EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      30,
                                                                  vertical: 12,
                                                                ),
                                                          ),
                                                          child: Text(
                                                            'Restore',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'RobotoMono',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                        if (confirm == true) {
                                          await _restoreCard(
                                            card['entry_id'].toString(),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 8 * scale),
                                  SizedBox(
                                    width: buttonSize,
                                    height: buttonSize,
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red[700],
                                        size: 24 * scale,
                                      ),
                                      tooltip: 'Delete',
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (ctx) => Dialog(
                                            backgroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              side: BorderSide(
                                                color: Color(0xFF334E7B),
                                                width: 2.0,
                                              ),
                                            ),
                                            child: ConstrainedBox(
                                              constraints: BoxConstraints(
                                                maxWidth: 350,
                                                maxHeight: 220,
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  16.0,
                                                ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      'Delete Card',
                                                      style: TextStyle(
                                                        fontFamily: 'Poppins',
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Color(
                                                          0xFF334E7B,
                                                        ),
                                                        fontSize: 22,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                    const SizedBox(height: 12),
                                                    Divider(
                                                      height: 1,
                                                      color: Color(0xFF334E7B),
                                                    ),
                                                    const SizedBox(height: 16),
                                                    Text(
                                                      'Are you sure you want to permanently delete this card?',
                                                      style: TextStyle(
                                                        fontFamily:
                                                            'RobotoMono',
                                                        color: Color(
                                                          0xFF334E7B,
                                                        ),
                                                        fontSize: 15,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                    const SizedBox(height: 24),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        OutlinedButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                ctx,
                                                                false,
                                                              ),
                                                          style: OutlinedButton.styleFrom(
                                                            foregroundColor:
                                                                Color(
                                                                  0xFF334E7B,
                                                                ),
                                                            side: BorderSide(
                                                              color: Color(
                                                                0xFF334E7B,
                                                              ),
                                                              width: 1.5,
                                                            ),
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    8,
                                                                  ),
                                                            ),
                                                            padding:
                                                                EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      30,
                                                                  vertical: 12,
                                                                ),
                                                          ),
                                                          child: Text(
                                                            'Cancel',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'RobotoMono',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 16,
                                                        ),
                                                        ElevatedButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                ctx,
                                                                true,
                                                              ),
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                Color(
                                                                  0xFF334E7B,
                                                                ),
                                                            foregroundColor:
                                                                Colors.white,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    8,
                                                                  ),
                                                            ),
                                                            padding:
                                                                EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      30,
                                                                  vertical: 12,
                                                                ),
                                                          ),
                                                          child: Text(
                                                            'Delete',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'RobotoMono',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                        if (confirm == true) {
                                          await _deleteCard(
                                            card['entry_id'].toString(),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              );
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
