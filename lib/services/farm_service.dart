import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/farm_model.dart';

class FarmService {
  final String baseUrl = 'http://localhost:3000/api';

  Future<bool> createFarm(FarmModel farm) async {
    final url = Uri.parse('$baseUrl/farm');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(farm.toJson()),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Error: ${response.body}');
        return false;
      }
    } catch (error) {
      print('Exception: $error');
      return false;
    }
  }
}
