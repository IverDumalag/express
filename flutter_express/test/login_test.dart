import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

Future<void> main() async {
  print('=== Supabase Login Test ===\n');

  // Initialize Supabase
  const supabaseUrl = 'https://mlqzqiuolmjzrctvmxfu.supabase.co';
  const supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1scXpxaXVvbG1qenJjdHZteGZ1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE1NTg0MzAsImV4cCI6MjA3NzEzNDQzMH0.6rAMGdYTtf7vmGyya3m-2kM3n_JHd1JH5KChcI8JeDs';

  print('Initializing Supabase...');
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  final client = Supabase.instance.client;
  print('✓ Supabase initialized\n');

  // Test 1: Check connection
  print('--- Test 1: Database Connection ---');
  try {
    final count = await client
        .from('tbl_users')
        .select('user_id')
        .count(CountOption.exact);
    print('✓ Connection successful');
    print('  Total users in database: ${count.count}\n');
  } catch (e) {
    print('✗ Connection failed: $e\n');
    return;
  }

  // Test 2: List all users
  print('--- Test 2: List All Users ---');
  try {
    final users = await client
        .from('tbl_users')
        .select('user_id, email, f_name, l_name, role');

    if (users.isEmpty) {
      print('⚠ No users found in database');
      print('  Please create a test user first\n');
      return;
    }

    print('Found ${users.length} user(s):');
    for (var user in users) {
      print(
        '  - ${user['email']} (${user['f_name']} ${user['l_name']}) - Role: ${user['role']}',
      );
    }
    print('');

    // Test 3: Test login with first user
    print('--- Test 3: Testing Login ---');
    final testEmail = users[0]['email'];
    print('Using email: $testEmail');
    print('Enter the password for this user to test login');
    print('(Common test passwords: password123, Password123, 12345678)\n');

    final testPasswords = [
      'password123',
      'Password123',
      '12345678',
      'test1234',
      'admin123',
    ];

    for (var testPassword in testPasswords) {
      print('Trying password: $testPassword');

      // Get user from database
      final userResponse = await client
          .from('tbl_users')
          .select('user_id, email, password, role, f_name, l_name')
          .eq('email', testEmail)
          .maybeSingle();

      if (userResponse == null) {
        print('  ✗ User not found\n');
        continue;
      }

      // Hash the password
      final hashedPassword = sha256
          .convert(utf8.encode(testPassword))
          .toString();

      print('  Computed hash: $hashedPassword');
      print('  Stored hash:   ${userResponse['password']}');

      if (userResponse['password'] == hashedPassword) {
        print('  ✓ PASSWORD MATCH! Login would succeed with this password\n');
        print('--- Login Successful ---');
        print('User Details:');
        print('  ID: ${userResponse['user_id']}');
        print('  Email: ${userResponse['email']}');
        print('  Name: ${userResponse['f_name']} ${userResponse['l_name']}');
        print('  Role: ${userResponse['role']}');
        return;
      } else {
        print('  ✗ Password mismatch\n');
      }
    }

    print('⚠ None of the test passwords worked');
    print('  Please use the correct password or create a test user\n');
  } catch (e) {
    print('✗ Error: $e\n');
  }

  // Instructions for creating a test user
  print('--- How to Create a Test User ---');
  print('1. Open Supabase Dashboard: https://mlqzqiuolmjzrctvmxfu.supabase.co');
  print('2. Go to Table Editor > tbl_users');
  print('3. Insert a new row with:');
  print('   - user_id: US-0000001');
  print('   - email: test@example.com');
  print(
    '   - password: 15e2b0d3c33891ebb0f1ef609ec419420c20e320ce94c65fbc8c3312448eb225',
  );
  print('     (This is the hash for "password123")');
  print('   - f_name: Test');
  print('   - l_name: User');
  print('   - sex: male');
  print('   - birthdate: 2000-01-01');
  print('   - role: user');
  print('   - created_at: now()');
  print('   - updated_at: now()');
}
