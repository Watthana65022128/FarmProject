import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExpenseService {
  final Dio _dio;
  static const String baseUrl = 'http://192.168.1.171:3000/api';

  ExpenseService() : _dio = Dio() {
    _dio.options.baseUrl = baseUrl;
  }

  void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  Future<Map<String, double>> getManagementExpenses(int farmId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token == null) {
        throw Exception('กรุณาเข้าสู่ระบบใหม่');
      }

      setToken(token);

      final response = await _dio.get(
        '/farms/$farmId/management-expenses',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      final Map<String, dynamic> data = response.data;
      return {
        'equipment': (data['equipment']['total'] ?? 0).toDouble(),
        'labor': (data['labor']['total'] ?? 0).toDouble(),
        'transportation': (data['transportation']['total'] ?? 0).toDouble(),
      };
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, double>> getProductionExpenses(int farmId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token == null) {
        throw Exception('กรุณาเข้าสู่ระบบใหม่');
      }

      setToken(token);

      final response = await _dio.get(
        '/farms/$farmId/production-expenses',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      final Map<String, dynamic> data = response.data;
      return {
        'seeds': (data['seeds']['total'] ?? 0).toDouble(),
        'chemicals': (data['chemicals']['total'] ?? 0).toDouble(),
        'water': (data['water']['total'] ?? 0).toDouble(),
        'electricity': (data['electricity']['total'] ?? 0).toDouble(),
        'fertilizer': (data['fertilizer']['total'] ?? 0).toDouble(),
      };
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        final errorMessage = 
          error.response?.data['error'] ?? 'เกิดข้อผิดพลาดจากเซิร์ฟเวอร์';
        return Exception(errorMessage);
      }
      return Exception('ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้');
    }
    return Exception('เกิดข้อผิดพลาดที่ไม่ทราบสาเหตุ');
  }
}