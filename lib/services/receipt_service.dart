import 'dart:io';
import 'package:dio/dio.dart';
import '../models/receipt_model.dart';
import 'package:http_parser/http_parser.dart';

class ReceiptService {
  final Dio _dio;
  static const String baseUrl = 'http://192.168.1.171:3000/api';

  ReceiptService() : _dio = Dio() {
    _dio.options.baseUrl = baseUrl;
  }

  // ตั้งค่า token สำหรับ authentication
  void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
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