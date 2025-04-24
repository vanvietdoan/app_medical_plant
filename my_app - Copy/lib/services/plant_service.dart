import 'package:flutter/foundation.dart';
import '../models/plant.dart';
import 'base_api_service.dart';

class PlantService {
  static final PlantService _instance = PlantService._internal();
  factory PlantService() => _instance;
  PlantService._internal();

  final BaseApiService _apiService = BaseApiService();

  /// Get plant by ID
  Future<Plant> getPlantById(int id) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>('/plants/$id');
      return Plant.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi lấy thông tin cây: $e');
      }
      rethrow;
    }
  }

  /// Get list of plants
  Future<List<Plant>> getPlants({int page = 1, int limit = 10}) async {
    try {
      final response = await _apiService.get<List<dynamic>>(
        '/plants?page=$page&limit=$limit',
      );

      return response.map((e) => Plant.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi lấy danh sách cây: $e');
      }
      rethrow;
    }
  }

  /// Search plants
  Future<List<Plant>> searchPlants(String query, {int page = 1, int limit = 10}) async {
    try {
      final response = await _apiService.get<List<dynamic>>(
        '/plants/search?q=$query&page=$page&limit=$limit',
      );

      return response.map((e) => Plant.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi tìm kiếm cây: $e');
      }
      rethrow;
    }
  }


  
  


}