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
                        letterSpacing: 0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Full Name",
                        style: GoogleFonts.robotoMono(
                          fontSize: 16,
                          color: themeBlue,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
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
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Account Created",
                        style: GoogleFonts.robotoMono(
                          fontSize: 16,
                          color: themeBlue,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                        textAlign: TextAlign.left,
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
                    SizedBox(height: screenHeight * 0.02),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Profile Details",
                        style: GoogleFonts.robotoMono(
                          fontSize: 16,
                          color: themeBlue,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    SizedBox(height: 5),
                    Card(
                      color: Colors.white,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                     child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Email with visibility toggle
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
                                  icon: Icon(
                                    _showEmail ? Icons.visibility_off : Icons.visibility,
                                    color: themeBlue,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _showEmail = !_showEmail;
                                    });
                                  },
                                ),
                              ],
                            ),
                            Divider(height: 16, thickness: 1),
                            // Birthdate
                            _profileItem(
                              icon: Icons.cake,
                              label: "Birthdate",
                              value: user!['birthdate'] != null && user!['birthdate'] != ''
                                  ? _formatDate(user!['birthdate'])
                                  : '',
                              themeBlue: themeBlue,
                              screenWidth: screenWidth,
                            ),
                            Divider(height: 16, thickness: 1),
                            // Sex
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
    double iconSize = screenWidth * 0.050;
    double labelFontSize = screenWidth * 0.040;
    double valueFontSize = screenWidth * 0.040;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: themeBlue, size: iconSize),
          SizedBox(width: screenWidth * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.robotoMono(
                    fontSize: labelFontSize,
                    color: Colors.blueGrey[800],
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  value,
                  style: GoogleFonts.robotoMono(
                    fontSize: valueFontSize,
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

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: screenWidth > 420 ? 400 : screenWidth * 0.95,
        decoration: BoxDecoration(
          color: themeBlue,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: themeBlue.withOpacity(0.15),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.edit, color: Colors.white, size: 28),
                  const SizedBox(width: 10),
                  Text(
                    "Edit Details",
                    style: GoogleFonts.robotoMono(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Divider(color: Colors.white24, thickness: 1),
              const SizedBox(height: 24),
              _buildTextField(
                controller: fNameController,
                label: "First Name",
                icon: Icons.account_circle,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: mNameController,
                label: "Middle Name",
                icon: Icons.account_circle,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: lNameController,
                label: "Last Name",
                icon: Icons.account_circle,
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _pickBirthdate,
                child: AbsorbPointer(
                  child: _buildTextField(
                    controller: birthdateController,
                    label: "Birthdate",
                    icon: Icons.cake,
                    suffixIcon: Icons.calendar_today,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 64,
                child: DropdownButtonFormField<String>(
                  value: sexOptions.contains(sexController.text)
                      ? sexController.text
                      : null,
                  items: sexOptions
                      .map(
                        (sex) => DropdownMenuItem(
                          value: sex,
                          child: Text(
                            sex,
                            style: GoogleFonts.robotoMono(color: Colors.white, fontSize: 17),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    sexController.text = val ?? '';
                    setState(() {});
                  },
                  dropdownColor: themeBlue,
                  style: GoogleFonts.robotoMono(color: Colors.white, fontSize: 17),
                  decoration: InputDecoration(
                    labelText: "Sex",
                    labelStyle: GoogleFonts.robotoMono(color: Colors.white70, fontSize: 15),
                    prefixIcon: Icon(Icons.wc, color: Colors.white70, size: 22),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    filled: true,
                    fillColor: themeBlue.withOpacity(0.9),
                    contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 18),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: loading ? null : () => Navigator.pop(context),
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      textStyle: MaterialStateProperty.all(GoogleFonts.robotoMono(fontWeight: FontWeight.bold)),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      overlayColor: MaterialStateProperty.resolveWith<Color?>((states) {
                        if (states.contains(MaterialState.hovered)) {
                          return Colors.white.withOpacity(0.15);
                        }
                        return null;
                      }),
                    ),
                    child: Text("Cancel", style: GoogleFonts.robotoMono()),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: themeBlue,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    IconData? suffixIcon,
  }) {
    return SizedBox(
      height: 64,
      child: TextField(
        controller: controller,
        style: GoogleFonts.robotoMono(color: Colors.white, fontSize: 17),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.robotoMono(color: Colors.white70, fontSize: 15),
          prefixIcon: Icon(icon, color: Colors.white70, size: 22),
          suffixIcon: suffixIcon != null
              ? Icon(suffixIcon, color: Colors.white70, size: 20)
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white24),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white),
          ),
          filled: true,
          fillColor: const Color(0xFF334E7B).withOpacity(0.9),
          contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 18),
        ),
      ),
    );
  }
  }

