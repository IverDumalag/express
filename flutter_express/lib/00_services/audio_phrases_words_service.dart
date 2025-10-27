import 'supabase_config.dart';

class AudioPhrasesWordsService {
  static final _client = SupabaseConfig.client;

  // Generate unique entry ID
  static String _generateEntryId() {
    return 'apw_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecondsSinceEpoch % 1000}';
  }

  // Insert new audio phrase/word
  static Future<SupabaseResponse<Map<String, dynamic>>>
  insertAudioPhrasesWords({
    required String userId,
    required String words,
    String? signLanguage,
    bool isMatch = false,
  }) async {
    try {
      final entryId = _generateEntryId();
      final now = DateTime.now().toIso8601String();

      final response = await _client
          .from('tbl_audiotext_phrases_words')
          .insert({
            'entry_id': entryId,
            'user_id': userId,
            'words': words,
            'sign_language': signLanguage ?? '',
            'is_match': isMatch,
            'created_at': now,
            'updated_at': now,
          })
          .select()
          .single();

      return SupabaseResponse.success(
        response,
        message: 'Audio phrase added successfully',
      );
    } catch (e) {
      print('Insert audio error: $e');
      return SupabaseResponse.error('Insert failed: ${e.toString()}');
    }
  }

  // Get user's audio phrases/words
  static Future<SupabaseResponse<List<Map<String, dynamic>>>>
  getAudioPhrasesWordsByUserId(String userId) async {
    try {
      final response = await _client
          .from('tbl_audiotext_phrases_words')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return SupabaseResponse.success(
        List<Map<String, dynamic>>.from(response),
        message: 'Audio phrases/words fetched successfully',
      );
    } catch (e) {
      print('Fetch audio error: $e');
      return SupabaseResponse.error('Fetch failed: ${e.toString()}');
    }
  }

  // Delete all audio phrases/words for user
  static Future<SupabaseResponse<void>> deleteAudioPhrasesWordsByUserId(
    String userId,
  ) async {
    try {
      await _client
          .from('tbl_audiotext_phrases_words')
          .delete()
          .eq('user_id', userId);

      return SupabaseResponse.success(
        null,
        message: 'All audio phrases/words deleted successfully',
      );
    } catch (e) {
      print('Delete audio error: $e');
      return SupabaseResponse.error('Delete failed: ${e.toString()}');
    }
  }
}
