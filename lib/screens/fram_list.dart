import 'package:flutter/material.dart';
import '../models/farm_model.dart';
import '../services/farm_service.dart';

class FarmListPage extends StatefulWidget {
  final FarmModel? newFarm; // รับข้อมูลฟาร์มที่สร้างใหม่

  const FarmListPage({Key? key, this.newFarm}) : super(key: key);

  @override
  _FarmListPageState createState() => _FarmListPageState();
}

class _FarmListPageState extends State<FarmListPage> {
  final FarmService _farmService = FarmService();
  final List<FarmModel> _farms = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFarms();
  }

  Future<void> _loadFarms() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (widget.newFarm != null) {
        _farms.add(widget.newFarm!);
      } else {
        final farms = await _farmService.getFarms();
        setState(() {
          _farms.addAll(farms);
        });
      }
    } catch (e) {
      setState(() {
        _error = 'เกิดข้อผิดพลาดในการโหลดข้อมูล: ${e.toString()}';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteFarm(int? id) async {
    if (id == null) return;
    try {
      final success = await _farmService.removeFarm(id);
      if (success) {
        // ย้าย setState ออกมาจาก block ของการแสดง SnackBar
        setState(() {
          _farms.removeWhere((farm) => farm.id == id);
        });
        // แยก ScaffoldMessenger ออกมา
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('ลบไร่สำเร็จ'), backgroundColor: Colors.green),
        );
      } else {
        _showErrorSnackBar('ไม่สามารถลบไร่ได้');
      }
    } catch (e) {
      _showErrorSnackBar('เกิดข้อผิดพลาดในการลบไร่: ${e.toString()}');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายการไร่ทั้งหมด'),
        centerTitle: true,
        backgroundColor: const Color(0xFFF3FCEE),
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadFarms,
                        child: const Text('ลองใหม่'),
                      ),
                    ],
                  ),
                )
              : _farms.isEmpty
                  ? const Center(child: Text('ไม่มีรายการไร่'))
                  : RefreshIndicator(
                      onRefresh: _loadFarms,
                      child: ListView.builder(
                        itemCount: _farms.length,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final farm = _farms[index];
                          return SizedBox(
                            height: 120,
                            child: Card(
                              margin:
                                  const EdgeInsets.only(top: 10, bottom: 10),
                              child: Center(
                                child: ListTile(
                                  leading: const Icon(Icons.agriculture,
                                      color: Colors.green),
                                  title: Text(
                                    farm.name.toUpperCase(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                      color: Colors.green
                                    ),
                                  ),
                                  subtitle: Text(
                                    'ระยะเวลา: ${farm.startMonth} - ${farm.endMonth}',
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () => _deleteFarm(farm.id),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
