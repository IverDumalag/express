import 'supabase_config.dart';

class PhrasesWordsService {
  static final _client = SupabaseConfig.client;

  // Generate unique entry ID
  static String _generateEntryId() {
    return 'pw_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecondsSinceEpoch % 1000}';
  }

  // Insert new phrase/word
  static Future<SupabaseResponse<Map<String, dynamic>>> insertPhrasesWords({
    required String userId,
    required String words,
    String? signLanguage,
    bool isFavorite = false,
    bool isMatch = false,
  }) async {
    try {
      final entryId = _generateEntryId();
      final now = DateTime.now().toIso8601String();

      final response = await _client
          .from('tbl_phrases_words')
          .insert({
            'entry_id': entryId,
            'user_id': userId,
            'words': words,
            'sign_language': signLanguage,
            'is_favorite': isFavorite,
            'is_match': isMatch,
            'status': 'active',
            'created_at': now,
            'updated_at': now,
          })
          .select()
          .single();

      return SupabaseResponse.success(
        response,
        message: 'Phrase/word added successfully',
      );
    } catch (e) {
      print('Insert error: $e');
      return SupabaseResponse.error('Insert failed: ${e.toString()}');
    }
  }

  // Get user's phrases/words
  static Future<SupabaseResponse<List<Map<String, dynamic>>>>
  getPhrasesWordsByUserId(String userId) async {
    try {
      final response = await _client
          .from('tbl_phrases_words')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return SupabaseResponse.success(
        List<Map<String, dynamic>>.from(response),
        message: 'Phrases/words fetched successfully',
      );
    } catch (e) {
      print('Fetch error: $e');
      return SupabaseResponse.error('Fetch failed: ${e.toString()}');
    }
  }

  // Update phrase/word status (archive/unarchive)
  static Future<SupabaseResponse<Map<String, dynamic>>>
  updatePhrasesWordsStatus({
    required String entryId,
    required String status,
  }) async {
    try {
      final response = await _client
          .from('tbl_phrases_words')
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('entry_id', entryId)
          .select()
          .single();

      return SupabaseResponse.success(
        response,
        message: 'Status updated successfully',
      );
    } catch (e) {
      print('Update status error: $e');
      return SupabaseResponse.error('Update failed: ${e.toString()}');
    }
  }

  // Update favorite status
  static Future<SupabaseResponse<Map<String, dynamic>>>
  updatePhrasesWordsFavorite({
    required String entryId,
    required bool isFavorite,
  }) async {
    try {
      final response = await _client
          .from('tbl_phrases_words')
          .update({
            'is_favorite': isFavorite,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('entry_id', entryId)
          .select()
          .single();

      return SupabaseResponse.success(
        response,
        message: 'Favorite status updated successfully',
      );
    } catch (e) {
      print('Update favorite error: $e');
      return SupabaseResponse.error('Update failed: ${e.toString()}');
    }
  }

  // Edit phrase/word
  static Future<SupabaseResponse<Map<String, dynamic>>> editPhrasesWords({
    required String entryId,
    required String words,
    String? signLanguage,
  }) async {
    try {
      final response = await _client
          .from('tbl_phrases_words')
          .update({
            'words': words,
            'sign_language': signLanguage,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('entry_id', entryId)
          .select()
          .single();

      return SupabaseResponse.success(
        response,
        message: 'Phrase/word updated successfully',
      );
    } catch (e) {
      print('Edit error: $e');
      return SupabaseResponse.error('Edit failed: ${e.toString()}');
    }
  }

  // Delete phrase/word
  static Future<SupabaseResponse<void>> deletePhrasesWords(
    String entryId,
  ) async {
    try {
      await _client.from('tbl_phrases_words').delete().eq('entry_id', entryId);

      return SupabaseResponse.success(
        null,
        message: 'Phrase/word deleted successfully',
      );
    } catch (e) {
      print('Delete error: $e');
      return SupabaseResponse.error('Delete failed: ${e.toString()}');
    }
  }
}
