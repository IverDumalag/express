import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<Map<String, dynamic>> restoreCard({
    required String entryId,
  }) async {
    // Restore by updating status to 'active'
    return await updateStatus(entryId: entryId, status: 'active');
  }

  static const String baseUrl = 'https://express-php.onrender.com/api';

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/userLogin.php');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fName,
    String? mName,
    required String lName,
    required String sex,
    required String birthdate,
  }) async {
    final url = Uri.parse('$baseUrl/userInsert.php');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'f_name': fName,
        'm_name': mName ?? '',
        'l_name': lName,
        'sex': sex,
        'birthdate': birthdate,
        'role': 'user',
      }),
    );
    return jsonDecode(response.body);
  }

  static const String trySearchUrl =
      'https://express-nodejs-nc12.onrender.com/api/search';

  static Future<List<Map<String, dynamic>>> fetchCards(String userId) async {
    final url = Uri.parse('$baseUrl/phrasesWordsByIdGet.php?user_id=$userId');
    final res = await http.get(url);
    final json = jsonDecode(res.body);
    if (json['data'] is List) {
      return List<Map<String, dynamic>>.from(json['data']);
    }
    return [];
  }

  static Future<Map<String, dynamic>?> trySearch(String query) async {
    final res = await http.get(
      Uri.parse('$trySearchUrl?q=${Uri.encodeComponent(query)}'),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> addCard({
    required String userId,
    required String words,
    required String signLanguageUrl,
    required int isMatch,
  }) async {
    final url = Uri.parse('$baseUrl/phrasesWordsInsert.php');
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'words': words,
        'sign_language': signLanguageUrl,
        'is_match': isMatch,
      }),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> updateStatus({
    required String entryId,
    required String status,
  }) async {
    final url = Uri.parse('$baseUrl/phrasesWordsStatusUpdate.php');
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'entry_id': entryId, 'status': status}),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> updateFavoriteStatus({
    required String entryId,
    required int isFavorite,
  }) async {
    final url = Uri.parse('$baseUrl/phrasesWordsIsFavoriteUpdate.php');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'entry_id': entryId, 'is_favorite': isFavorite}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> editCard({
    required String entryId,
    required String words,
    String signLanguage = '',
  }) async {
    final url = Uri.parse('$baseUrl/phrasesWordsEdit.php');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'entry_id': entryId,
        'words': words,
        'sign_language': signLanguage,
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<List<Map<String, dynamic>>> fetchAudioPhrases(
    String userId,
  ) async {
    final url = Uri.parse(
      '$baseUrl/audioPhrasesWordsByIdGet.php?user_id=$userId',
    );
    final res = await http.get(url);
    final json = jsonDecode(res.body);
    if (json['data'] is List) {
      return List<Map<String, dynamic>>.from(json['data']);
    }
    return [];
  }

  static Future<Map<String, dynamic>> insertAudioPhrase({
    required String userId,
    required String words,
    required String signLanguage,
    required int isMatch,
  }) async {
    final url = Uri.parse('$baseUrl/audioPhrasesWordsInsert.php');
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'words': words,
        'sign_language': signLanguage,
        'is_match': isMatch,
      }),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> deleteAudioPhrase({
    required String userId,
  }) async {
    final url = Uri.parse('$baseUrl/audioPhrasesWordsDeleteById.php');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> editUser({
    required String userId,
    required String email,
    required String fName,
    required String mName,
    required String lName,
    required String sex,
    required String birthdate,
    String? password,
  }) async {
    final url = Uri.parse('$baseUrl/userEdit.php');
    final body = {
      'user_id': userId,
      'email': email,
      'f_name': fName,
      'm_name': mName,
      'l_name': lName,
      'sex': sex,
      'birthdate': birthdate,
    };
    if (password != null && password.isNotEmpty) {
      body['password'] = password;
    }
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> submitFeedback({
    required String userId,
    required String email,
    required String mainConcern,
    required String details,
  }) async {
    final url = Uri.parse('$baseUrl/feedbackInsert.php');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'email': email,
        'main_concern': mainConcern,
        'details': details,
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> deleteCard({
    required String entryId,
  }) async {
    final url = Uri.parse('$baseUrl/phrasesWordsDelete.php');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'entry_id': entryId}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> wakephp() async {
    final url = Uri.parse('$baseUrl/wake.php');
    final response = await http.get(url);
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> wakenodejs() async {
    final url = Uri.parse('https://express-nodejs-nc12.onrender.com/wake');
    final response = await http.get(url);
    return jsonDecode(response.body);
  }

  static Future<void> wakeAllServices() async {
    try {
      // Wake both services simultaneously
      await Future.wait([wakephp(), wakenodejs()]);
    } catch (e) {
      // Silently handle wake errors to not disrupt app startup
      print('Wake services error: $e');
    }
  }

  static Future<bool> checkEmailExists(String email) async {
    try {
      final url = Uri.parse('$baseUrl/users.php');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> users = jsonDecode(response.body);

        // Check if any user has the same email
        for (var user in users) {
          if (user['email']?.toString().toLowerCase() == email.toLowerCase()) {
            return true;
          }
        }
        return false;
      } else {
        throw Exception('Failed to fetch users');
      }
    } catch (e) {
      throw Exception('Error checking email: $e');
    }
  }
}
