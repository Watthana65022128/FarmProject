import 'package:flutter/material.dart';
import '../models/farm_model.dart';
import '../services/farm_service.dart';
import 'profile.dart';
import 'farm_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateFarmPage extends StatefulWidget {
  const CreateFarmPage({super.key});

  @override
  _CreateFarmPageState createState() => _CreateFarmPageState();
}


class _CreateFarmPageState extends State<CreateFarmPage> {
  final TextEditingController _nameController = TextEditingController();
  final FarmService _farmService = FarmService();
  bool _isLoading = false;
  String? _startMonth;
  String? _endMonth;

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
    'ธันวาคม'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveFarm() async {
  if (_nameController.text.isEmpty || _startMonth == null || _endMonth == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('กรุณากรอกข้อมูลให้ครบถ้วน'),
        backgroundColor: Colors.red
      ),
    );
    return;
  }

  setState(() => _isLoading = true);

  final farm = FarmModel(
    name: _nameController.text,
    startMonth: _startMonth!,
    endMonth: _endMonth!,
  );

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('jwt_token');

  final success = await _farmService.createFarm(farm, token);

  if (!mounted) return;

  setState(() => _isLoading = false);

  if (success) {
    // แสดง SnackBar ก่อน navigate
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('เพิ่มไร่สำเร็จ'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ),
    );

    // รอให้ SnackBar แสดงเสร็จก่อน navigate
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    // ใช้ pushAndRemoveUntil เพื่อล้าง stack เก่าทั้งหมด
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const FarmListPage()),
      (route) => false,
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ไม่สามารถเพิ่มไร่ได้'),
        backgroundColor: Colors.red,
      ),
    );
  }
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
          padding: const EdgeInsets.all(30),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ข้อมูลไร่',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'ชื่อไร่',
                          prefixIcon: const Icon(Icons.agriculture, color: Colors.green),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.green, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // เลือกเดือนเริ่มต้น
                      DropdownButtonFormField<String>(
                        value: _startMonth,
                        decoration: InputDecoration(
                          labelText: 'เดือนเริ่มต้น',
                          prefixIcon: const Icon(Icons.calendar_today, color: Colors.green),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.green, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: months.map((String month) {
                          return DropdownMenuItem<String>(
                            value: month,
                            child: Text(month),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() => _startMonth = newValue);
                        },
                      ),
                      const SizedBox(height: 20),

                      // เลือกเดือนสิ้นสุด
                      DropdownButtonFormField<String>(
                        value: _endMonth,
                        decoration: InputDecoration(
                          labelText: 'เดือนสิ้นสุด',
                          prefixIcon: const Icon(Icons.calendar_today, color: Colors.green),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.green, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: months.map((String month) {
                          return DropdownMenuItem<String>(
                            value: month,
                            child: Text(month),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() => _endMonth = newValue);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveFarm,
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
                          'สร้างไร่',
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FarmListPage()),
                  );
                },
                icon: const Icon(Icons.list),
                label: const Text('รายการไร่ทั้งหมด'),
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
