import 'package:flutter/material.dart';
import '../auth/auth_service.dart';
import '../models/user_model.dart';

class ProfileEditPage extends StatefulWidget {
  final User userProfile;

  const ProfileEditPage({super.key, required this.userProfile});

  @override
  _ProfileEditPageState createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _ageController;
  late TextEditingController _addressController;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing user data
    _usernameController = TextEditingController(text: widget.userProfile.username);
    _emailController = TextEditingController(text: widget.userProfile.email);
    _ageController = TextEditingController(
      text: widget.userProfile.age != null 
        ? widget.userProfile.age.toString() 
        : ''
    );
    _addressController = TextEditingController(text: widget.userProfile.address);
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _usernameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _addressController.dispose();
    super.dispose();
  }

Future<void> _updateProfile() async {
  if (_formKey.currentState!.validate()) {
    try {
      // Prepare updated user data
      final updatedUser = User(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        age: int.tryParse(_ageController.text.trim()).toString(),
        address: _addressController.text.trim(),
        // Include other necessary fields from your existing User model
      );

      // Call auth service to update profile
      final result = await _authService.updateUserProfile(updatedUser);

      if (result != null) {
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('อัพเดทโปรไฟล์สำเร็จ'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          // Return to previous screen with updated data
          Navigator.pop(context, updatedUser);
        }
      } else {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('เกิดข้อผิดพลาดในการอัพเดทข้อมูล'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('แก้ไขโปรไฟล์'),
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildProfilePicture(),
                  const SizedBox(height: 32),
                  _buildTextFormField(
                    controller: _usernameController,
                    label: 'ชื่อ',
                    icon: Icons.person,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกชื่อ';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextFormField(
                    controller: _emailController,
                    label: 'อีเมล',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกอีเมล';
                      }
                      // Basic email validation
                      final emailRegex = RegExp(
                        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
                      );
                      if (!emailRegex.hasMatch(value)) {
                        return 'รูปแบบอีเมลไม่ถูกต้อง';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextFormField(
                    controller: _ageController,
                    label: 'อายุ',
                    icon: Icons.cake,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกอายุ';
                      }
                      final age = int.tryParse(value);
                      if (age == null || age < 0 || age > 120) {
                        return 'กรุณากรอกอายุที่ถูกต้อง';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextFormField(
                    controller: _addressController,
                    label: 'ที่อยู่',
                    icon: Icons.home,
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกที่อยู่';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'บันทึกการเปลี่ยนแปลง',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
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

  Widget _buildProfilePicture() {
    return Stack(
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
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: IconButton(
            icon: const Icon(Icons.camera_alt, color: Colors.white),
            onPressed: () {
              // จัดการการอัพโหลดรูปภาพ
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int? maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.green),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.green, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
    );
  }
}