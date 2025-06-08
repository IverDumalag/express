import 'package:flutter/material.dart';
import 'package:flutter_express/00_services/api_services.dart';
import 'package:flutter_express/global_variables.dart';
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
        UserSession.setUser(user);
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
                Text(
                  'Welcome to exPress',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26 * scale,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF334E7B),
                  ),
                ),
                SizedBox(height: 8 * scale),
                Text(
                  'Sign in to continue your journey',
                  style: TextStyle(
                    fontSize: 14 * scale,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 24 * scale),

                // Email field
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'you@example.com',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter email' : null,
                  onSaved: (v) => email = v!.trim(),
                ),
                SizedBox(height: 16 * scale),

                // Password field
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: '••••••••••',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
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
                  Text(error!, style: const TextStyle(color: Colors.red)),
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
                        borderRadius: BorderRadius.circular(16),
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
                            style: TextStyle(
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
                  style: TextStyle(
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
                        borderRadius: BorderRadius.circular(16),
                      ),
                      side: const BorderSide(color: Color(0xFF334E7B)),
                    ),
                    child: Text(
                      'Register',
                      style: TextStyle(
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
