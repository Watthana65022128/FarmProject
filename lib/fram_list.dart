import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'createfarm.dart';

class FarmList extends StatefulWidget {
  const FarmList({super.key});

  @override
  _FarmListState createState() => _FarmListState();
}

class _FarmListState extends State<FarmList> {
  List<Map<String, dynamic>> _farms = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchFarms();
  }

  // แสดง SnackBar
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ดึงข้อมูลไร่ทั้งหมด
  Future<void> _fetchFarms() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/farm'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> farmsData = json.decode(response.body);
        setState(() {
          _farms = farmsData.cast<Map<String, dynamic>>();
          _isLoading = false;
          _hasError = false;
        });
      } else {
        throw Exception('Failed to load farms');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      _showSnackBar('ไม่สามารถโหลดข้อมูลไร่ได้', isError: true);
    }
  }

  // ลบไร่
  Future<void> _deleteFarm(String id, String farmName) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:3000/api/farm/$id'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _farms.removeWhere((farm) => farm['id'] == id);
        });
        _showSnackBar('ลบไร่ "$farmName" สำเร็จ');
      } else {
        throw Exception('Failed to delete farm');
      }
    } catch (e) {
      _showSnackBar('ไม่สามารถลบไร่ได้', isError: true);
    }
  }

  // แสดง dialog ยืนยันการลบ
  Future<void> _showDeleteConfirmation(String id, String farmName) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ลบไร่ "$farmName"'),
          content: const Text('คุณต้องการลบไร่นี้ใช่หรือไม่?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteFarm(id, farmName);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('ลบ'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายการไร่ทั้งหมด'),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('เกิดข้อผิดพลาดในการโหลดข้อมูล'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchFarms,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('ลองใหม่'),
                      ),
                    ],
                  ),
                )
              : _farms.isEmpty
                  ? const Center(
                      child: Text('ยังไม่มีรายการไร่'),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchFarms,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: _farms.length,
                        itemBuilder: (context, index) {
                          final farm = _farms[index];
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 4,
                            ),
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: Colors.green,
                                child: Icon(
                                  Icons.agriculture,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                farm['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '${farm['startMonth']} - ${farm['endMonth']}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                color: Colors.red,
                                onPressed: () => _showDeleteConfirmation(
                                  farm['id'].toString(),
                                  farm['name'],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Createfarm()),
          );
        },
        backgroundColor: Colors.green,
        icon: const Icon(Icons.add),
        label: const Text('สร้างไร่ใหม่'),
      ),
    );
  }
}