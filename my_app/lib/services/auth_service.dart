import 'package:flutter/foundation.dart';
import 'base_api_service.dart';
import '../models/user.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final BaseApiService _apiService = BaseApiService();
  User? _currentUser;

  User? get currentUser => _currentUser;

  Future<User> login(String email, String password) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/auth/login',
        {
          'email': email,
          'password': password,
        },
      );

      // Store the token
      final token = response['token'] as String;
      _apiService.setToken(token);

      // Parse and store user data
      final userData = response['user'] as Map<String, dynamic>;

      // Get complete user profile using the ID from login response
      final userProfile = await getUserProfile(userData['id']);
      _currentUser = userProfile;

      return _currentUser!;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Login error: $e');
      }
      throw Exception('Đăng nhập thất bại');
    }
  }

  Future<User> getUserProfile(int userId) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>('/users/$userId');

      // ✅ API trả về một object, không phải danh sách
      return User.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi lấy thông tin người dùng: $e');
      }
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
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
