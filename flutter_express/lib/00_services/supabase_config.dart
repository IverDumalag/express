import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://mlqzqiuolmjzrctvmxfu.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1scXpxaXVvbG1qenJjdHZteGZ1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE1NTg0MzAsImV4cCI6MjA3NzEzNDQzMH0.6rAMGdYTtf7vmGyya3m-2kM3n_JHd1JH5KChcI8JeDs';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}

// Helper class for consistent response format
class SupabaseResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final String? message;

  SupabaseResponse({
    required this.success,
    this.data,
    this.error,
    this.message,
  });

  factory SupabaseResponse.success(T data, {String? message}) {
    return SupabaseResponse(
      success: true,
      data: data,
      message: message ?? 'Operation successful',
    );
  }

  factory SupabaseResponse.error(String error) {
    return SupabaseResponse(success: false, error: error);
  }
}
