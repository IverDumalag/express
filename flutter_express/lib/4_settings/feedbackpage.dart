import 'package:flutter/material.dart';
import 'package:flutter_express/global_variables.dart';
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

  final List<String> _mainConcernOptions = [
    "Word/Phrases No Match",
    "Bug Found",
    "Suggestion",
  ];

  @override
  void dispose() {
    _mainConcernController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    final user = UserSession.user;
    if (user == null) return;

    final mainConcern = _mainConcernController.text.trim();
    final details = _detailsController.text.trim();

    if (mainConcern.isEmpty || details.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please fill in all fields.',
            style: GoogleFonts.robotoMono(),
          ),
        ),
      );
      return;
    }

    setState(() => _loading = true);

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
            'Feedback submitted successfully!',
            style: GoogleFonts.robotoMono(),
          ),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message'] ?? 'Submission failed.',
            style: GoogleFonts.robotoMono(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shadowColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [

            Text(
              'Back',
              style: GoogleFonts.robotoMono(
                color: Color(0xFF334E7B),
                fontWeight: FontWeight.bold,
              ),
            ),

          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,

              child: Text(
                'Feedback',
                style: GoogleFonts.robotoMono(
                  color: Color(0xFF334E7B),
                  fontWeight: FontWeight.bold,
                  fontSize: 36,
                ),
              ),

            ),
            SizedBox(height: 28),
            Image.asset(
              'assets/images/archive.png',
              height: 150,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 12),
            Text(
              'Help us to improve',
              style: GoogleFonts.robotoMono(
                fontSize: 27,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 8),
            // Dropdown + TextField for Main Concern
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text == '') {
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

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),

                      ),
                      onEditingComplete: onEditingComplete,
                    );
                  },
              onSelected: (String selection) {
                _mainConcernController.text = selection;
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _detailsController,
              style: GoogleFonts.robotoMono(),
              decoration: InputDecoration(
                labelText: 'Details',

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),

              ),
              maxLines: 4,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : _submitFeedback,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF334E7B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 5,
                shadowColor: Colors.grey.withOpacity(0.5),
              ),
              child: _loading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 12.0,
                      ),
                      child: Text(
                        'Submit',
                        style: GoogleFonts.robotoMono(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 20.0,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
