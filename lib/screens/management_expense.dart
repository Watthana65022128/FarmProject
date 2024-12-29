import 'package:flutter/material.dart';
import '../widgets/overview_card.dart';

class ManagementExpensePage extends StatelessWidget {
  const ManagementExpensePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ค่าจัดการและการดูแล'),
        centerTitle: true,
        backgroundColor: const Color(0xFFF3FCEE),
        foregroundColor: Colors.black,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OverviewCard(
                  title: 'ค่าแรง',
                  icon: Icons.attach_money, // เปลี่ยนไอคอนให้สอดคล้อง
                ),
                SizedBox(height: 30),
                OverviewCard(
                  title: 'ค่าขนส่ง',
                  icon: Icons.local_shipping, // เปลี่ยนไอคอนให้สอดคล้อง
                ),
                SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}