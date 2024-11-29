import 'package:flutter/material.dart';
import '../screens/login.dart';
import '../auth/auth_service.dart';
import '../models/user_model.dart';
import '../screens/profile_edit.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  User? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getUserProfile();
  }

  Future<void> _getUserProfile() async {
    try {
      final userProfile = await _authService.getUserProfile();

      if (mounted) {
        setState(() {
          _userProfile = userProfile;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาดในการดึงข้อมูล: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showLogoutConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('ยืนยันการออกจากระบบ'),
          content: const Text('คุณต้องการออกจากระบบใช่หรือไม่?'),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'ยกเลิก',
                style: TextStyle(color: Colors.grey),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text(
                'ยืนยัน',
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () async {
                Navigator.of(dialogContext).pop();

                await _authService.logout();

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('ออกจากระบบสำเร็จ'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 1),
                    ),
                  );

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                    (route) => false,
                  );
                }
              },
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('โปรไฟล์ของฉัน'),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _userProfile == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('ไม่สามารถโหลดข้อมูลโปรไฟล์ได้'),
                          ElevatedButton(
                            onPressed: _getUserProfile,
                            child: const Text('ลองอีกครั้ง'),
                          )
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                CircleAvatar(
                                  radius: 60,
                                  backgroundColor: Colors.grey[200],
                                  child: const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.green,
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 2),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.camera_alt,
                                        color: Colors.white),
                                    onPressed: () {
                                      // จัดการการอัพโหลดรูปภาพ
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            // แสดงข้อมูลโปรไฟล์ที่ดึงมาจาก API
                            _buildProfileItem(
                              icon: Icons.person,
                              label: 'ชื่อ',
                              value: _userProfile?.username ?? 'ไม่มีข้อมูล',
                            ),
                            _buildProfileItem(
                              icon: Icons.email,
                              label: 'อีเมล',
                              value: _userProfile?.email ?? 'ไม่มีข้อมูล',
                            ),
                            _buildProfileItem(
                              icon: Icons.cake,
                              label: 'อายุ',
                              value: _userProfile?.age != null
                                  ? '${_userProfile!.age} ปี'
                                  : 'ไม่มีข้อมูล',
                            ),
                            _buildProfileItem(
                              icon: Icons.home,
                              label: 'ที่อยู่',
                              value: _userProfile?.address ?? 'ไม่มีข้อมูล',
                            ),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: () async {
                                  // ใช้ Navigator เพื่อไปยังหน้า ProfileEditPage
                                  final updatedUser =
                                      await Navigator.push<User>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProfileEditPage(
                                          userProfile: _userProfile!),
                                    ),
                                  );

                                  // ถ้ามีข้อมูลที่อัปเดตกลับมา
                                  if (updatedUser != null) {
                                    setState(() {
                                      _userProfile =
                                          updatedUser; // อัปเดตข้อมูลผู้ใช้ในหน้า ProfilePage
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'แก้ไขโปรไฟล์',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            TextButton(
                              onPressed: _showLogoutConfirmationDialog,
                              child: const Text(
                                'ออกจากระบบ',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
        ),
      ),
    );
  }

  // โค้ดส่วน _buildProfileItem คงเดิม
  Widget _buildProfileItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
