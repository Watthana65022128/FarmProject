import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/farm_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FarmService {
  final String baseUrl = 'http://192.168.1.171:3000/api';

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<bool> updateBudget(int farmId, double budget) async {
    final url = Uri.parse('$baseUrl/farm/budget');
    
    final String? token = await getToken();
    if (token == null || token.isEmpty) {
      print('Error: ไม่พบ token กรุณา login ใหม่');
      return false;
    }

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'farmId': farmId,
          'budget': budget,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['message']?.contains('สำเร็จ') == true;
      }

      print('Error response: ${response.body}');
      return false;
    } catch (e) {
      print('Error updating budget: $e');
      return false;
    }
  }

  Future<bool> createFarm(FarmModel farm, [String? providedToken]) async {
  final url = Uri.parse('$baseUrl/farm');

  String? token = providedToken;
  if (token == null) {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('jwt_token');
  }

  if (token == null) {
    print('Error: ไม่พบ token กรุณา login ใหม่');
    return false;
  }

  try {
    print('Sending farm data: ${farm.toJson()}'); // เพิ่ม log

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(farm.toJson()),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = json.decode(response.body);
      
      // ตรวจสอบข้อมูลที่ได้รับกลับมา
      print('Response data: $responseData');
      
      if (responseData['data'] != null) {
        // สร้าง FarmModel จากข้อมูลที่ได้รับกลับมา
        try {
          FarmModel newFarm = FarmModel.fromJson(responseData['data']);
          print('Created new farm: $newFarm');
          return true;
        } catch (e) {
          print('Error parsing farm data: $e');
          return false;
        }
      }
      
      return responseData['message']?.contains('สำเร็จ') == true;
    }

    print('Farm creation failed. Status: ${response.statusCode}');
    print('Error response: ${response.body}');
    return false;
  } catch (e) {
    print('Error creating farm: $e');
    if (e is FormatException) {
      print('Format error details: ${e.message}');
    }
    return false;
  }
}

  Future<List<FarmModel>> getFarms([String? providedToken]) async {
    final url = Uri.parse('$baseUrl/farms');

    String? token = providedToken;
    if (token == null) {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('jwt_token');
    }

    if (token == null) {
      print('Error: ไม่พบ token กรุณา login ใหม่');
      return [];
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Fetching all farms');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic jsonResponse = jsonDecode(response.body);
        List<dynamic> farmList;

        if (jsonResponse is List) {
          farmList = jsonResponse;
        } else if (jsonResponse is Map) {
          if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
            farmList = jsonResponse['data'];
          } else {
            print('API returned success: false or no data');
            return [];
          }
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
                return FarmModel.fromJson(farm);
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

  Future<bool> removeFarm(int id, [String? providedToken]) async {
    try {
      final url = Uri.parse('$baseUrl/farm/$id');

      String? token = providedToken;
      if (token == null) {
        final prefs = await SharedPreferences.getInstance();
        token = prefs.getString('jwt_token');
      }

      if (token == null) {
        print('Error: ไม่พบ token กรุณา login ใหม่');
        return false;
      }

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Deleting farm with ID: $id');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);

        if (jsonData['success'] == true ||
            jsonData.containsKey('data') ||
            jsonData['message']?.contains('สำเร็จ') == true) {
          return true;
        }

        print('Error response: ${response.body}');
        return false;
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

