import 'package:flutter/material.dart';
import '../models/farm_model.dart';
import '../widgets/custom_navigation_bar.dart';
import 'scan.dart';
import '../screens/overview_home.dart';

class FarmInfoPage extends StatefulWidget {
  final FarmModel farm;

  const FarmInfoPage({
    super.key,
    required this.farm,
  });

  @override
  State<FarmInfoPage> createState() => _FarmInfoPageState();
}

class _FarmInfoPageState extends State<FarmInfoPage> {
  int _selectedIndex = 0;

  void _navigateToScan() async {
    try {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ScanPage(),
          fullscreenDialog: true,
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

  void _onItemTapped(int index) {
    if (index == 2) {
      _navigateToScan();
    } else {
      setState(() {
        // ปรับการคำนวณ index ใหม่
        _selectedIndex = index > 2 ? index - 1 : index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // คำนวณ currentIndex สำหรับ CustomNavigationBar
    final navigationIndex = _selectedIndex >= 2 ? _selectedIndex + 1 : _selectedIndex;

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
          OverviewPage(),
          Center(child: Text('หน้ารายการ')),
          Center(child: Text('หน้าแจ้งเตือน')),
          Center(child: Text('หน้างบประมาณ')),
        ],
      ),
      bottomNavigationBar: CustomNavigationBar(
        selectedIndex: navigationIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}