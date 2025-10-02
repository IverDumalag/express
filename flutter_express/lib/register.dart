import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '00_services/api_services.dart';
import '0_components/popup_information.dart';
import '4_settings/about_page.dart';

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

  // Password validation state
  bool hasMinLength = false;
  bool hasUppercase = false;
  bool hasLowercase = false;
  bool hasSpecialChar = false;
  bool passwordsMatch = false;

  // Name validation state
  bool firstNameHasInvalidChars = false;
  bool middleNameHasInvalidChars = false;
  bool lastNameHasInvalidChars = false;

  // Password validation functions
  void validatePassword(String password) {
    setState(() {
      hasMinLength = password.length >= 8;
      hasUppercase = password.contains(RegExp(r'[A-Z]'));
      hasLowercase = password.contains(RegExp(r'[a-z]'));
      hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  void validatePasswordMatch() {
    setState(() {
      passwordsMatch =
          password.isNotEmpty &&
          confirmPassword.isNotEmpty &&
          password == confirmPassword;
    });
  }

  bool isPasswordValid() {
    return hasMinLength && hasUppercase && hasLowercase && hasSpecialChar;
  }

  // Name validation functions
  bool hasInvalidNameCharacters(String name) {
    // Check for numbers and special characters (allow only letters, spaces, hyphens, and apostrophes)
    return name.contains(RegExp(r'[0-9!@#$%^&*(),.?":{}|<>+=\[\]\\/_~`]'));
  }

  void validateFirstName(String name) {
    setState(() {
      firstNameHasInvalidChars = hasInvalidNameCharacters(name);
    });
  }

  void validateMiddleName(String name) {
    setState(() {
      middleNameHasInvalidChars = hasInvalidNameCharacters(name);
    });
  }

  void validateLastName(String name) {
    setState(() {
      lastNameHasInvalidChars = hasInvalidNameCharacters(name);
    });
  }

  // Helper widget for validation indicators
  Widget _buildValidationIndicator({
    required String text,
    required bool isValid,
    required bool isSmallScreen,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.cancel,
            color: isValid ? Colors.green : Colors.red,
            size: isSmallScreen ? 16.0 : 18.0,
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.robotoMono(
                color: isValid ? Colors.green : Colors.red,
                fontSize: isSmallScreen ? 12.0 : 14.0,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for password match indicator
  Widget _buildPasswordMatchIndicator({required bool isSmallScreen}) {
    if (confirmPassword.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            passwordsMatch ? Icons.check_circle : Icons.cancel,
            color: passwordsMatch ? Colors.green : Colors.red,
            size: isSmallScreen ? 16.0 : 18.0,
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              passwordsMatch ? "Passwords match" : "Passwords don't match",
              style: GoogleFonts.robotoMono(
                color: passwordsMatch ? Colors.green : Colors.red,
                fontSize: isSmallScreen ? 12.0 : 14.0,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for name validation indicator
  Widget _buildNameValidationIndicator({
    required bool hasInvalidChars,
    required bool isSmallScreen,
  }) {
    if (!hasInvalidChars) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.cancel,
            color: Colors.red,
            size: isSmallScreen ? 16.0 : 18.0,
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              "Numbers and special characters not allowed",
              style: GoogleFonts.robotoMono(
                color: Colors.red,
                fontSize: isSmallScreen ? 12.0 : 14.0,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

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

    try {
      // Check if email already exists
      bool emailExists = await ApiService.checkEmailExists(email.trim());

      if (emailExists) {
        await PopupInformation.show(
          context,
          title: "Email Already Registered",
          message:
              "This email address is already registered. Please use a different email or try logging in instead.",
        );
        return;
      }

      final otp = generateOTP();
      setState(() {
        sentOtp = otp;
      });

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
      String errorMessage =
          "We couldn't send the verification code to your email.";
      String errorTitle = "Email Verification Failed";

      // Check for specific error types
      if (e.toString().contains('SocketException') ||
          e.toString().contains('TimeoutException')) {
        errorTitle = "Connection Problem";
        errorMessage = "Please check your internet connection and try again.";
      } else if (e.toString().contains('FormatException') ||
          e.toString().contains('invalid email')) {
        errorTitle = "Invalid Email";
        errorMessage = "Please enter a valid email address.";
      } else if (e.toString().contains('Error checking email') ||
          e.toString().contains('Failed to fetch users')) {
        errorTitle = "Verification Error";
        errorMessage = "Unable to verify email availability. Please try again.";
      } else if (e.toString().contains('already exists') ||
          e.toString().contains('duplicate')) {
        errorTitle = "Email Already Used";
        errorMessage =
            "This email is already registered. Please use a different email or try logging in.";
      }

      await PopupInformation.show(
        context,
        title: errorTitle,
        message: errorMessage,
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
        title: "Verification Failed",
        message:
            "The code you entered doesn't match. Please check your email and try again.",
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
      String errorMessage = "We couldn't complete your registration.";
      String errorTitle = "Registration Failed";

      // Check for specific error types
      if (e.toString().contains('SocketException') ||
          e.toString().contains('TimeoutException')) {
        errorTitle = "Connection Problem";
        errorMessage = "Please check your internet connection and try again.";
      } else if (e.toString().contains('already exists') ||
          e.toString().contains('duplicate')) {
        errorTitle = "Account Already Exists";
        errorMessage =
            "An account with this email already exists. Please try logging in instead.";
      } else if (e.toString().contains('invalid') ||
          e.toString().contains('format')) {
        errorTitle = "Invalid Information";
        errorMessage =
            "Please check that all information is entered correctly.";
      }

      await PopupInformation.show(
        context,
        title: errorTitle,
        message: errorMessage,
      );
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
      if (!isPasswordValid()) {
        setState(() {
          error = "Password must meet all requirements";
        });
        return;
      }
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
    void Function(String)? onChanged,
    TextEditingController? controller,
    VoidCallback? onTap,
    bool readOnly = false,
    Widget? suffixIcon,
    int? maxLength,
  }) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 400;
    final fontSize = isSmallScreen ? 16.0 : 18.0;
    final fieldFontSize = fontSize * 0.85;

    return TextFormField(
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      onSaved: onSaved,
      onChanged: onChanged,
      controller: controller,
      onTap: onTap,
      readOnly: readOnly,
      maxLength: maxLength,
      style: GoogleFonts.robotoMono(fontSize: fieldFontSize),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.robotoMono(fontSize: fieldFontSize),
        labelStyle: GoogleFonts.robotoMono(fontSize: 15.3),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 16 : 24,
          vertical: isSmallScreen ? 16 : 16,
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
    final buttonPadding = isSmallScreen ? 18.0 : 16.0;
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
                              Center(
                                child: Column(
                                  children: [
                                    Text(
                                      "Register",
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
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: spacing * 2.9),

                              if (!otpStep) ...[
                                // Registration Form
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildField(
                                      hint: "First Name",
                                      maxLength: 50,
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty) {
                                          return "First name is required";
                                        }
                                        if (v.trim().length > 50) {
                                          return "First name must be 50 characters or less";
                                        }
                                        if (hasInvalidNameCharacters(v)) {
                                          return "Only letters, spaces, hyphens, and apostrophes are allowed";
                                        }
                                        return null;
                                      },
                                      onSaved: (v) => fName = v!.trim(),
                                      onChanged: (v) {
                                        validateFirstName(v);
                                      },
                                    ),
                                    _buildNameValidationIndicator(
                                      hasInvalidChars: firstNameHasInvalidChars,
                                      isSmallScreen: isSmallScreen,
                                    ),
                                  ],
                                ),
                                SizedBox(height: spacing * 0.7),

                                // Responsive row for name fields
                                if (isSmallScreen) ...[
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildField(
                                        hint: "Middle Name",
                                        maxLength: 50,
                                        validator: (v) {
                                          if (v != null &&
                                              v.trim().length > 50) {
                                            return "Middle name must be 50 characters or less";
                                          }
                                          if (v != null &&
                                              hasInvalidNameCharacters(v)) {
                                            return "Only letters, spaces, hyphens, and apostrophes are allowed";
                                          }
                                          return null;
                                        },
                                        onSaved: (v) => mName = v!.trim(),
                                        onChanged: (v) {
                                          validateMiddleName(v);
                                        },
                                      ),
                                      _buildNameValidationIndicator(
                                        hasInvalidChars:
                                            middleNameHasInvalidChars,
                                        isSmallScreen: isSmallScreen,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: spacing * 0.7),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildField(
                                        hint: "Surname",
                                        maxLength: 50,
                                        validator: (v) {
                                          if (v == null || v.trim().isEmpty) {
                                            return "Surname is required";
                                          }
                                          if (v.trim().length > 50) {
                                            return "Surname must be 50 characters or less";
                                          }
                                          if (hasInvalidNameCharacters(v)) {
                                            return "Only letters, spaces, hyphens, and apostrophes are allowed";
                                          }
                                          return null;
                                        },
                                        onSaved: (v) => lName = v!.trim(),
                                        onChanged: (v) {
                                          validateLastName(v);
                                        },
                                      ),
                                      _buildNameValidationIndicator(
                                        hasInvalidChars:
                                            lastNameHasInvalidChars,
                                        isSmallScreen: isSmallScreen,
                                      ),
                                    ],
                                  ),
                                ] else ...[
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _buildField(
                                              hint: "Middle Name",
                                              maxLength: 50,
                                              validator: (v) {
                                                if (v != null &&
                                                    v.trim().length > 50) {
                                                  return "Middle name must be 50 characters or less";
                                                }
                                                if (v != null &&
                                                    hasInvalidNameCharacters(
                                                      v,
                                                    )) {
                                                  return "Only letters, spaces, hyphens, and apostrophes are allowed";
                                                }
                                                return null;
                                              },
                                              onSaved: (v) => mName = v!.trim(),
                                              onChanged: (v) {
                                                validateMiddleName(v);
                                              },
                                            ),
                                            _buildNameValidationIndicator(
                                              hasInvalidChars:
                                                  middleNameHasInvalidChars,
                                              isSmallScreen: isSmallScreen,
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: spacing * 0.7),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _buildField(
                                              hint: "Surname",
                                              maxLength: 50,
                                              validator: (v) {
                                                if (v == null ||
                                                    v.trim().isEmpty) {
                                                  return "Surname is required";
                                                }
                                                if (v.trim().length > 50) {
                                                  return "Surname must be 50 characters or less";
                                                }
                                                if (hasInvalidNameCharacters(
                                                  v,
                                                )) {
                                                  return "Only letters, spaces, hyphens, and apostrophes are allowed";
                                                }
                                                return null;
                                              },
                                              onSaved: (v) => lName = v!.trim(),
                                              onChanged: (v) {
                                                validateLastName(v);
                                              },
                                            ),
                                            _buildNameValidationIndicator(
                                              hasInvalidChars:
                                                  lastNameHasInvalidChars,
                                              isSmallScreen: isSmallScreen,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                SizedBox(height: spacing * 0.7),

                                DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    hintText: "Select your Sex",
                                    hintStyle: GoogleFonts.robotoMono(
                                      fontSize: 15.3,
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: isSmallScreen ? 16 : 24,
                                      vertical: isSmallScreen ? 16 : 16,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF334E7B),
                                        width: 1,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF334E7B),
                                        width: 1,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF334E7B),
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  dropdownColor: Colors.white,
                                  style: GoogleFonts.robotoMono(
                                    fontSize: 15.3,
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
                                SizedBox(height: spacing * 0.7),

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
                                SizedBox(height: spacing * 0.7),

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
                                SizedBox(height: spacing * 0.7),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildField(
                                      hint: "Password",
                                      obscure: !showPassword,
                                      validator: (v) {
                                        if (v == null || v.isEmpty) {
                                          return "Password is required";
                                        }
                                        if (!isPasswordValid()) {
                                          return "Password must meet all requirements below";
                                        }
                                        return null;
                                      },
                                      onSaved: (v) => password = v!,
                                      onChanged: (v) {
                                        password = v;
                                        validatePassword(v);
                                        validatePasswordMatch();
                                      },
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          showPassword
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            showPassword = !showPassword;
                                          });
                                        },
                                      ),
                                    ),
                                    // Password validation indicators
                                    if (password.isNotEmpty) ...[
                                      const SizedBox(height: 8.0),
                                      _buildValidationIndicator(
                                        text: "At least 8 characters",
                                        isValid: hasMinLength,
                                        isSmallScreen: isSmallScreen,
                                      ),
                                      _buildValidationIndicator(
                                        text: "1 uppercase letter",
                                        isValid: hasUppercase,
                                        isSmallScreen: isSmallScreen,
                                      ),
                                      _buildValidationIndicator(
                                        text: "1 lowercase letter",
                                        isValid: hasLowercase,
                                        isSmallScreen: isSmallScreen,
                                      ),
                                      _buildValidationIndicator(
                                        text: "1 special character",
                                        isValid: hasSpecialChar,
                                        isSmallScreen: isSmallScreen,
                                      ),
                                    ],
                                  ],
                                ),
                                SizedBox(height: spacing * 0.7),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildField(
                                      hint: "Confirm Password",
                                      obscure: !showConfirmPassword,
                                      validator: (v) {
                                        if (v == null || v.isEmpty) {
                                          return "Please confirm your password";
                                        }
                                        if (v != password) {
                                          return "Passwords don't match";
                                        }
                                        return null;
                                      },
                                      onSaved: (v) => confirmPassword = v!,
                                      onChanged: (v) {
                                        confirmPassword = v;
                                        validatePasswordMatch();
                                      },
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          showConfirmPassword
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            showConfirmPassword =
                                                !showConfirmPassword;
                                          });
                                        },
                                      ),
                                    ),
                                    // Password match indicator
                                    _buildPasswordMatchIndicator(
                                      isSmallScreen: isSmallScreen,
                                    ),
                                  ],
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
                                    fontSize: isSmallScreen ? 20.0 : 22.0,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: isSmallScreen ? 4.0 : 8.0,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: "Enter 6-digit code",
                                    hintStyle: GoogleFonts.robotoMono(
                                      fontSize: isSmallScreen ? 16.0 : 18.0,
                                      fontWeight: FontWeight.normal,
                                      letterSpacing: isSmallScreen ? 2.0 : 4.0,
                                      color: Colors.grey[500],
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: isSmallScreen
                                          ? 8
                                          : 12, // Reduce horizontal padding
                                      vertical: isSmallScreen
                                          ? 12
                                          : 14, // Adjust vertical padding
                                    ),
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
                                  ),
                                  maxLength: 6,
                                ),
                                SizedBox(height: spacing * 1.5),

                                Center(
                                  child: TextButton(
                                    onPressed: (otpLoading || resendTimer > 0)
                                        ? null
                                        : sendOTP,
                                    child: Text(
                                      otpLoading
                                          ? "Sending..."
                                          : resendTimer > 0
                                          ? "Resend Code (${resendTimer}s)"
                                          : "Resend Code",
                                      style: GoogleFonts.robotoMono(
                                        color: (otpLoading || resendTimer > 0)
                                            ? Colors.grey
                                            : const Color(0xFF334E7B),
                                        fontSize: isSmallScreen ? 14.0 : 16.0,
                                        decoration:
                                            (otpLoading || resendTimer > 0)
                                            ? TextDecoration.none
                                            : TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: spacing * 0.7),

                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    onPressed: goBackToForm,
                                    style: OutlinedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                        vertical: buttonPadding * 1.0,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
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
                              SizedBox(height: spacing * 1.0),

                              // Terms and Privacy Policy Acceptance
                              if (!otpStep) ...[
                                Center(
                                  child: RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      style: GoogleFonts.robotoMono(
                                        fontSize: 12.0,
                                        color: Colors.grey[700],
                                        height: 1.4,
                                      ),
                                      children: [
                                        TextSpan(
                                          text:
                                              'By registering, you agree to our\n',
                                        ),
                                        WidgetSpan(
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      TermsConditionsPage(),
                                                ),
                                              );
                                            },
                                            child: Text(
                                              'Terms & Conditions',
                                              style: GoogleFonts.robotoMono(
                                                fontSize: 12.0,
                                                color: Colors.blue,
                                                decoration:
                                                    TextDecoration.underline,
                                                height: 1.4,
                                              ),
                                            ),
                                          ),
                                        ),
                                        TextSpan(text: ' and '),
                                        WidgetSpan(
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      PrivacyPolicyPage(),
                                                ),
                                              );
                                            },
                                            child: Text(
                                              'Privacy Policy',
                                              style: GoogleFonts.robotoMono(
                                                fontSize: 12.0,
                                                color: Colors.blue,
                                                decoration:
                                                    TextDecoration.underline,
                                                height: 1.4,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: spacing * 1.0),
                              ],

                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: (loading || otpLoading)
                                      ? null
                                      : _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF334E7B),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
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
                                            fontSize: 15.3,
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
