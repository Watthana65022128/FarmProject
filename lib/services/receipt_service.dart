import 'dart:io';
import 'package:dio/dio.dart';
import '../models/receipt_model.dart';
import 'package:http_parser/http_parser.dart';

class ReceiptService {
  final Dio _dio;
  static const String baseUrl = 'http://10.50.10.11:3000/api';

  ReceiptService() : _dio = Dio() {
    _dio.options.baseUrl = baseUrl;
  }

  // ตั้งค่า token สำหรับ authentication
  void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  Future<List<Receipt>> getReceipts({
    required int farmId,
    required String dateFilter,
  }) async {
    try {
      // คำนวณช่วงวันที่
      final now = DateTime.now();
      DateTime startDate;
      final endDate = now;

      switch (dateFilter) {
        case 'today':
          startDate = DateTime(now.year, now.month, now.day);
          break;
        case 'week':
          startDate = now.subtract(Duration(days: now.weekday - 1));
          break;
        case 'month':
          startDate = DateTime(now.year, now.month - 1, now.day);
          break;
        case 'threeMonths':
          startDate = DateTime(now.year, now.month - 3, now.day);
          break;
        case 'sixMonths':
          startDate = DateTime(now.year, now.month - 6, now.day);
          break;
        default:
          startDate = DateTime(now.year, now.month, now.day);
      }

      final response = await _dio.get(
        '/receipts',
        queryParameters: {
          'farmId': farmId,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['receipts'] != null && data['receipts'] is List) {
          return (data['receipts'] as List)
              .map((json) => Receipt.fromJson(json))
              .toList();
        }
      }
      
      return [];
    } catch (e) {
      print('Error fetching receipts: $e');
      throw Exception('ไม่สามารถดึงข้อมูลใบเสร็จได้');
    }
  }

  // สแกนใบเสร็จ
  Future<Map<String, dynamic>> scanReceipt(File image, int farmId) async {
    try {
      String fileName = image.path.split('/').last;
      print('Sending file: $fileName');

      FormData formData = FormData.fromMap({
        'receipt': await MultipartFile.fromFile( 
          image.path,
          filename: fileName,
          contentType: MediaType('image', 'jpeg'),
        ),
        'farmId': farmId.toString(),
      });

      print('Headers: ${_dio.options.headers}'); 
      print('FormData: ${formData.fields}'); 

      final response = await _dio.post(
        '/receipts/scan',
        data: formData,
        options: Options(
          headers: {
            'Authorization': _dio.options.headers['Authorization'],
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      return {
        'receipt': Receipt.fromJson(response.data['receipt']),
        'imagePath': response.data['imagePath'],
      };
    } catch (e) {
      print('Upload error: $e'); // debug log
      throw _handleError(e);
    }
}
  // บันทึกใบเสร็จ
  Future<Receipt> createReceipt({
    required String shopName,
    required DateTime receiptDate,
    required double totalAmount,
    required List<ReceiptItem> items,
    required int farmId,
    required String imagePath,
    required String token, 
  }) async {
    try {
      final response = await _dio.post(
        '/receipts',
        data: {
          'farmId': farmId,
          'shopName': shopName,
          'receiptDate': receiptDate.toIso8601String(),
          'totalAmount': totalAmount,
          'items': items.map((item) => item.toJson()).toList(),
          'imagePath': imagePath,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token', // เพิ่ม token ใน headers
            'Content-Type': 'application/json',
          },
        ),
      );

      return Receipt.fromJson(response.data['receipt']);
    } catch (e) {
      throw _handleError(e);
    }
  }


  // ลบใบเสร็จ
  Future<void> deleteReceipt(int id) async {
    try {
      await _dio.delete('/receipts/$id');
    } catch (e) {
      throw _handleError(e);
    }
  }

  // จัดการ error
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