import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static const String baseUrl = 'http://192.168.1.171:3000/api';

  // ฟังก์ชันสำหรับการลงทะเบียน
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
                'email': user.email,
                'password': user.password,
            }),
        );

        if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            final token = data['token'];
            final userData = data['user'];

            // บันทึกข้อมูลทั้งหมดที่จำเป็น
            final prefs = await SharedPreferences.getInstance();
            
            // เก็บ token
            await prefs.setString('jwt_token', token);
            
            // เก็บสถานะ admin
            await prefs.setBool('isAdmin', userData['isAdmin'] ?? false);
            
            // เก็บข้อมูลผู้ใช้
            await prefs.setString('userId', userData['id'].toString());
            await prefs.setString('username', userData['username']);
            await prefs.setString('email', userData['email']);
            
            // เช็คสถานะการแบน
            if (userData['isBanned'] == true) {
                final banInfo = {
                    'reason': userData['bannedReason'] ?? 'ไม่ระบุเหตุผล',
                    'bannedAt': userData['bannedAt'],
                };
                throw Exception('บัญชีถูกระงับการใช้งาน: ${jsonEncode(banInfo)}');
            }

            print('Login successful: ${userData['username']}');
            print('Is Admin: ${userData['isAdmin']}');
            
            return true;
        } else {
            final error = jsonDecode(response.body);
            print('Login failed: ${error['error']}');
            throw Exception(error['error'] ?? 'เข้าสู่ระบบไม่สำเร็จ');
        }
    } catch (e) {
        print('Login error: $e');
        throw Exception(e.toString());
    }
}

  // ฟังก์ชันดึงข้อมูลโปรไฟล์
  Future<User?> getUserProfile() async {
    final token = await getToken();

    if (token == null) {
      print('No token found. Please log in.');
      return null;
    }

    final url = Uri.parse('$baseUrl/user/profile');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      if (response.statusCode == 200) {
        // แปลงข้อมูลที่ได้รับเป็น User object
        final data = jsonDecode(response.body);
        print('ดึงข้อมูลโปรไฟล์สำเร็จ: $data');
        final userData = data['user'] ?? data;
        return User.fromJson(userData);
      } else {
        print('เกิดข้อผิดพลาดในการดึงข้อมูลโปรไฟล์: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  // Add this method to the AuthService class
  Future<User?> updateUserProfile(User updatedUser) async {
    // ดึง token จาก SharedPreferences
    final token = await getToken();

    if (token == null) {
      print('No token found. Please log in.');
      return null;
    }

    final url = Uri.parse('$baseUrl/user/profile');
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(updatedUser.toJson()),
      );

      if (response.statusCode == 200) {
        // แปลงข้อมูลที่ได้รับเป็น User object
        final data = jsonDecode(response.body);
        print('อัพเดทโปรไฟล์สำเร็จ: $data');

        // ตรวจสอบว่ามี key 'user' หรือไม่
        final userData = data['user'] ?? data;
        return User.fromJson(userData);
      } else {
        print('เกิดข้อผิดพลาดในการอัพเดทโปรไฟล์: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  // ฟังก์ชันเก็บ token ใน SharedPreferences
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  // ฟังก์ชันดึง token จาก SharedPreferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // ฟังก์ชันสำหรับการออกจากระบบ (ลบ token)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  // เพิ่มฟังก์ชันเช็ค token
  Future<bool> isValidToken() async {
    final token = await getToken();
    print('Checking token: $token');
    return token != null && token.isNotEmpty;
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
        'userId': prefs.getString('userId'),
        'username': prefs.getString('username'),
        'email': prefs.getString('email'),
        'isAdmin': prefs.getBool('isAdmin') ?? false,
    };
}
}
