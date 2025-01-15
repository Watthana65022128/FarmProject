import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/receipt_service.dart';
import '../models/receipt_model.dart';
import 'edit_receipt.dart';
import '../auth/auth_service.dart';

class ScanPage extends StatefulWidget {
  final int farmId;
  const ScanPage({super.key, required this.farmId});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;
  final ReceiptService _receiptService = ReceiptService();
  final AuthService _authService = AuthService();

  Future<void> _checkPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.storage,
    ].request();

    if (statuses[Permission.camera]!.isDenied ||
        statuses[Permission.storage]!.isDenied) {
      // Handle permission denied
    }
  }

  Future<void> _initializeService() async {
    // ดึง token จาก AuthService และตั้งค่าให้ ReceiptService
    final token = await _authService.getToken();
    print('Token in ScanPage: $token');
    if (token != null) {
      _receiptService.setToken(token);
      print('Token set in ReceiptService');
    } else {
      // จัดการกรณีไม่มี token
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('กรุณาเข้าสู่ระบบใหม่'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context); // กลับไปหน้าก่อนหน้า
      }
    }
  }

  Future<void> _getImage(ImageSource source) async {
    await _checkPermissions();

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _image = File(image.path);
          _isProcessing = true;
        });

        await _scanReceipt();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
        );
      }
    }
  }

  Future<void> _scanReceipt() async {
   if (_image == null) return;

   try {
       // เช็ค token ก่อนส่งรูป
       final token = await _authService.getToken();
       print('Token before scan: $token');  // ดู token ที่ได้

       if (token == null || token.isEmpty) {
           throw Exception('กรุณาเข้าสู่ระบบใหม่');
       }

       // ตั้งค่า token ให้ ReceiptService
       _receiptService.setToken(token);

       final result = await _receiptService.scanReceipt(
           _image!,
           widget.farmId,
       );

       setState(() {
           _isProcessing = false;
       });

       if (context.mounted) {
           // ไปหน้าแก้ไขพร้อมส่งข้อมูลที่ได้จาก OCR
           final Receipt? updatedReceipt = await Navigator.push(
               context,
               MaterialPageRoute(
                   builder: (context) => EditReceiptPage(
                       receipt: result['receipt'] as Receipt,
                       imagePath: result['imagePath'] as String,
                       farmId: widget.farmId,
                   ),
               ),
           );

           // ถ้าบันทึกสำเร็จ กลับไปหน้าก่อนหน้าพร้อมส่งข้อมูลใบเสร็จกลับไป
           if (updatedReceipt != null && context.mounted) {
               Navigator.pop(context, updatedReceipt);
           }
       }
   } catch (e) {
       setState(() {
           _isProcessing = false;
       });
       if (context.mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(
                   content: Text(e.toString()),
                   backgroundColor: Colors.red,
               ),
           );
       }
   }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('สแกนบิล'),
        centerTitle: true,
        backgroundColor: const Color(0xFFF3FCEE),
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_image != null) ...[
              Image.file(
                _image!,
                height: 600,
                width: 400,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 20),
            ],
            if (_image == null)
              const Icon(
                Icons.camera_alt,
                size: 100,
                color: Colors.grey,
              ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _isProcessing
                      ? null
                      : () => _getImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('ถ่ายภาพ'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: _isProcessing
                      ? null
                      : () => _getImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('เลือกจากแกลเลอรี่'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_isProcessing)
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
          ],
        ),
      ),
    );
  }
}
