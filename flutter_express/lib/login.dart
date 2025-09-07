import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_express/00_services/api_services.dart';
import 'package:flutter_express/global_variables.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '0_components/popup_information.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  bool loading = false;
  String? error;
  bool _passwordVisible = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      loading = true;
      error = null;
    });
    _formKey.currentState!.save();
    try {
      final result = await ApiService.login(email, password);
      if (result['status'] == 200) {
        final user = result['user'];
        if (user['role'] == 'admin' || user['role'] == 'superadmin') {
          setState(() {
            error = 'Invalid credentials';
            loading = false;
          });
          return;
        }

        // Set user session
        UserSession.setUser(user);

        // Save login state and user data to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('seenIntro', true);
        await prefs.setBool('isLoggedIn', true);

        // Save user data as JSON string
        final userDataString = jsonEncode(user);
        await prefs.setString('userData', userDataString);

        await PopupInformation.show(
          context,
          title: "Login Successful",
          message: "Welcome!",
          onOk: () {
            Navigator.pushReplacementNamed(context, '/landing');
          },
        );
        GlobalVariables.currentIndex = 0;
      } else {
        setState(() {
          error = result['message'] ?? 'Login failed';
        });
      }
    } catch (e) {
      setState(() {
        error = 'Network error';
      });
    }
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 375.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: 24 * scale,
            vertical: 36 * scale,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Welcome to ',
                      style: GoogleFonts.robotoMono(
                        fontSize: 28 * scale,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF334E7B),
                      ),
                    ),
                    Text(
                      'ex',
                      style: GoogleFonts.robotoMono(
                        fontSize: 28 * scale,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'Press',
                      style: GoogleFonts.robotoMono(
                        fontSize: 28 * scale,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF4C75F2),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8 * scale),
                Text(
                  'Sign in to continue your journey',
                  style: GoogleFonts.robotoMono(
                    fontSize: 14 * scale,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 40 * scale),

                // Email field
                TextFormField(
                  style: GoogleFonts.robotoMono(fontSize: 18),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: GoogleFonts.robotoMono(fontSize: 16),
                    hintStyle: GoogleFonts.robotoMono(fontSize: 18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF334E7B),
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF334E7B),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF334E7B),
                        width: 1,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter email' : null,
                  onSaved: (v) => email = v!.trim(),
                ),
                SizedBox(height: 12 * scale),

                // Password field
                TextFormField(
                  style: GoogleFonts.robotoMono(fontSize: 18),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: GoogleFonts.robotoMono(fontSize: 16),
                    hintStyle: GoogleFonts.robotoMono(fontSize: 18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF334E7B),
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF334E7B),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF334E7B),
                        width: 1,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                  ),
                  obscureText: !_passwordVisible,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter password' : null,
                  onSaved: (v) => password = v!,
                ),

                if (error != null) ...[
                  SizedBox(height: 16 * scale),
                  Text(
                    error!,
                    style: GoogleFonts.robotoMono(color: Colors.red),
                  ),
                ],
                SizedBox(height: 24 * scale),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF334E7B),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: loading
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          )
                        : Text(
                            'Login',
                            style: GoogleFonts.robotoMono(
                              color: Colors.white,
                              fontSize: 18 * scale,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                SizedBox(height: 16 * scale),
                Text(
                  "OR",
                  style: GoogleFonts.robotoMono(
                    color: Colors.grey[600],
                    fontSize: 14 * scale,
                  ),
                ),
                SizedBox(height: 16 * scale),

                // Register Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(color: Color(0xFF334E7B)),
                    ),
                    child: Text(
                      'Register',
                      style: GoogleFonts.robotoMono(
                        color: const Color(0xFF334E7B),
                        fontSize: 18 * scale,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
