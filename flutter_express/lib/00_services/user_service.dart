import 'package:bcrypt/bcrypt.dart';
import 'dart:convert';
import 'supabase_config.dart';

class UserService {
  static final _client = SupabaseConfig.client;

  // Generate unique user ID
  static Future<String> _generateUserId() async {
    try {
      final response = await _client
          .from('tbl_users')
          .select('user_id')
          .order('user_id', ascending: false)
          .limit(1);

      if (response.isNotEmpty) {
        final lastId = response[0]['user_id'] as String;
        final numberPart = int.parse(lastId.split('-')[1]);
        final nextNumber = numberPart + 1;
        return 'US-${nextNumber.toString().padLeft(7, '0')}';
      }
      return 'US-0000001';
    } catch (e) {
      print('Error generating user ID: $e');
      return 'US-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';
    }
  }

  // Hash password using bcrypt
  static String _hashPassword(String password) {
    return BCrypt.hashpw(password, BCrypt.gensalt());
  }

  // Verify password using bcrypt
  static bool _verifyPassword(String password, String hashedPassword) {
    try {
      return BCrypt.checkpw(password, hashedPassword);
    } catch (e) {
      print('Password verification error: $e');
      return false;
    }
  }

  // Register new user
  static Future<SupabaseResponse<Map<String, dynamic>>> registerUser({
    required String email,
    required String password,
    required String firstName,
    String? middleName,
    required String lastName,
    required String sex,
    required String birthdate,
  }) async {
    try {
      // Check if email exists
      final existingUser = await _client
          .from('tbl_users')
          .select('email')
          .eq('email', email)
          .maybeSingle();

      if (existingUser != null) {
        return SupabaseResponse.error('Email already registered');
      }

      // Generate user ID
      final userId = await _generateUserId();

      // Hash password
      final hashedPassword = _hashPassword(password);

      // Insert user
      final now = DateTime.now().toIso8601String();
      final response = await _client
          .from('tbl_users')
          .insert({
            'user_id': userId,
            'email': email,
            'password': hashedPassword,
            'f_name': firstName,
            'm_name': middleName,
            'l_name': lastName,
            'sex': sex,
            'birthdate': birthdate,
            'role': 'user', // Explicitly set role
            'created_at': now,
            'updated_at': now,
          })
          .select()
          .single();

      // Create log entry
      await _createLog(
        userId: userId,
        email: email,
        actionType: 'register',
        objectType: 'user',
        objectId: userId,
        newData: {'email': email, 'f_name': firstName, 'l_name': lastName},
      );

      return SupabaseResponse.success(
        response,
        message: 'User registered successfully',
      );
    } catch (e) {
      print('Registration error: $e');
      return SupabaseResponse.error('Registration failed: ${e.toString()}');
    }
  }

  // Login user
  static Future<SupabaseResponse<Map<String, dynamic>>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      print('LoginUser: Starting login attempt for email: $email');

      // Get user by email
      final response = await _client
          .from('tbl_users')
          .select()
          .eq('email', email)
          .maybeSingle();

      print('LoginUser: Database query completed');

      if (response == null) {
        print('LoginUser: No user found with email: $email');
        return SupabaseResponse.error('Invalid email or password');
      }

      print(
        'LoginUser: User found - ID: ${response['user_id']}, Role: ${response['role']}',
      );

      // Verify password using bcrypt
      final storedHash = response['password'] as String;
      print('LoginUser: Stored hash: $storedHash');
      print('LoginUser: Verifying password...');

      final passwordValid = _verifyPassword(password, storedHash);

      if (!passwordValid) {
        print('LoginUser: Password verification failed');
        return SupabaseResponse.error('Invalid email or password');
      }

      print('LoginUser: Password verified successfully');

      // Create log entry
      try {
        await _createLog(
          userId: response['user_id'],
          email: response['email'],
          actionType: 'login',
          objectType: 'user',
          objectId: response['user_id'],
        );
        print('LoginUser: Log entry created');
      } catch (logError) {
        print('LoginUser: Error creating log (non-fatal): $logError');
      }

      // Remove password from response
      final userWithoutPassword = Map<String, dynamic>.from(response);
      userWithoutPassword.remove('password');

      print('LoginUser: Login successful for user: ${response['user_id']}');
      return SupabaseResponse.success(
        userWithoutPassword,
        message: 'Login successful',
      );
    } catch (e, stackTrace) {
      print('LoginUser: ERROR - $e');
      print('LoginUser: Stack trace - $stackTrace');
      return SupabaseResponse.error('Login failed: ${e.toString()}');
    }
  }

  // Update user profile
  static Future<SupabaseResponse<Map<String, dynamic>>> updateUser({
    required String userId,
    required String email,
    required String firstName,
    String? middleName,
    required String lastName,
    required String sex,
    required String birthdate,
    String? password,
  }) async {
    try {
      final updateData = {
        'email': email,
        'f_name': firstName,
        'm_name': middleName,
        'l_name': lastName,
        'sex': sex,
        'birthdate': birthdate,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // If password is provided, hash it
      if (password != null && password.isNotEmpty) {
        updateData['password'] = _hashPassword(password);
      }

      final response = await _client
          .from('tbl_users')
          .update(updateData)
          .eq('user_id', userId)
          .select()
          .single();

      return SupabaseResponse.success(
        response,
        message: 'User updated successfully',
      );
    } catch (e) {
      print('Update error: $e');
      return SupabaseResponse.error('Update failed: ${e.toString()}');
    }
  }

  // Check if email exists
  static Future<SupabaseResponse<bool>> checkEmailExists(String email) async {
    try {
      final response = await _client
          .from('tbl_users')
          .select('user_id')
          .eq('email', email)
          .maybeSingle();

      final exists = response != null;
      return SupabaseResponse.success(
        exists,
        message: exists ? 'Email is already registered' : 'Email is available',
      );
    } catch (e) {
      print('Check email error: $e');
      return SupabaseResponse.error('Check failed: ${e.toString()}');
    }
  }

  // Helper function to create log entries
  static Future<void> _createLog({
    required String userId,
    required String email,
    required String actionType,
    String? objectType,
    String? objectId,
    Map<String, dynamic>? oldData,
    Map<String, dynamic>? newData,
  }) async {
    try {
      final logId = 'log_${DateTime.now().millisecondsSinceEpoch}';

      await _client.from('tbl_log_history').insert({
        'log_id': logId,
        'user_id': userId,
        'email': email,
        'user_role': 'user',
        'action_type': actionType,
        'object_type': objectType,
        'object_id': objectId,
        'old_data': oldData,
        'new_data': newData,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error creating log: $e');
    }
  }
}
