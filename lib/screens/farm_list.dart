import 'package:flutter/material.dart';
import '../models/farm_model.dart';
import '../services/farm_service.dart';
import './farm_info.dart';

class FarmListPage extends StatefulWidget {
  final FarmModel? newFarm;

  const FarmListPage({Key? key, this.newFarm}) : super(key: key);

  @override
  
  _FarmListPageState createState() => _FarmListPageState();
}

class _FarmListPageState extends State<FarmListPage> {
  final FarmService _farmService = FarmService();
  List<FarmModel> _farms = [];
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
      final farms = await _farmService.getFarms();
      setState(() {
        _farms = farms; // กำหนดค่าใหม่แทนการใช้ addAll
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'เกิดข้อผิดพลาดในการโหลดข้อมูล: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteFarm(FarmModel farm) async {
    final confirmed = await _showDeleteConfirmation(farm.name);
    if (confirmed) {
      setState(() => _isLoading = true);

      try {
        final success = await _farmService.removeFarm(farm.id!);
        if (success) {
          // อัพเดทรายการไร่ทันทีหลังจากลบสำเร็จ
          setState(() {
            _farms.removeWhere((f) => f.id == farm.id);
            _isLoading = false; // อัพเดทสถานะหลังลบสำเร็จ
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('ลบไร่สำเร็จ'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          setState(() {
            _isLoading = false;
          });
          if (mounted) {
            _showErrorSnackBar('ลบไร่สำเร็จ');
          }
        }
      } catch (e) {
        // เกิดข้อผิดพลาดในการลบ
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          _showErrorSnackBar('เกิดข้อผิดพลาดในการลบไร่: ${e.toString()}');
        }
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message),
          backgroundColor: const Color.fromARGB(255, 4, 202, 53)),
    );
  }

  Future<bool> _showDeleteConfirmation(String farmName) async {
    bool confirmed = false;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'ยืนยันการลบ',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        content: Text(
          'คุณต้องการลบ "$farmName" ใช่หรือไม่?',
          style: const TextStyle(fontSize: 18),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'ยกเลิก',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(width: 22),
              ElevatedButton(
                onPressed: () {
                  confirmed = true;
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'ยืนยัน',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    return confirmed;
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
                      Image.asset(
                        'assets/logo.png',
                        height: 120,
                      ),
                      const SizedBox(height: 16),
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
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/logo.png',
                            height: 120,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'ไม่มีรายการไร่',
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    )
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
                                  leading: const Icon(
                                    Icons.agriculture,
                                    color: Colors.green,
                                    size: 32,
                                  ),
                                  title: Text(
                                    farm.name.toUpperCase(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                      color: Colors.green,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'ระยะเวลา: ${farm.startMonth} - ${farm.endMonth}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                      size: 28,
                                    ),
                                    onPressed: () => _deleteFarm(farm),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FarmInfoPage(
                                            farm: farm), // ส่งข้อมูลไร่ไปด้วย
                                      ),
                                    );
                                  },
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
