import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/farm_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FarmService {
  final String baseUrl = 'http://10.50.10.84:3000/api';

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
