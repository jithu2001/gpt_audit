import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import 'auth_service.dart';

class UserService {
  static const String _baseUrl = 'http://192.168.1.109:8080';
  static const String _usersEndpoint = '/api/users';

  static UserService? _instance;
  static UserService get instance => _instance ??= UserService._();

  UserService._();

  // Get all users (Admin only)
  Future<List<User>> getAllUsers() async {
    try {
      print('🔍 Fetching all users from: $_baseUrl$_usersEndpoint');

      final headers = await AuthService.instance.getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl$_usersEndpoint'),
        headers: headers,
      );

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        List<dynamic> usersJson;
        if (responseData is Map<String, dynamic> && responseData.containsKey('users')) {
          usersJson = responseData['users'] as List<dynamic>;
        } else if (responseData is List) {
          usersJson = responseData;
        } else {
          print('❌ Unexpected response format');
          return [];
        }

        final users = usersJson.map((json) => User.fromJson(json)).toList();
        print('✅ Successfully parsed ${users.length} users');
        return users;
      } else {
        print('❌ Failed to load users: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('💥 Error loading users: $e');
      return [];
    }
  }

  // Create new user (Admin only)
  Future<User?> createUser({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      print('🚀 Creating user: $email');

      final headers = await AuthService.instance.getAuthHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl$_usersEndpoint'),
        headers: headers,
        body: jsonEncode({
          'full_name': fullName,
          'email': email,
          'password': password,
          'role': role,
        }),
      );

      print('📡 Create user response status: ${response.statusCode}');
      print('📄 Create user response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final createdUser = User.fromJson(jsonDecode(response.body));
        print('✅ User created successfully: ${createdUser.email}');
        return createdUser;
      } else {
        print('❌ Failed to create user: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('💥 Error creating user: $e');
      return null;
    }
  }

  // Update user status (Admin only)
  Future<bool> updateUserStatus(int userId, String status) async {
    try {
      print('🔄 Updating user $userId status to: $status');

      final headers = await AuthService.instance.getAuthHeaders();
      final response = await http.patch(
        Uri.parse('$_baseUrl$_usersEndpoint/$userId/status'),
        headers: headers,
        body: jsonEncode({
          'status': status,
        }),
      );

      print('📡 Update status response status: ${response.statusCode}');
      print('📄 Update status response body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ User status updated successfully');
        return true;
      } else {
        print('❌ Failed to update user status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('💥 Error updating user status: $e');
      return false;
    }
  }

  // Change password (for logged-in users)
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      print('🔄 Changing password for current user');

      final headers = await AuthService.instance.getAuthHeaders();
      // print('📤 Sending to: $_baseUrl$_usersEndpoint/change-password');
      // print('📋 Request body: ${jsonEncode({
      //     'current_password': currentPassword,
      //     'new_password': newPassword,
      //     'confirm_password': confirmPassword,
      //   })}');

      final response = await http.patch(
        Uri.parse('$_baseUrl$_usersEndpoint/change-password'),
        headers: headers,
        body: jsonEncode({
          'current_password': currentPassword,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        }),
      );

      print('📡 Change password response status: ${response.statusCode}');
      print('📄 Change password response body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ Password changed successfully');
        return true;
      } else {
        print('❌ Failed to change password: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('💥 Error changing password: $e');
      return false;
    }
  }

  // Reset user password (Admin only)
  Future<bool> resetUserPassword(int userId, String newPassword) async {
    try {
      print('🔄 Resetting password for user $userId');

      final headers = await AuthService.instance.getAuthHeaders();
      final response = await http.patch(
        Uri.parse('$_baseUrl$_usersEndpoint/$userId/reset-password'),
        headers: headers,
        body: jsonEncode({
          'new_password': newPassword,
        }),
      );

      print('📡 Reset password response status: ${response.statusCode}');
      print('📄 Reset password response body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ Password reset successfully');
        return true;
      } else {
        print('❌ Failed to reset password: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('💥 Error resetting password: $e');
      return false;
    }
  }
}
