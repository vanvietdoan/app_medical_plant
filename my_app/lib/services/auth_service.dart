import 'package:flutter/foundation.dart';
import 'base_api_service.dart';
import '../models/user.dart';
import 'dart:convert';

class AuthService {
  final _apiService = BaseApiService();
  User? _currentUser;

  User? get currentUser => _currentUser;

  Future<User> login(String email, String password) async {
    if (kDebugMode) {
      debugPrint('🔄 Đang đăng nhập: $email');
    }

    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/auth/login',
        {
          'email': email,
          'password': password,
        },
      );

      final token = response['token'];
      if (token == null) {
        throw Exception('Không nhận được token');
      }
      
      // Parse JWT token
      final parts = token.split('.');
      if (parts.length != 3) {
        throw Exception('Token không hợp lệ');
      }
      
      final payload = json.decode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1])))
      );
      
      final userId = payload['id'] as int;
      final role = payload['role'] as String;
      
      if (kDebugMode) {
        debugPrint('📝 Token info - ID: $userId, Role: $role');
      }

      _apiService.setToken(token);

      // Get user details using ID
      final userProfile = await getUserProfile(userId);

      if (kDebugMode) {
        debugPrint('✅ Đăng nhập thành công: ${userProfile.fullName}');
      }

      _currentUser = userProfile;
      return userProfile;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi đăng nhập: $e');
      }
      rethrow;
    }
  }

  Future<User> getUserProfile(int userId) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>('/users/$userId');
      return User.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi lấy thông tin: $e');
      }
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    // TODO: Implement actual password reset logic
    await Future.delayed(const Duration(seconds: 1)); // Simulate API call
    if (!email.contains('@')) {
      throw Exception('Email không hợp lệ');
    }
  }

  void logout() {
    _apiService.clearToken();
    _currentUser = null;
    if (kDebugMode) {
      debugPrint('✅ Đã đăng xuất');
    }
  }
}
