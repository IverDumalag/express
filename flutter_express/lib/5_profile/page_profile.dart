import 'package:flutter/material.dart';
import '../00_services/api_services.dart';
import '../global_variables.dart';

class PageProfile extends StatefulWidget {
  const PageProfile({Key? key}) : super(key: key);

  @override
  State<PageProfile> createState() => _PageProfileState();
}

class _PageProfileState extends State<PageProfile> {
  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    user = UserSession.user;
  }

  @override
  Widget build(BuildContext context) {
    final themeBlue = const Color(0xFF2354C7);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: themeBlue.withOpacity(0.07),
      body: user == null
          ? const Center(child: Text("No user data"))
          : Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.08,
                  vertical: screenHeight * 0.04,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Removed CircleAvatar here
                    SizedBox(height: screenHeight * 0.03),
                    Text(
                      "${user!['f_name'] ?? ''} ${user!['m_name'] ?? ''} ${user!['l_name'] ?? ''}",
                      style: TextStyle(
                        fontSize: screenWidth * 0.07,
                        fontWeight: FontWeight.bold,
                        color: themeBlue,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      user!['email'] ?? '',
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        color: Colors.blueGrey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    Card(
                      color: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.06,
                          vertical: screenHeight * 0.025,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _profileItem(
                              icon: Icons.account_circle,
                              label: "First Name",
                              value: user!['f_name'] ?? '',
                              themeBlue: themeBlue,
                              screenWidth: screenWidth,
                            ),
                            Divider(),
                            _profileItem(
                              icon: Icons.account_circle,
                              label: "Middle Name",
                              value: user!['m_name'] ?? '',
                              themeBlue: themeBlue,
                              screenWidth: screenWidth,
                            ),
                            Divider(),
                            _profileItem(
                              icon: Icons.account_circle_outlined,
                              label: "Last Name",
                              value: user!['l_name'] ?? '',
                              themeBlue: themeBlue,
                              screenWidth: screenWidth,
                            ),
                            Divider(),
                            _profileItem(
                              icon: Icons.email,
                              label: "Email",
                              value: user!['email'] ?? '',
                              themeBlue: themeBlue,
                              screenWidth: screenWidth,
                            ),
                            Divider(),
                            _profileItem(
                              icon: Icons.cake,
                              label: "Birthdate",
                              value: user!['birthdate'] ?? '',
                              themeBlue: themeBlue,
                              screenWidth: screenWidth,
                            ),
                            Divider(),
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
                    SizedBox(height: screenHeight * 0.04),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeBlue,
                        foregroundColor: Colors.white,
                        minimumSize: Size(screenWidth * 0.5, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.edit),
                      label: Text(
                        "Edit Profile",
                        style: TextStyle(fontSize: screenWidth * 0.045),
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
        children: [
          Icon(icon, color: themeBlue, size: screenWidth * 0.06),
          SizedBox(width: screenWidth * 0.04),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                color: Colors.blueGrey[800],
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              color: themeBlue,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
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
  late TextEditingController passwordController;

  bool loading = false;

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
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    fNameController.dispose();
    mNameController.dispose();
    lNameController.dispose();
    birthdateController.dispose();
    sexController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeBlue = const Color(0xFF2354C7);
    final screenWidth = MediaQuery.of(context).size.width;

    return AlertDialog(
      title: const Text("Edit Profile"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: fNameController,
              decoration: const InputDecoration(labelText: "First Name"),
            ),
            TextField(
              controller: mNameController,
              decoration: const InputDecoration(labelText: "Middle Name"),
            ),
            TextField(
              controller: lNameController,
              decoration: const InputDecoration(labelText: "Last Name"),
            ),
            TextField(
              controller: birthdateController,
              decoration: const InputDecoration(labelText: "Birthdate"),
            ),
            TextField(
              controller: sexController,
              decoration: const InputDecoration(labelText: "Sex"),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: "New Password (optional)",
              ),
              obscureText: true,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: loading ? null : () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: themeBlue),
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
                    password: passwordController.text.isNotEmpty
                        ? passwordController.text
                        : null,
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
                        content: Text(result['message'] ?? "Update failed"),
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
              : const Text("Save"),
        ),
      ],
    );
  }
}
