import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/farm_model.dart';

class FarmService {
  final String baseUrl = 'http://192.168.1.134:3000/api';

  Future<bool> createFarm(FarmModel farm) async {
    final url = Uri.parse('$baseUrl/farm');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(farm.toJson()),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true ||
            responseData.containsKey('data') ||
            responseData['message']?.contains('สำเร็จ') == true) {
          return true;
        }
      }

      print('Error response: ${response.body}');
      return false;
    } catch (e) {
      print('Exception during farm creation: $e');
      return false;
    }
  }

  Future<List<FarmModel>> getFarms() async {
    final url = Uri.parse('$baseUrl/farms');
    try {
      final response = await http.get(url);
      print('Fetching all farms');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic jsonResponse = jsonDecode(response.body);
        List<dynamic> farmList;

        if (jsonResponse is List) {
          farmList = jsonResponse;
        } else if (jsonResponse is Map) {
          farmList = jsonResponse['data'] ?? [];
        } else {
          print('Unexpected response format');
          return [];
        }

        return farmList
            .map((farm) {
              if (farm is! Map<String, dynamic>) {
                print('Invalid farm data format: $farm');
                return null;
              }
              try {
                return FarmModel.fromMap(farm);
              } catch (e) {
                print('Error parsing farm data: $e');
                return null;
              }
            })
            .where((farm) => farm != null)
            .cast<FarmModel>()
            .toList();
      } else {
        print('Failed to fetch farms. Status: ${response.statusCode}');
        print('Error response: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching farms: $e');
      print('Stack trace: ${e is Error ? e.stackTrace : null}');
      return [];
    }
  }

  Future<FarmModel?> getFarmId(int id) async {
    try {
      // แก้ไข URL endpoint ให้ถูกต้อง
      final url = Uri.parse('$baseUrl/farm/$id');
      final response = await http.get(url);

      print('Getting farm with ID: $id');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);

        // ตรวจสอบโครงสร้าง response
        if (jsonData['success'] == true && jsonData['data'] != null) {
          // ถ้า data เป็น array ให้เอาตัวแรก
          final farmData =
              jsonData['data'] is List ? jsonData['data'][0] : jsonData['data'];

          return FarmModel.fromMap(farmData);
        } else {
          print('API returned success: false or no data');
          print('Response structure: $jsonData');
          return null;
        }
      } else {
        print('Failed to get farm. Status: ${response.statusCode}');
        print('Error response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error getting farm: $e');
      print('Stack trace: ${e is Error ? e.stackTrace : null}');
      return null;
    }
  }

  Future<bool> removeFarm(int id) async {
    try {
      final url = Uri.parse('$baseUrl/farm/$id');
      final response = await http.delete(url);

      print('Deleting farm with ID: $id');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        return jsonData['success'] == true;
      } else {
        print('Failed to delete farm. Status: ${response.statusCode}');
        print('Error response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error deleting farm: $e');
      print('Stack trace: ${e is Error ? e.stackTrace : null}');
      return false;
    }
  }
}
