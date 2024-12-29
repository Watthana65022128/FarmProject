import 'package:flutter/material.dart';
import '../models/farm_model.dart';
import '../widgets/custom_navigation_bar.dart';
import 'scan.dart';

class FarmInfoPage extends StatefulWidget {
  final FarmModel farm;

  const FarmInfoPage({
    super.key,
    required this.farm,
  });

  @override
  State<FarmInfoPage> createState() => _FarmInfoPageState();
}

// ใน _FarmInfoPageState
class _FarmInfoPageState extends State<FarmInfoPage> {
  int _selectedIndex = 0;

  void _navigateToScan() async {
    try {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ScanPage(),
          fullscreenDialog: true, // เพิ่มการแสดงผลแบบ fullscreen
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.farm.name),
        centerTitle: true,
        backgroundColor: const Color(0xFFF3FCEE),
        foregroundColor: Colors.black,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          Center(child: Text('หน้าภาพรวม')), // index 0
          Center(child: Text('หน้ารายการ')), // index 1
          Center(child: Text('หน้าแจ้งเตือน')), // index 2 (เดิมเป็น 3)
          Center(child: Text('หน้างบประมาณ')), // index 3 (เดิมเป็น 4)
        ],
      ),
      bottomNavigationBar: CustomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) {
          if (index == 2) {
            _navigateToScan();
          } else {
            setState(() {
              _selectedIndex = index > 2 ? index - 1 : index;
            });
          }
        },
      ),
    );
  }
}
