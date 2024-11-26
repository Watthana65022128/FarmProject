import 'package:flutter/material.dart';
import 'screens/register.dart';
import 'screens/create_farm.dart';
import 'screens/profile.dart';
import 'screens/login.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('th', 'TH'),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF3FCEE),
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF3FCEE),
          elevation: 0, 
        ),
      ),
      home:  const LoginPage(),
    );
  }
}