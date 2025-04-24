import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart' as dio;
import '../models/user.dart';
import 'base_api_service.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final BaseApiService _apiService = BaseApiService();
  final _dio = dio.Dio();

  /// Get user profile by ID
  Future<User> getUserProfile(int userId) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>('/users/$userId');
      return User.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ $e.toString()');
      }
      rethrow;
    }
  }

  /// Update user profile
  Future<Map<String, dynamic>> updateUserProfile(int userId, Map<String, dynamic> userData) async {
    try {
      final response = await _apiService.put<Map<String, dynamic>>(
        '/users/$userId',
        userData,
      );
      return response;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi cập nhật thông tin người dùng: $e');
      }
      rethrow;
    }
  }

  /// Get users list with pagination
  Future<List<User>> getUsers({int page = 1, int limit = 10}) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '/users?page=$page&limit=$limit',
      );
      final List<dynamic> usersJson = response['data'] as List<dynamic>;
      return usersJson.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi lấy danh sách người dùng: $e');
      }
      rethrow;
    }
  }

  /// Search users
  Future<List<User>> searchUsers(String query, {int page = 1, int limit = 10}) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '/users/search?q=$query&page=$page&limit=$limit',
      );
      final List<dynamic> usersJson = response['data'] as List<dynamic>;
      return usersJson.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi tìm kiếm người dùng: $e');
      }
      rethrow;
    }
  }

  /// Change user password
  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      await _apiService.post<Map<String, dynamic>>(
        '/auth/change-password',
        {
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi đổi mật khẩu: $e');
      }
      
      // Check if the error is due to invalid old password
      if (e.toString().contains('Invalid old password')) {
        throw Exception('Mật khẩu hiện tại không đúng');
      }
      
      rethrow;
    }
  }

  /// Forgot password
  Future<void> forgotPassword(String email) async {
    try {
      await _apiService.post<Map<String, dynamic>>(
        '/auth/forgot-password',
        {
          'email': email,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi quên mật khẩu: $e');
      }
      rethrow;
    }
  }

  /// Upload avatar image
  Future<Map<String, dynamic>> uploadAvatar(String filePath) async {
    try {
      final formData = dio.FormData.fromMap({
        'file': await dio.MultipartFile.fromFile(filePath),
      });

      final response = await _dio.post<Map<String, dynamic>>(
        '${BaseApiService.baseUrl}/upload/avatar',
        data: formData,
      );

      return response.data ?? {};
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi tải lên ảnh đại diện: $e');
      }
      rethrow;
    }
  }

  /// Upload proof document
  Future<Map<String, dynamic>> uploadProof(String filePath) async {
    try {
      final formData = dio.FormData.fromMap({
        'file': await dio.MultipartFile.fromFile(filePath),
      });

      final response = await _dio.post<Map<String, dynamic>>(
        '${BaseApiService.baseUrl}/upload/proof',
        data: formData,
      );

      return response.data ?? {};
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi tải lên giấy tờ chứng minh: $e');
      }
      rethrow;
    }
  }
} 