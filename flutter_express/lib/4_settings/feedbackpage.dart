import 'package:flutter/material.dart';
import 'package:flutter_express/global_variables.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../00_services/api_services.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({Key? key}) : super(key: key);

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController _mainConcernController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  bool _loading = false;
  int _letterCount = 0;

  // Validation state variables
  String? _mainConcernError;
  String? _detailsError;

  final List<String> _mainConcernOptions = [
    "Word/Phrases No Match",
    "Error Found",
    "Suggestion",
  ];

  @override
  void initState() {
    super.initState();
    _detailsController.addListener(_updateLetterCount);
  }

  void _updateLetterCount() {
    final text = _detailsController.text;
    setState(() {
      _letterCount = text.replaceAll(RegExp(r'\s+'), '').length;
    });
  }

  @override
  void dispose() {
    _mainConcernController.dispose();
    _detailsController.removeListener(_updateLetterCount);
    _detailsController.dispose();
    super.dispose();
  }

  // Validation functions
  void _validateFields() {
    setState(() {
      // Validate main concern
      if (_mainConcernController.text.trim().isEmpty) {
        _mainConcernError = "Required";
      } else {
        _mainConcernError = null;
      }

      // Validate details
      if (_detailsController.text.trim().isEmpty) {
        _detailsError = "Required";
      } else {
        final letterCount = _detailsController.text
            .replaceAll(RegExp(r'\s+'), '')
            .length;
        if (letterCount > 300) {
          _detailsError = "Please limit your feedback to 300 letters";
        } else {
          _detailsError = null;
        }
      }
    });
  }

  bool _hasValidationErrors() {
    return _mainConcernError != null || _detailsError != null;
  }

  Future<void> _submitFeedback() async {
    final user = UserSession.user;
    if (user == null) return;

    // Validate fields first
    _validateFields();

    // Check if there are validation errors
    if (_hasValidationErrors()) {
      return; // Don't proceed if there are validation errors
    }

    final mainConcern = _mainConcernController.text.trim();
    final details = _detailsController.text.trim();

    setState(() => _loading = true);

    try {
      final result = await ApiService.submitFeedback(
        userId: user['user_id'].toString(),
        email: user['email'] ?? '',
        mainConcern: mainConcern,
        details: details,
      );

      setState(() => _loading = false);

      if (result['status'] == 201 || result['status'] == "201") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Thank you! Your feedback has been sent successfully.',
              style: GoogleFonts.robotoMono(),
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        String errorMessage = "We couldn't send your feedback right now.";

        if (result['status'] == 400 || result['status'] == "400") {
          errorMessage = "Please check that all fields are filled correctly.";
        } else if (result['status'] == 500 || result['status'] == "500") {
          errorMessage =
              "Our servers are temporarily busy. Please try again later.";
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage, style: GoogleFonts.robotoMono()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _loading = false);

      String errorMessage = "Unable to send feedback.";

      // Check for specific error types
      if (e.toString().contains('SocketException') ||
          e.toString().contains('TimeoutException')) {
        errorMessage = "Please check your internet connection and try again.";
      } else if (e.toString().contains('FormatException')) {
        errorMessage = "Please check your input and try again.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage, style: GoogleFonts.robotoMono()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left,
            color: Color(0xFF334E7B),
            size: 32,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Feedback',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Image.asset(
              'assets/images/archive.png',
              height: 120,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
            Text(
              'Your opinion matters, help exPress improve',
              style: GoogleFonts.robotoMono(
                fontSize: 18,
                color: const Color(0xFF334E7B),
                fontWeight: FontWeight.w900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Main Concern Dropdown/Autocomplete
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return _mainConcernOptions;
                    }
                    return _mainConcernOptions.where((String option) {
                      return option.toLowerCase().contains(
                        textEditingValue.text.toLowerCase(),
                      );
                    });
                  },
                  fieldViewBuilder:
                      (context, controller, focusNode, onEditingComplete) {
                        _mainConcernController.text = controller.text;
                        controller.addListener(() {
                          _mainConcernController.text = controller.text;
                        });
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          style: GoogleFonts.robotoMono(),
                          decoration: InputDecoration(
                            labelText: 'Main Concern',
                            labelStyle: GoogleFonts.robotoMono(
                              color: _mainConcernError != null
                                  ? Colors.red[600]
                                  : const Color(0xFF334E7B),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: _mainConcernError != null
                                    ? Colors.red[600] ?? Colors.red
                                    : const Color(0xFF334E7B),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: _mainConcernError != null
                                    ? Colors.red[600] ?? Colors.red
                                    : Colors.grey[400] ?? Colors.grey,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: _mainConcernError != null
                                    ? Colors.red[600] ?? Colors.red
                                    : const Color(0xFF334E7B),
                              ),
                            ),
                          ),
                          onEditingComplete: onEditingComplete,
                        );
                      },
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        color: const Color.fromARGB(0, 84, 26, 26),
                        child: Container(
                          width: MediaQuery.of(context).size.width - 40,
                          constraints: const BoxConstraints(maxHeight: 200),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF334E7B),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (context, index) {
                              final option = options.elementAt(index);
                              return InkWell(
                                onTap: () => onSelected(option),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                  child: Text(
                                    option,
                                    style: GoogleFonts.robotoMono(
                                      fontSize: 16,
                                      color: const Color(0xFF334E7B),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                  onSelected: (String selection) {
                    _mainConcernController.text = selection;
                  },
                ),
                if (_mainConcernError != null) ...[
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Text(
                      _mainConcernError!,
                      style: GoogleFonts.robotoMono(
                        color: Colors.red[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),

            // Details TextField with word counter
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _detailsController,
                  style: GoogleFonts.robotoMono(),
                  decoration: InputDecoration(
                    labelText: 'Details',
                    labelStyle: GoogleFonts.robotoMono(
                      color: _detailsError != null
                          ? Colors.red[600]
                          : const Color(0xFF334E7B),
                    ),
                    alignLabelWithHint: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _detailsError != null
                            ? Colors.red[600] ?? Colors.red
                            : const Color(0xFF334E7B),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _detailsError != null
                            ? Colors.red[600] ?? Colors.red
                            : Colors.grey[400] ?? Colors.grey,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _detailsError != null
                            ? Colors.red[600] ?? Colors.red
                            : const Color(0xFF334E7B),
                      ),
                    ),
                    counterText: '',
                  ),
                  maxLines: 5,
                  textAlignVertical: TextAlignVertical.top,
                  maxLength: 300,
                  inputFormatters: [LengthLimitingTextInputFormatter(300)],
                ),
                const SizedBox(height: 4),
                if (_detailsError != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Text(
                      _detailsError!,
                      style: GoogleFonts.robotoMono(
                        color: Colors.red[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '$_letterCount/300 words',
                    style: GoogleFonts.robotoMono(
                      fontSize: 12,
                      color: _letterCount > 300
                          ? Colors.red
                          : const Color(0xFF334E7B),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Submit Button
            ElevatedButton(
              onPressed: _loading ? null : _submitFeedback,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF334E7B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 5,
                shadowColor: Colors.grey.withOpacity(0.5),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'Submit',
                      style: GoogleFonts.robotoMono(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 18.0,
                      ),
                    ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
