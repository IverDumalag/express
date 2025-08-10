import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../00_services/api_services.dart';
import '../global_variables.dart';

class PageProfile extends StatefulWidget {
  const PageProfile({Key? key}) : super(key: key);

  @override
  State<PageProfile> createState() => _PageProfileState();
}

class _PageProfileState extends State<PageProfile> {
  Map<String, dynamic>? user;
  bool _showEmail = true;

  @override
  void initState() {
    super.initState();
    user = UserSession.user;
  }

  @override
  Widget build(BuildContext context) {
    final themeBlue = const Color(0xFF334E7B);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 50, 51, 53).withOpacity(0.08),
      body: user == null
          ? Center(child: Text("No user data", style: GoogleFonts.robotoMono()))
          : Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.08,
                  vertical: screenHeight * 0.04,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 32),
                    Text(
                      "My Profile",
                      style: GoogleFonts.robotoMono(
                        fontSize: 29,
                        fontWeight: FontWeight.w700,
                        color: themeBlue,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Full Name:",
                          style: GoogleFonts.robotoMono(
                            fontSize: 16,
                            color: themeBlue,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                          color: Color(0xFF334E7B), // Blue outline
                          width: 2,                
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                "${user!['f_name'] ?? ''} ${user!['m_name'] ?? ''} ${user!['l_name'] ?? ''}",
                                style: GoogleFonts.robotoMono(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.bold,
                                  color: themeBlue,
                                  letterSpacing: 0.5,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.check_circle,
                              color: themeBlue,
                              size: screenWidth * 0.05,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.015),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2.0, left: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Account Created",
                            style: GoogleFonts.robotoMono(
                              fontSize: 16,
                              color: themeBlue,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: themeBlue.withOpacity(0.4),
                            width: 1.2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          user!['created_at'] != null
                              ? _formatDate(user!['created_at'])
                              : 'Unknown registration date',
                          style: GoogleFonts.robotoMono(
                            fontSize: screenWidth * 0.04,
                            color: Colors.blueGrey[700],
                            letterSpacing: 0.2,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    Card(
                      color: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.06,
                          vertical: screenHeight * 0.025,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                  
                            Row(
                              children: [
                                Expanded(
                                  child: _profileItem(
                                    icon: Icons.email,
                                    label: "Email",
                                    value: _showEmail ? (user!['email'] ?? '') : "************",
                                    themeBlue: themeBlue,
                                    screenWidth: screenWidth,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(_showEmail ? Icons.visibility_off : Icons.visibility, color: themeBlue),
                                  tooltip: _showEmail ? "Hide Email" : "Show Email",
                                  onPressed: () {
                                    setState(() {
                                      _showEmail = !_showEmail;
                                    });
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Divider(),
                            SizedBox(height: 8),
                            _profileItem(
                              icon: Icons.cake,
                              label: "Birthdate",
                              value: user!['birthdate'] != null && user!['birthdate'] != ''
                                  ? _formatDate(user!['birthdate'])
                                  : '',
                              themeBlue: themeBlue,
                              screenWidth: screenWidth,
                            ),
                            SizedBox(height: 8),
                            Divider(),
                            SizedBox(height: 8),
                            _profileItem(
                              icon: Icons.wc,
                              label: "Sex",
                              value: user!['sex'] ?? '',
                              themeBlue: themeBlue,
                              screenWidth: screenWidth,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 2),
                       
                        decoration: BoxDecoration(
                            color: themeBlue,
                          border: Border.all(
                            color: themeBlue.withOpacity(0.4),
                            width: 1.2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeBlue, // 🔹 Set background color
                            foregroundColor: Colors.white, // 🔹 Icon/text color
                            minimumSize: const Size(double.infinity, 70),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.edit, color: Colors.white), // White icon
                          label: Text(
                            "Edit Profile",
                            style: GoogleFonts.robotoMono(
                              fontSize: screenWidth * 0.045,
                              color: Colors.white, // White text
                            ),
                          ),
                          onPressed: () async {
                            final updated = await showDialog<Map<String, dynamic>>(
                              context: context,
                              builder: (context) => EditProfileDialog(user: user!),
                            );
                            if (updated != null) {
                              setState(() {
                                user = updated;
                                UserSession.setUser(updated);
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _profileItem({
    required IconData icon,
    required String label,
    required String value,
    required Color themeBlue,
    required double screenWidth,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: themeBlue, size: screenWidth * 0.06),
          SizedBox(width: screenWidth * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.robotoMono(
                    fontSize: screenWidth * 0.045,
                    color: Colors.blueGrey[800],
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.robotoMono(
                    fontSize: screenWidth * 0.045,
                    color: themeBlue,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return "${_monthName(date.month)} ${date.day}, ${date.year}";
    } catch (e) {
      return dateStr;
    }
  }

  String _monthName(int month) {
    const months = [
      "January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December"
    ];
    return months[month - 1];
  }
}

class EditProfileDialog extends StatefulWidget {
  final Map<String, dynamic> user;
  const EditProfileDialog({Key? key, required this.user}) : super(key: key);

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late TextEditingController fNameController;
  late TextEditingController mNameController;
  late TextEditingController lNameController;
  late TextEditingController birthdateController;
  late TextEditingController sexController;

  bool loading = false;
  final List<String> sexOptions = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    fNameController = TextEditingController(text: widget.user['f_name'] ?? '');
    mNameController = TextEditingController(text: widget.user['m_name'] ?? '');
    lNameController = TextEditingController(text: widget.user['l_name'] ?? '');
    birthdateController = TextEditingController(
      text: widget.user['birthdate'] ?? '',
    );
    sexController = TextEditingController(text: widget.user['sex'] ?? '');
  }

  @override
  void dispose() {
    fNameController.dispose();
    mNameController.dispose();
    lNameController.dispose();
    birthdateController.dispose();
    sexController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthdate() async {
    DateTime? initialDate;
    try {
      initialDate = DateTime.parse(birthdateController.text);
    } catch (_) {
      initialDate = DateTime(2000, 1, 1);
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      birthdateController.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeBlue = const Color(0xFF334E7B);
    final screenWidth = MediaQuery.of(context).size.width;

    return AlertDialog(
      backgroundColor: const Color(0xFF334E7B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      title: Row(
        children: [
          Icon(Icons.edit, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            "Edit Profile",
            style: GoogleFonts.robotoMono(color: Colors.white),
          ),
        ],
      ),
      content: SizedBox(
        width: screenWidth > 420 ? 400 : screenWidth * 0.95,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: fNameController,
                style: GoogleFonts.robotoMono(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "First Name",
                  labelStyle: GoogleFonts.robotoMono(color: Colors.white70),
                  prefixIcon: Icon(Icons.account_circle, color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: mNameController,
                style: GoogleFonts.robotoMono(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Middle Name",
                  labelStyle: GoogleFonts.robotoMono(color: Colors.white70),
                  prefixIcon: Icon(Icons.account_circle, color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: lNameController,
                style: GoogleFonts.robotoMono(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Last Name",
                  labelStyle: GoogleFonts.robotoMono(color: Colors.white70),
                  prefixIcon: Icon(Icons.account_circle, color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: _pickBirthdate,
                child: AbsorbPointer(
                  child: TextField(
                    controller: birthdateController,
                    style: GoogleFonts.robotoMono(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Birthdate",
                      labelStyle: GoogleFonts.robotoMono(color: Colors.white70),
                      prefixIcon: Icon(Icons.cake, color: Colors.white70),
                      suffixIcon: Icon(
                        Icons.calendar_today,
                        color: Colors.white70,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: sexOptions.contains(sexController.text)
                    ? sexController.text
                    : null,
                items: sexOptions
                    .map(
                      (sex) => DropdownMenuItem(
                        value: sex,
                        child: Text(
                          sex,
                          style: GoogleFonts.robotoMono(color: Colors.white),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  sexController.text = val ?? '';
                  setState(() {});
                },
                dropdownColor: const Color(0xFF334E7B),
                style: GoogleFonts.robotoMono(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Sex",
                  labelStyle: GoogleFonts.robotoMono(color: Colors.white70),
                  prefixIcon: Icon(Icons.wc, color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      actions: [
        TextButton(
          onPressed: loading ? null : () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            textStyle: GoogleFonts.robotoMono(fontWeight: FontWeight.bold),
          ),
          child: Text("Cancel", style: GoogleFonts.robotoMono()),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: themeBlue,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: loading
              ? null
              : () async {
                  setState(() => loading = true);
                  final updatedUser = {
                    ...widget.user,
                    'f_name': fNameController.text.trim(),
                    'm_name': mNameController.text.trim(),
                    'l_name': lNameController.text.trim(),
                    'birthdate': birthdateController.text.trim(),
                    'sex': sexController.text.trim(),
                  };
                  final result = await ApiService.editUser(
                    userId: widget.user['user_id'].toString(),
                    email: widget.user['email'] ?? '',
                    fName: fNameController.text.trim(),
                    mName: mNameController.text.trim(),
                    lName: lNameController.text.trim(),
                    sex: sexController.text.trim(),
                    birthdate: birthdateController.text.trim(),
                  );
                  setState(() => loading = false);
                  if (result['status'] == 200 || result['status'] == "200") {
                    Navigator.pop(context, {
                      ...widget.user,
                      'f_name': fNameController.text.trim(),
                      'm_name': mNameController.text.trim(),
                      'l_name': lNameController.text.trim(),
                      'birthdate': birthdateController.text.trim(),
                      'sex': sexController.text.trim(),
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          result['message'] ?? "Update failed",
                          style: GoogleFonts.robotoMono(),
                        ),
                      ),
                    );
                  }
                },
          child: loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF334E7B),
                  ),
                )
              : Text("Save", style: GoogleFonts.robotoMono()),
        ),
      ],
    );
  }
}
