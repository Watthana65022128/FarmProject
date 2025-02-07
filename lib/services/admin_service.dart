import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminService {
  static const String baseUrl = 'http://192.168.1.171:3000/api';

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<List<User>> getAllUsers() async {
    try {
      final token = await getToken();
      if (token == null) throw Exception('ไม่พบ token');

      final response = await http.get(
        Uri.parse('$baseUrl/admin/users'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final users = (data['users'] as List)
            .map((user) => User.fromJson(user))
            .toList();
        return users;
      } else {
        throw Exception('เกิดข้อผิดพลาดในการดึงข้อมูลผู้ใช้');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<bool> banUser(int userId, String reason) async {
    try {
      final token = await getToken();
      if (token == null) throw Exception('ไม่พบ token');

      final response = await http.post(
        Uri.parse('$baseUrl/admin/users/ban'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'userId': userId,
          'reason': reason,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<bool> unbanUser(int userId) async {
    try {
      final token = await getToken();
      if (token == null) throw Exception('ไม่พบ token');

      final response = await http.post(
        Uri.parse('$baseUrl/admin/users/unban'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'userId': userId,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}