import 'package:flutter/foundation.dart';
import '../models/family.dart';
import 'base_api_service.dart';

class FamilyService {
  static final FamilyService _instance = FamilyService._internal();
  factory FamilyService() => _instance;
  FamilyService._internal();

  final BaseApiService _apiService = BaseApiService();

  Future<List<Family>> getFamilies({int page = 1, int limit = 10}) async {
    try {
      if (kDebugMode) {
        debugPrint('Fetching families with page=$page, limit=$limit');
      }

      final response = await _apiService.get<dynamic>(
        '/families?page=$page&limit=$limit',
      );

      if (kDebugMode) {
        debugPrint('Raw family response: $response');
        debugPrint('Response type: ${response.runtimeType}');
      }

      List<dynamic> familiesJson;
      if (response is List<dynamic>) {
        familiesJson = response;
      } else {
        throw Exception('Unexpected response type: ${response.runtimeType}');
      }

      if (kDebugMode) {
        debugPrint('Processed families: ${familiesJson.length} items');
      }

      return familiesJson.map((json) => Family.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error fetching families: $e');
        debugPrint('Stack trace: ${StackTrace.current}');
      }
      rethrow;
    }
  }

  Future<Family> getFamilyById(int id) async {
    try {
      if (kDebugMode) {
        debugPrint('Fetching family with id: $id');
      }

      final response = await _apiService.get<dynamic>('/families/$id');

      if (kDebugMode) {
        debugPrint('Raw family detail response: $response');
        debugPrint('Response type: ${response.runtimeType}');
      }

      if (response is Map<String, dynamic>) {
        return Family.fromJson(response);
      } else {
        throw Exception('Unexpected response type: ${response.runtimeType}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error fetching family detail: $e');
        debugPrint('Stack trace: ${StackTrace.current}');
      }
      rethrow;
    }
  }
}
