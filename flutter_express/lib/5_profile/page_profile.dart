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
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Color(0xFF334E7B), size: 32),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Profile",
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
      body: user == null
          ? Center(
              child: Text(
                "No user data",
                style: GoogleFonts.robotoMono(),
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.only(
                top: 0, 
                left: 24,
                right: 24,
                bottom: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  
                  Center(
                    child: Text(
                      "",
                      style: GoogleFonts.poppins(
                        fontSize: 33,
                        fontWeight: FontWeight.w700,
                        color: themeBlue,
                        letterSpacing: 0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 20), 
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Full Name",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: themeBlue,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: Color(0xFF334E7B),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              "${user!['f_name'] ?? ''} ${user!['m_name'] ?? ''} ${user!['l_name'] ?? ''}",
                              style: GoogleFonts.robotoMono(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
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
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Account Created",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: themeBlue,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: themeBlue.withOpacity(0.4),
                          width: 1.2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        user!['created_at'] != null
                            ? _formatDate(user!['created_at'])
                            : 'Unknown registration date',
                        style: GoogleFonts.robotoMono(
                          fontSize: 15,
                          color: Colors.blueGrey[700],
                          letterSpacing: 0.2,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Profile Details",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: themeBlue,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(left: 0, right: 16, top: 16, bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Email with visibility toggle
                          Row(
                            children: [
                              Expanded(
                                child: _profileItem(
                                  icon: null,
                                  label: "Email",
                                  value: _showEmail
                                      ? (user!['email'] ?? '')
                                      : "************",
                                  themeBlue: themeBlue,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  _showEmail
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
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
                          Divider(height: 16, thickness: 1, color: Color(0xFF334E7B)),
                          // Birthdate
                          _profileItem(
                            icon: null,
                            label: "Birthdate",
                            value: user!['birthdate'] != null &&
                                    user!['birthdate'] != ''
                                ? _formatDate(user!['birthdate'])
                                : '',
                            themeBlue: themeBlue,
                          ),
                          Divider(height: 16, thickness: 1, color: Color(0xFF334E7B)),
                          // Sex
                          _profileItem(
                            icon: null,
                            label: "Sex",
                            value: user!['sex'] ?? '',
                            themeBlue: themeBlue,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [Color(0xFF334E7B), Color(0xFF4A6BA5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF334E7B).withOpacity(0.3),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 20),
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 12),
                          Text( 
                            "Edit Profile",
                            style: GoogleFonts.robotoMono(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 12),
                          Icon(Icons.chevron_right_outlined, color: Colors.white, size: 30),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  Widget _profileItem({
    IconData? icon,
    required String label,
    required String value,
    required Color themeBlue,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, color: themeBlue, size: 22),
            SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.robotoMono(
                    fontSize: 14,
                    color: Colors.blueGrey[800],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.robotoMono(
                    fontSize: 15,
                    color: themeBlue,
                    fontWeight: FontWeight.w500,
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
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
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
  final List<String> sexOptions = ['Male', 'Female', 'Prefer not to say it'];

  @override
  void initState() {
    super.initState();
    fNameController = TextEditingController(text: widget.user['f_name'] ?? '');
    mNameController = TextEditingController(text: widget.user['m_name'] ?? '');
    lNameController = TextEditingController(text: widget.user['l_name'] ?? '');
    birthdateController =
        TextEditingController(text: widget.user['birthdate'] ?? '');
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SizedBox(width: 10),
                  Text(
                    "Edit Details",
                    style: GoogleFonts.poppins(
                      color: themeBlue,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Divider(color: Colors.grey[300], thickness: 1),
              const SizedBox(height: 24),
              _buildTextField(
                controller: fNameController,
                label: "First Name",
                icon: null,
                themeBlue: themeBlue,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: mNameController,
                label: "Middle Name",
                icon: null,
                themeBlue: themeBlue,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: lNameController,
                label: "Last Name",
                icon: null,
                themeBlue: themeBlue,
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickBirthdate,
                child: AbsorbPointer(
                  child: _buildTextField(
                    controller: birthdateController,
                    label: "Birthdate",
                    icon: Icons.cake_outlined,
                    suffixIcon: Icons.calendar_today_outlined,
                    themeBlue: themeBlue,
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
                            style: GoogleFonts.robotoMono(
                                color: themeBlue, fontSize: 15),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    sexController.text = val ?? '';
                    setState(() {});
                  },
                  dropdownColor: Colors.white,
                  style:
                      GoogleFonts.robotoMono(color: themeBlue, fontSize: 15),
                  decoration: InputDecoration(
                    labelText: "Sex",
                    labelStyle: GoogleFonts.robotoMono(
                        color: Colors.grey[600], fontSize: 14),
                    prefixIcon: Icon(Icons.wc_outlined,
                        color: Color(0xFF334E7B), size: 22),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: themeBlue, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[400]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: themeBlue, width: 1.5),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 20, horizontal: 18),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: loading ? null : () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    child: Text(
                      "Cancel",
                      style: GoogleFonts.robotoMono(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        colors: [Color(0xFF334E7B), Color(0xFF4A6BA5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
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
                              if (result['status'] == 200 ||
                                  result['status'] == "200") {
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
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              "Update",
                              style: GoogleFonts.robotoMono(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
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
  IconData? icon,
    IconData? suffixIcon,
    required Color themeBlue,
  }) {
    return SizedBox(
      height: 64,
      child: TextField(
        controller: controller,
        style: GoogleFonts.robotoMono(color: themeBlue, fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
              GoogleFonts.robotoMono(color: Color(0xFF334E7B), fontSize: 14, fontWeight: FontWeight.w500),
          prefixIcon: icon != null ? Icon(icon, color: Color(0xFF334E7B), size: 22) : null,
          suffixIcon: suffixIcon != null
              ? Icon(suffixIcon, color: Colors.grey[600], size: 20)
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: themeBlue, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: themeBlue, width: 1.5),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 18),
        ),
      ),
    );
  }
}