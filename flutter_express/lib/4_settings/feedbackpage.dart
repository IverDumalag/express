import 'package:flutter/material.dart';
import 'package:flutter_express/global_variables.dart';
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please fill in all fields.')));
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
        SnackBar(content: Text('Feedback submitted successfully!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Submission failed.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Back',
              style: TextStyle(
                fontFamily: 'RobotoMono',
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
        backgroundColor: Colors.white,
        centerTitle: false,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Feedback',
                style: TextStyle(
                  color: Color(0xFF334E7B),
                  fontWeight: FontWeight.bold,
                  fontSize: 36,
                  fontFamily: 'RobotoMono',
                ),
              ),
            ),
            SizedBox(height: 28),
            Image.asset(
              'assets/images/smiley.png',
              height: 120,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 32),
            Text(
              'Help us to improve',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontFamily: 'RobotoMono',
                fontSize: 27,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 16),
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
                      decoration: InputDecoration(
                        labelText: 'Main Concern',
                        border: OutlineInputBorder(),
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
              decoration: InputDecoration(
                labelText: 'Details',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : _submitFeedback,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF334E7B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
                elevation: 5,
                shadowColor: Colors.grey.withOpacity(0.5),
              ),
              child: _loading
                  ? CircularProgressIndicator(color: Colors.white)
                  : const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 12.0,
                      ),
                      child: Text(
                        'Submit',
                        style: TextStyle(
                          fontFamily: 'RobotoMono',
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
