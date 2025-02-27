import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../auth/auth_service.dart';
import '../widgets/custom_text_field_register.dart';
import '../screens/login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  bool _isLoading = false;

  String? _validatePassword(String password) {
    if (password.isEmpty) {
      return 'กรุณากรอกรหัสผ่าน';
    }

    if (password.length < 6) {
      return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
    }

    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'รหัสผ่านต้องมีตัวพิมพ์เล็กอย่างน้อย 1 ตัว';
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'รหัสผ่านต้องมีตัวพิมพ์ใหญ่อย่างน้อย 1 ตัว';
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'รหัสผ่านต้องมีตัวเลขอย่างน้อย 1 ตัว';
    }

    if (!password.contains(RegExp(r'[@$!%*?&_-]'))) {
      return 'รหัสผ่านต้องมีอักขระพิเศษ อย่างน้อย 1 ตัว';
    }

    return null;
  }

  Future<void> _handleRegister() async {
    // ตรวจสอบรหัสผ่าน
    String? passwordError = _validatePassword(passwordController.text);
    if (passwordError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(passwordError),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // ตรวจสอบรหัสผ่านยืนยัน
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('รหัสผ่านไม่ตรงกัน'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final user = User(
        username: usernameController.text,
        email: emailController.text,
        password: passwordController.text,
        age: ageController.text,
        address: addressController.text,
      );

      final success = await _authService.register(user);

      setState(() {
        _isLoading = false;
      });

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ลงทะเบียนสำเร็จ'),
              backgroundColor: Colors.green,
            ),
          );
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('อีเมลนี้ถูกใช้งานแล้ว'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Image.asset(
                      'assets/logo.png',
                      height: 100,
                    ),
                    
                    const Text(
                      'ลงทะเบียน',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: usernameController,
                      labelText: 'ชื่อผู้ใช้',
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: emailController,
                      labelText: 'อีเมล',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: passwordController,
                      labelText: 'รหัสผ่าน',
                      icon: Icons.lock,
                      obscureText: true,
                      helperText: '''รหัสผ่านต้องประกอบด้วย:
- ความยาวอย่างน้อย 6 ตัวอักษร
- ตัวพิมพ์เล็กอย่างน้อย 1 ตัว
- ตัวพิมพ์ใหญ่อย่างน้อย 1 ตัว
- ตัวเลขอย่างน้อย 1 ตัว
- อักขระพิเศษ (@\$!%*?&_-) อย่างน้อย 1 ตัว''',
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: confirmPasswordController,
                      labelText: 'ยืนยันรหัสผ่าน',
                      icon: Icons.lock_outline,
                      obscureText: true,
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: ageController,
                      labelText: 'อายุ',
                      icon: Icons.cake,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: addressController,
                      labelText: 'ที่อยู่',
                      icon: Icons.home,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                'ลงทะเบียน',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginPage()),
                        );
                      },
                      child: const Text(
                        'เข้าสู่ระบบ',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    ageController.dispose();
    addressController.dispose();
    super.dispose();
  }
}
