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
                  title: 'ค่าอุปกรณ์',
                  icon: Icons.build, // ปรับไอคอนให้ตรงกับ title
                ),
                SizedBox(height: 20),
                OverviewCard(
                  title: 'ค่าแรง',
                  icon: Icons.work, // ปรับไอคอนให้ตรงกับ title
                ),
                SizedBox(height: 20),
                OverviewCard(
                  title: 'ค่าขนส่ง',
                  icon: Icons.local_shipping, // ปรับไอคอนให้ตรงกับ title
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}