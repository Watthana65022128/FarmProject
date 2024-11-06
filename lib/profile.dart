import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 4, // เพิ่ม Elevation ให้กับ AppBar
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'บัญชี',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600, // เพิ่ม FontWeight เพื่อให้ Header Text เด่นชัดขึ้น
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0), // เพิ่ม Padding สำหรับ Body
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profile Image
            const Center(
              child: CircleAvatar(
                radius: 46,
                backgroundColor: Color(0xFFEEEEEE),
                child: Icon(
                  Icons.person_outline,
                  size: 46,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // User ID
            const Text(
              'ID: xxxxxxxx',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 30),
            // Personal Info Card
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ), // เพิ่ม BoxShadow เพื่อเพิ่ม Elevation
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with edit button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ข้อมูลส่วนตัว',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600, // เพิ่ม FontWeight เพื่อให้ Header Text เด่นชัดขึ้น
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: Colors.black54,
                          ),
                          onPressed: () {
                            // Add edit functionality
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    // User details
                    _buildInfoRow('ชื่อ', 'xxxxxxxx'),
                    const SizedBox(height: 16),
                    _buildInfoRow('อีเมล', 'xxxxxxxx'),
                    const SizedBox(height: 16),
                    _buildInfoRow('รหัสผ่าน', 'xxxxxxxx'),
                    const SizedBox(height: 16),
                    _buildInfoRow('อายุ', 'xxxxxxxx'),
                    const SizedBox(height: 30),
                    const Text(
                      'ที่อยู่',
                      style: TextStyle(
                        fontWeight: FontWeight.w600, // เพิ่ม FontWeight เพื่อให้ Header Text เด่นชัดขึ้น
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'xxxxxxxx',
                      style: TextStyle(color: Colors.black54),
                    ),
                    const Spacer(),
                    // Logout Button
                    Center(
                      child: SizedBox(
                        width: 150,
                        child: ElevatedButton(
                          onPressed: () {
                            // Add logout functionality
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 93, 95, 94),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            'ออกจากระบบ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600, // เพิ่ม FontWeight เพื่อให้ Text เด่นชัดขึ้น
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black54),
              overflow: TextOverflow.ellipsis, // เพิ่ม TextOverflow เพื่อแสดง Text เต็มความยาว
            ),
          ),
        ],
      ),
    );
  }
}