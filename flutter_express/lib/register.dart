import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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

  // Password visibility toggles
  bool showPassword = false;
  bool showConfirmPassword = false;

  // OTP related variables
  bool otpStep = false;
  String otpCode = '';
  String sentOtp = '';
  bool otpLoading = false;
  int resendTimer = 0;

  final birthdateController = TextEditingController();
  final otpController = TextEditingController();

  // Generate random 6-digit OTP
  String generateOTP() {
    return (100000 + (900000 * (DateTime.now().millisecond / 1000)).floor())
        .toString();
  }

  // Send OTP using the Node.js backend
  Future<void> sendOTP() async {
    if (email.trim().isEmpty) {
      setState(() {
        error = "Please enter your email first.";
      });
      return;
    }

    setState(() {
      otpLoading = true;
      error = null;
    });

    final otp = generateOTP();
    setState(() {
      sentOtp = otp;
    });

    try {
      const otpUrl = 'https://express-nodejs-nc12.onrender.com/send-otp';
      final response = await http.post(
        Uri.parse(otpUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'to': email.trim(), 'otp': otp}),
      );

      final result = jsonDecode(response.body);

      if (result['success'] == true) {
        await PopupInformation.show(
          context,
          title: "OTP Sent",
          message: "Verification code sent to $email. Please check your email.",
        );
        setState(() {
          otpStep = true;
        });
        startResendTimer();
      } else {
        throw Exception(result['message'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      await PopupInformation.show(
        context,
        title: "Error",
        message: "Failed to send OTP. Please try again.",
      );
    } finally {
      setState(() {
        otpLoading = false;
      });
    }
  }

  // Start resend timer
  void startResendTimer() {
    setState(() {
      resendTimer = 60;
    });

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          resendTimer--;
        });
        return resendTimer > 0;
      }
      return false;
    });
  }

  // Verify OTP and proceed with registration
  Future<void> verifyOTPAndRegister() async {
    if (otpCode != sentOtp) {
      await PopupInformation.show(
        context,
        title: "Error",
        message: "Invalid OTP. Please try again.",
      );
      return;
    }

    // OTP verified, proceed with registration
    setState(() {
      loading = true;
      error = null;
    });

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
        await PopupInformation.show(
          context,
          title: "Registration Successful",
          message:
              "Your account has been created successfully! You can now login.",
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
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  void _submit() async {
    if (!otpStep) {
      // First step: Validate form and send OTP
      if (!_formKey.currentState!.validate()) return;
      if (password != confirmPassword) {
        setState(() {
          error = "Passwords do not match";
        });
        return;
      }
      _formKey.currentState!.save();
      await sendOTP();
    } else {
      // Second step: Verify OTP and register
      if (otpCode.length != 6) {
        setState(() {
          error = "Please enter the 6-digit OTP code";
        });
        return;
      }
      await verifyOTPAndRegister();
    }
  }

  // Go back to form step
  void goBackToForm() {
    setState(() {
      otpStep = false;
      otpCode = '';
      sentOtp = '';
      otpController.clear();
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
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 400;
    final fontSize = isSmallScreen ? 16.0 : 18.0;

    return TextFormField(
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      onSaved: onSaved,
      controller: controller,
      onTap: onTap,
      readOnly: readOnly,
      style: GoogleFonts.robotoMono(fontSize: fontSize),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.robotoMono(fontSize: fontSize),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 16 : 24,
          vertical: isSmallScreen ? 16 : 22,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF334E7B), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF334E7B), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF334E7B), width: 1),
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final isSmallScreen = screenWidth < 400;
    final isMediumScreen = screenWidth >= 400 && screenWidth < 600;
    final isLargeScreen = screenWidth >= 600;

    // Responsive sizes
    final horizontalPadding = isSmallScreen
        ? 16.0
        : (isMediumScreen ? 20.0 : 24.0);
    final containerPadding = isSmallScreen
        ? 20.0
        : (isMediumScreen ? 28.0 : 32.0);
    final titleSize = isSmallScreen ? 28.0 : (isMediumScreen ? 32.0 : 36.0);
    final subtitleSize = isSmallScreen ? 16.0 : (isMediumScreen ? 18.0 : 20.0);
    final spacing = isSmallScreen ? 16.0 : 20.0;
    final buttonPadding = isSmallScreen ? 18.0 : 24.0;
    final buttonFontSize = isSmallScreen ? 18.0 : 22.0;

    // Container width constraints
    final maxWidth = isLargeScreen ? 500.0 : double.infinity;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.all(horizontalPadding),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight:
                          constraints.maxHeight - (horizontalPadding * 2),
                    ),
                    child: Center(
                      child: Container(
                        width: maxWidth,
                        padding: EdgeInsets.all(containerPadding),
                        
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                otpStep ? "Verify Email" : "Register",
                                style: GoogleFonts.robotoMono(
                                  fontSize: titleSize,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF334E7B),
                                ),
                              ),
                              SizedBox(height: spacing * 0.5),
                              Text(
                                otpStep
                                    ? "Enter the verification code sent to your email"
                                    : "Sign up to get started",
                                style: GoogleFonts.robotoMono(
                                  fontSize: subtitleSize,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: spacing * 1.5),

                              if (!otpStep) ...[
                                // Registration Form
                                _buildField(
                                  hint: "First Name",
                                  validator: (v) =>
                                      v!.isEmpty ? "Required" : null,
                                  onSaved: (v) => fName = v!.trim(),
                                ),
                                SizedBox(height: spacing),

                                // Responsive row for name fields
                                if (isSmallScreen) ...[
                                  _buildField(
                                    hint: "Middle Name",
                                    onSaved: (v) => mName = v!.trim(),
                                  ),
                                  SizedBox(height: spacing),
                                  _buildField(
                                    hint: "Surname",
                                    validator: (v) =>
                                        v!.isEmpty ? "Required" : null,
                                    onSaved: (v) => lName = v!.trim(),
                                  ),
                                ] else ...[
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildField(
                                          hint: "Middle Name",
                                          onSaved: (v) => mName = v!.trim(),
                                        ),
                                      ),
                                      SizedBox(width: spacing),
                                      Expanded(
                                        child: _buildField(
                                          hint: "Surname",
                                          validator: (v) =>
                                              v!.isEmpty ? "Required" : null,
                                          onSaved: (v) => lName = v!.trim(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                SizedBox(height: spacing),

                                DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    hintText: "Select your Sex",
                                    hintStyle: GoogleFonts.robotoMono(
                                      fontSize: isSmallScreen ? 16.0 : 18.0,
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: isSmallScreen ? 16 : 24,
                                      vertical: isSmallScreen ? 16 : 22,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(color: Color(0xFF334E7B), width: 1),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(color: Color(0xFF334E7B), width: 1),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(color: Color(0xFF334E7B), width: 1),
                                    ),
                                  ),
                                  style: GoogleFonts.robotoMono(
                                    fontSize: isSmallScreen ? 16.0 : 18.0,
                                    color: Colors.black,
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: "Male",
                                      child: Text("Male"),
                                    ),
                                    DropdownMenuItem(
                                      value: "Female",
                                      child: Text("Female"),
                                    ),
                                  ],
                                  validator: (v) =>
                                      v == null ? "Required" : null,
                                  onChanged: (v) => sex = v ?? '',
                                  onSaved: (v) => sex = v ?? '',
                                ),
                                SizedBox(height: spacing),

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
                                        birthdate = picked
                                            .toIso8601String()
                                            .split('T')[0];
                                        birthdateController.text = birthdate;
                                      });
                                    }
                                  },
                                  validator: (v) => birthdate.isEmpty
                                      ? "Select birthdate"
                                      : null,
                                  suffixIcon: const Icon(Icons.calendar_today),
                                  // Border color handled in _buildField
                                ),
                                SizedBox(height: spacing),

                                _buildField(
                                  hint: "Email",
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty)
                                      return "Email is required";
                                    if (!RegExp(
                                      r'^[^@]+@[^@]+\.[^@]+',
                                    ).hasMatch(v))
                                      return "Enter a valid email";
                                    return null;
                                  },
                                  onSaved: (v) => email = v!.trim(),
                                ),
                                SizedBox(height: spacing),

                                _buildField(
                                  hint:
                                      "Password (At least 8+ strong characters)",
                                  obscure: !showPassword,
                                  validator: (v) => v!.length < 8
                                      ? "Minimum 8 characters"
                                      : null,
                                  onSaved: (v) => password = v!,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      showPassword ? Icons.visibility : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        showPassword = !showPassword;
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(height: spacing),

                                _buildField(
                                  hint: "Confirm Password",
                                  obscure: !showConfirmPassword,
                                  validator: (v) =>
                                      v!.isEmpty ? "Confirm password" : null,
                                  onSaved: (v) => confirmPassword = v!,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      showConfirmPassword ? Icons.visibility : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        showConfirmPassword = !showConfirmPassword;
                                      });
                                    },
                                  ),
                                ),
                              ] else ...[
                                // OTP Verification Form
                                TextFormField(
                                  controller: otpController,
                                  onChanged: (value) {
                                    String filtered = value.replaceAll(
                                      RegExp(r'[^0-9]'),
                                      '',
                                    );
                                    if (filtered.length <= 6) {
                                      otpController.value = TextEditingValue(
                                        text: filtered,
                                        selection: TextSelection.collapsed(
                                          offset: filtered.length,
                                        ),
                                      );
                                      setState(() {
                                        otpCode = filtered;
                                      });
                                    }
                                  },
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.robotoMono(
                                    fontSize: isSmallScreen ? 24.0 : 32.0,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: isSmallScreen ? 4.0 : 8.0,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: "Enter 6-digit code",
                                    hintStyle: GoogleFonts.robotoMono(
                                      fontSize: isSmallScreen ? 16.0 : 20.0,
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: isSmallScreen ? 16 : 24,
                                      vertical: isSmallScreen ? 16 : 22,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(color: Color(0xFF334E7B), width: 1),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(color: Color(0xFF334E7B), width: 1),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(color: Color(0xFF334E7B), width: 1),
                                    ),
                                  ),
                                  maxLength: 6,
                                ),
                                SizedBox(height: spacing),

                                if (resendTimer > 0)
                                  Center(
                                    child: Text(
                                      "Resend code in ${resendTimer}s",
                                      style: GoogleFonts.robotoMono(
                                        color: Colors.grey,
                                        fontSize: isSmallScreen ? 14.0 : 16.0,
                                      ),
                                    ),
                                  )
                                else
                                  Center(
                                    child: TextButton(
                                      onPressed: otpLoading ? null : sendOTP,
                                      child: Text(
                                        otpLoading
                                            ? "Sending..."
                                            : "Resend Code",
                                        style: GoogleFonts.robotoMono(
                                          color: const Color(0xFF334E7B),
                                          fontSize: isSmallScreen ? 14.0 : 16.0,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ),
                                SizedBox(height: spacing),

                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    onPressed: goBackToForm,
                                    style: OutlinedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                        vertical: buttonPadding * 0.7,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      side: const BorderSide(
                                        color: Color(0xFF334E7B),
                                      ),
                                    ),
                                    child: Text(
                                      'Back to Form',
                                      style: GoogleFonts.robotoMono(
                                        color: const Color(0xFF334E7B),
                                        fontSize: buttonFontSize * 0.8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],

                              if (error != null) ...[
                                SizedBox(height: spacing),
                                Text(
                                  error!,
                                  style: GoogleFonts.robotoMono(
                                    color: Colors.red,
                                    fontSize: isSmallScreen ? 16.0 : 18.0,
                                  ),
                                ),
                              ],
                              SizedBox(height: spacing * 1.6),

                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: (loading || otpLoading)
                                      ? null
                                      : _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF334E7B),
                                    padding: EdgeInsets.symmetric(
                                      vertical: buttonPadding,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: (loading || otpLoading)
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : Text(
                                          otpStep
                                              ? (otpCode.length == 6
                                                    ? 'Verify & Register'
                                                    : 'Enter OTP Code')
                                              : 'Send Verification Code',
                                          style: GoogleFonts.robotoMono(
                                            fontSize: buttonFontSize,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
