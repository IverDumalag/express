import 'package:flutter/material.dart';
import '00_services/api_services.dart';
import '0_components/popup_information.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String confirmPassword = '';
  String fName = '';
  String mName = '';
  String lName = '';
  String sex = '';
  String birthdate = '';
  bool loading = false;
  String? error;
  String? success;

  final birthdateController = TextEditingController();

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (password != confirmPassword) {
      setState(() {
        error = "Passwords do not match";
      });
      return;
    }
    setState(() {
      loading = true;
      error = null;
      success = null;
    });
    _formKey.currentState!.save();
    try {
      final result = await ApiService.register(
        email: email,
        password: password,
        fName: fName,
        mName: mName,
        lName: lName,
        sex: sex,
        birthdate: birthdate,
      );
      if (result['status'] == 201) {
        setState(() {
          success = "Registration successful! Please login.";
        });
        await PopupInformation.show(
          context,
          title: "Registration Successful",
          message: "You can now login.",
          onOk: () {
            Navigator.pushReplacementNamed(context, '/login');
          },
        );
      } else {
        setState(() {
          error = result['message'] ?? 'Registration failed';
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

  Widget _buildField({
    required String hint,
    bool obscure = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
    TextEditingController? controller,
    VoidCallback? onTap,
    bool readOnly = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      onSaved: onSaved,
      controller: controller,
      onTap: onTap,
      readOnly: readOnly,
      style: const TextStyle(fontSize: 20),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 20),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        suffixIcon: suffixIcon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/continue_us.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height - 40),
                child: IntrinsicHeight(
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Register",
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF334E7B),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Sign up to get started",
                            style: TextStyle(fontSize: 20, color: Colors.grey),
                          ),
                          const SizedBox(height: 30),
                          _buildField(
                            hint: "First Name",
                            validator: (v) => v!.isEmpty ? "Required" : null,
                            onSaved: (v) => fName = v!.trim(),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: _buildField(
                                  hint: "Middle Name",
                                  onSaved: (v) => mName = v!.trim(),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildField(
                                  hint: "Surname",
                                  validator: (v) => v!.isEmpty ? "Required" : null,
                                  onSaved: (v) => lName = v!.trim(),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              hintText: "Select your Sex",
                              hintStyle: const TextStyle(fontSize: 20),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            style: const TextStyle(fontSize: 20, color: Colors.black),
                            items: const [
                              DropdownMenuItem(value: "Male", child: Text("Male")),
                              DropdownMenuItem(value: "Female", child: Text("Female")),
                            ],
                            validator: (v) => v == null ? "Required" : null,
                            onChanged: (v) => sex = v ?? '',
                            onSaved: (v) => sex = v ?? '',
                          ),
                          const SizedBox(height: 20),
                          _buildField(
                            hint: "Birthdate",
                            controller: birthdateController,
                            readOnly: true,
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime(2000, 1, 1),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setState(() {
                                  birthdate = picked.toIso8601String().split('T')[0];
                                  birthdateController.text = birthdate;
                                });
                              }
                            },
                            validator: (v) => birthdate.isEmpty ? "Select birthdate" : null,
                            suffixIcon: const Icon(Icons.calendar_today),
                          ),
                          const SizedBox(height: 20),
                          _buildField(
                            hint: "Email",
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return "Email is required";
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) return "Enter a valid email";
                              return null;
                            },
                            onSaved: (v) => email = v!.trim(),
                          ),
                          const SizedBox(height: 20),
                          _buildField(
                            hint: "Password (At least 8+ strong characters)",
                            obscure: true,
                            validator: (v) => v!.length < 8 ? "Minimum 8 characters" : null,
                            onSaved: (v) => password = v!,
                          ),
                          const SizedBox(height: 20),
                          _buildField(
                            hint: "Confirm Password..",
                            obscure: true,
                            validator: (v) => v!.isEmpty ? "Confirm password" : null,
                            onSaved: (v) => confirmPassword = v!,
                          ),
                          if (error != null) ...[
                            const SizedBox(height: 20),
                            Text(error!, style: const TextStyle(color: Colors.red, fontSize: 18)),
                          ],
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: loading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF334E7B),
                                padding: const EdgeInsets.symmetric(vertical: 24),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              child: loading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text(
                                      'Register',
                                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
