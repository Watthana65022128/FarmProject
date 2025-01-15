import 'package:flutter/material.dart';
import '../models/farm_model.dart';
import '../widgets/custom_navigation_bar.dart';
import 'scan.dart';
import '../screens/overview_home.dart';
import '../models/receipt_model.dart';

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
    // เช็คว่ามี farmId ก่อน
    if (widget.farm.id == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ไม่พบข้อมูลฟาร์ม'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      final Receipt? newReceipt = await Navigator.push<Receipt>(
        context,
        MaterialPageRoute(
          builder: (context) => ScanPage(
              farmId: widget.farm.id!), // ใช้ ! เพราะเช็คแล้วว่าไม่เป็น null
          fullscreenDialog: true,
        ),
      );

      if (mounted && newReceipt != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('บันทึกใบเสร็จสำเร็จ'),
            backgroundColor: Colors.green,
          ),
        );

        setState(() {
          _selectedIndex = 0;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      _navigateToScan();
    } else {
      setState(() {
        _selectedIndex = index > 2 ? index - 1 : index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final navigationIndex =
        _selectedIndex >= 2 ? _selectedIndex + 1 : _selectedIndex;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.farm.name),
        centerTitle: true,
        backgroundColor: const Color(0xFFF3FCEE),
        foregroundColor: Colors.black,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          OverviewPage(
            farm: widget.farm,
            key: ValueKey('overview-${widget.farm.id}'),
          ),
          const Center(child: Text('หน้ารายการ')),
          const Center(child: Text('หน้าแจ้งเตือน')),
          const Center(child: Text('หน้างบประมาณ')),
        ],
      ),
      bottomNavigationBar: CustomNavigationBar(
        selectedIndex: navigationIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
