import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class AuthService {
  static const String baseUrl = 'http://10.50.10.185:3000/api';

  Future<bool> register(User user) async {
    final url = Uri.parse('$baseUrl/register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('ลงทะเบียนสำเร็จ: ${response.body}');
        return true;
      } else {
        print('เกิดข้อผิดพลาดในการลงทะเบียน: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  Future<bool> login(User user) async {
    final url = Uri.parse('$baseUrl/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': user.username,
          'email': user.email,
          'password': user.password,
        }),
      );

      if (response.statusCode == 200) {
        print('เข้าสู่ระบบสำเร็จ: ${response.body}');
        return true;
      } else {
        print('เกิดข้อผิดพลาดในการเข้าสู่ระบบ: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }
}


