import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'global_variables.dart';
import '5_profile/page_profile.dart';
import '4_settings/page_settings.dart';
import '4_settings/archived_cards.dart';
import '4_settings/feedbackpage.dart';
import '4_settings/help_page.dart';
import '4_settings/about_page.dart';

class MorePage extends StatelessWidget {
  final List<_MoreItem> items = const [
    _MoreItem(icon: Icons.person_4, label: 'Profile'),
    _MoreItem(icon: Icons.info_outline, label: 'About'),
    _MoreItem(icon: Icons.archive, label: 'Archive'),
    _MoreItem(icon: Icons.feedback_outlined, label: 'Feedback'),
    _MoreItem(icon: Icons.help_rounded, label: 'Help'),
    _MoreItem(icon: Icons.logout, label: 'Logout'),
  ];

  static Future<void> _performLogout(BuildContext context) async {
    try {
      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedIn');
      await prefs.remove('userData');

      // Clear user session
      UserSession.clear();

      // Reset global variables
      GlobalVariables.currentIndex = 0;

      // Navigate to login page and clear navigation stack
      if (context.mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);

        // Show success message after navigation
        Future.delayed(Duration(milliseconds: 500), () {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'You have been logged out successfully',
                  style: GoogleFonts.robotoMono(),
                ),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        });
      }
    } catch (e) {
      // Show error message if logout fails
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Logout failed. Please try again.',
              style: GoogleFonts.robotoMono(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

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
              padding: const EdgeInsets.only(
                left: 29.0,
                top: 8.0,
                right: 0,
                bottom: 8.0,
              ),
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
        padding: const EdgeInsets.only(
          left: 29.0,
          right: 29.0,
          top: 8.0,
          bottom: 8.0,
        ),
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
                      MaterialPageRoute(
                        builder: (context) => ArchivedCardsPage(),
                      ),
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
                    Navigator.of(
                      context,
                    ).push(MaterialPageRoute(builder: (context) => HelpPage()));
                    break;
                  case 'Logout':
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
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
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Log Out',
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
                                  'Are you sure you want to log out?',
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
                                      onPressed: () => Navigator.pop(context),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Color(0xFF334E7B),
                                        side: BorderSide(
                                          color: Color(0xFF334E7B),
                                          width: 1.5,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
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
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        await _performLogout(context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFF334E7B),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 30,
                                          vertical: 12,
                                        ),
                                      ),
                                      child: Text(
                                        'Logout',
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
                    break;
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF334E7B),
                    width: 1.1,
                  ),
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
