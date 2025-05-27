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

  @override
  Widget build(BuildContext context) {
    final double scale = MediaQuery.of(context).size.width / 375.0;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF334E7B),
        title: Text("Register"),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 32 * scale),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text(
                  'Create your account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24 * scale,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF334E7B),
                    fontFamily: 'Inter',
                  ),
                ),
                SizedBox(height: 24 * scale),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'First Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter first name' : null,
                  onSaved: (v) => fName = v!.trim(),
                ),
                SizedBox(height: 12 * scale),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Middle Name (optional)',
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (v) => mName = v!.trim(),
                ),
                SizedBox(height: 12 * scale),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Last Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter last name' : null,
                  onSaved: (v) => lName = v!.trim(),
                ),
                SizedBox(height: 12 * scale),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter email' : null,
                  onSaved: (v) => email = v!.trim(),
                ),
                SizedBox(height: 12 * scale),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Sex',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(value: 'Male', child: Text('Male')),
                    DropdownMenuItem(value: 'Female', child: Text('Female')),
                  ],
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Select sex' : null,
                  onChanged: (v) => sex = v ?? '',
                  onSaved: (v) => sex = v ?? '',
                ),
                SizedBox(height: 12 * scale),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Birthdate',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                  controller: TextEditingController(text: birthdate),
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
                      });
                    }
                  },
                  validator: (v) =>
                      birthdate.isEmpty ? 'Select birthdate' : null,
                ),
                SizedBox(height: 12 * scale),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter password' : null,
                  onSaved: (v) => password = v!,
                ),
                SizedBox(height: 12 * scale),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Confirm password' : null,
                  onSaved: (v) => confirmPassword = v!,
                ),
                if (error != null) ...[
                  SizedBox(height: 16 * scale),
                  Text(error!, style: TextStyle(color: Colors.red)),
                ],
                if (success != null) ...[
                  SizedBox(height: 16 * scale),
                  Text(success!, style: TextStyle(color: Colors.green)),
                ],
                SizedBox(height: 24 * scale),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF334E7B),
                      padding: EdgeInsets.symmetric(vertical: 16 * scale),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: loading
                        ? CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          )
                        : Text(
                            'Register',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18 * scale,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                SizedBox(height: 16 * scale),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: TextStyle(color: Colors.black87),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: Text(
                        "Login",
                        style: TextStyle(
                          color: Color(0xFF334E7B),
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
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
  }
}
