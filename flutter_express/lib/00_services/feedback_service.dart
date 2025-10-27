import 'supabase_config.dart';

class FeedbackService {
  static final _client = SupabaseConfig.client;

  // Generate unique feedback ID
  static String _generateFeedbackId() {
    return 'fb_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecondsSinceEpoch % 1000}';
  }

  // Submit feedback
  static Future<SupabaseResponse<Map<String, dynamic>>> insertFeedback({
    required String userId,
    required String email,
    required String mainConcern,
    required String details,
  }) async {
    try {
      final feedbackId = _generateFeedbackId();

      final response = await _client
          .from('tbl_feedback')
          .insert({
            'feedback_id': feedbackId,
            'user_id': userId,
            'email': email,
            'main_concern': mainConcern,
            'details': details,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return SupabaseResponse.success(
        response,
        message: 'Feedback submitted successfully',
      );
    } catch (e) {
      print('Submit feedback error: $e');
      return SupabaseResponse.error('Submit failed: ${e.toString()}');
    }
  }

  // Get all feedback (admin)
  static Future<SupabaseResponse<List<Map<String, dynamic>>>>
  getAllFeedback() async {
    try {
      final response = await _client
          .from('tbl_feedback')
          .select()
          .order('created_at', ascending: false);

      return SupabaseResponse.success(
        List<Map<String, dynamic>>.from(response),
        message: 'Feedback fetched successfully',
      );
    } catch (e) {
      print('Fetch feedback error: $e');
      return SupabaseResponse.error('Fetch failed: ${e.toString()}');
    }
  }
}
