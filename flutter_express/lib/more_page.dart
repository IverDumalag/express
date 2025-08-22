import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '5_profile/page_profile.dart';
import '4_settings/page_settings.dart';
import '4_settings/archived_cards.dart';
import '4_settings/feedbackpage.dart';
import '4_settings/help_page.dart';
import '4_settings/about_page.dart';

class MorePage extends StatelessWidget {
  final List<_MoreItem> items = const [
    _MoreItem(icon: Icons.person, label: 'Profile'),
    _MoreItem(icon: Icons.info, label: 'About'),
    _MoreItem(icon: Icons.archive, label: 'Archive'),
    _MoreItem(icon: Icons.feedback_outlined, label: 'Feedback'),
    _MoreItem(icon: Icons.help_outline, label: 'Help'),
    _MoreItem(icon: Icons.logout, label: 'Logout'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(110),
        child: Container(
          color: Colors.white,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 29.0, top: 8.0, right: 0, bottom: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 18),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Menu',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF334E7B),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.only(left: 29.0, right: 29.0, top: 8.0, bottom: 8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return GestureDetector(
              onTap: () {
                switch (item.label) {
                  case 'Profile':
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => PageProfile()),
                    );
                    break;
                  // Settings removed
                  case 'Archive':
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => ArchivedCardsPage()),
                    );
                    break;
                  case 'Feedback':
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => FeedbackPage()),
                    );
                    break;
                  case 'About':
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => AboutPage()),
                    );
                    break;
                  case 'Help':
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => HelpPage()),
                    );
                    break;
                  case 'Logout':
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(color: Color(0xFF334E7B)),
                        ),
                        title: Text('Logout', style: GoogleFonts.robotoMono(fontWeight: FontWeight.bold)),
                        content: Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Cancel', style: GoogleFonts.robotoMono()),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.of(context).pushReplacementNamed('/login');
                            },
                            child: Text('Logout', style: GoogleFonts.robotoMono(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                    break;
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF334E7B), width: 1.1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item.icon, size: 45, color: const Color(0xFF334E7B)),
                    const SizedBox(height: 16),
                    Text(
                      item.label,
                      style: GoogleFonts.robotoMono(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF334E7B),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MoreItem {
  final IconData icon;
  final String label;
  const _MoreItem({required this.icon, required this.label});
}
