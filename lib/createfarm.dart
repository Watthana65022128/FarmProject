import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'fram_list.dart';
import 'profile.dart';

class Createfarm extends StatefulWidget {
  const Createfarm({super.key});

  @override
  _CreatefarmState createState() => _CreatefarmState();
}

class _CreatefarmState extends State<Createfarm> {
  String? _startMonth;
  String? _endMonth;
  final TextEditingController _name = TextEditingController();
  bool _isLoading = false; // เพิ่มตัวแปรสำหรับแสดง loading state

  final List<String> months = [
    'มกราคม',
    'กุมภาพันธ์',
    'มีนาคม',
    'เมษายน',
    'พฤษภาคม',
    'มิถุนายน',
    'กรกฎาคม',
    'สิงหาคม',
    'กันยายน',
    'ตุลาคม',
    'พฤศจิกายน',
    'ธันวาคม',
  ];

  // แสดง SnackBar แบบ custom
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ตรวจสอบความถูกต้องของข้อมูล
  bool _validateInputs() {
    if (_name.text.isEmpty) {
      _showSnackBar('กรุณากรอกชื่อไร่', isError: true);
      return false;
    }
    if (_startMonth == null) {
      _showSnackBar('กรุณาเลือกเดือนเริ่มต้น', isError: true);
      return false;
    }
    if (_endMonth == null) {
      _showSnackBar('กรุณาเลือกเดือนสิ้นสุด', isError: true);
      return false;
    }
    return true;
  }

  Future<void> _saveFarmData() async {
    if (!_validateInputs()) return;

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('http://localhost:3000/api/farm');
    final payload = {
      'name': _name.text,
      'startMonth': _startMonth,
      'endMonth': _endMonth,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        _showSnackBar('บันทึกข้อมูลไร่ "${responseData['name']}" สำเร็จ');

        // เคลียร์ฟอร์ม
        _clearForm();

        // นำผู้ใช้ไปยังหน้ารายการไร่
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const FarmList()),
          );
        }
      } else {
        final errorData = json.decode(response.body);
        _showSnackBar(errorData['error'] ?? 'เกิดข้อผิดพลาดในการบันทึกข้อมูล',
            isError: true);
      }
    } catch (e) {
      _showSnackBar('ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearForm() {
    _name.clear();
    setState(() {
      _startMonth = null;
      _endMonth = null;
    });
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('สร้างไร่'),
        centerTitle: true,
        backgroundColor: const Color(0xFFF3FCEE),
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                color: Colors.black,
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const ProfilePage(), // สร้างหน้า ProfilePage
                ),
              );
            },
          ),
          const SizedBox(width: 10), // เพิ่มระยะห่างจากขอบ
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20,
              ),
              Image.asset(
                'assets/logo.png',
                height: 120,
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _name,
                        decoration: const InputDecoration(
                          labelText: 'ชื่อไร่',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.agriculture),
                        ),
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: _startMonth,
                        decoration: const InputDecoration(
                          labelText: 'เดือนเริ่มต้น',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        items: months.map((String month) {
                          return DropdownMenuItem<String>(
                            value: month,
                            child: Text(month),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _startMonth = newValue;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: _endMonth,
                        decoration: const InputDecoration(
                          labelText: 'เดือนสิ้นสุด',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        items: months.map((String month) {
                          return DropdownMenuItem<String>(
                            value: month,
                            child: Text(month),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _endMonth = newValue;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveFarmData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'เพิ่มไร่',
                          style: TextStyle(fontSize: 18),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.green[50],
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const FarmList()),
                  );
                },
                icon: const Icon(Icons.list),
                label: const Text('ดูรายการไร่ทั้งหมด'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
