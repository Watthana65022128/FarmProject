import 'package:flutter/material.dart';
import '../widgets/overview_card.dart';

class ProductionExpensePage extends StatelessWidget {
  const ProductionExpensePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ค่าใช้จ่ายในการผลิต'),
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
                  title: 'ค่าเมล็ดพันธุ์พืช',
                  icon: Icons.grass, // เปลี่ยนไอคอนให้สอดคล้อง
                ),
                SizedBox(height: 20),
                OverviewCard(
                  title: 'ค่าสารเคมี',
                  icon: Icons.science, // เปลี่ยนไอคอนให้สอดคล้อง
                ),
                SizedBox(height: 20),
                OverviewCard(
                  title: 'ค่าน้ำ',
                  icon: Icons.water, // เปลี่ยนไอคอนให้สอดคล้อง
                ),
                SizedBox(height: 20),
                OverviewCard(
                  title: 'ค่าไฟ',
                  icon: Icons.electric_bolt, // เปลี่ยนไอคอนให้สอดคล้อง
                ),
                SizedBox(height: 20),
                OverviewCard(
                  title: 'ค่าปุ๋ย',
                  icon: Icons.agriculture, // เปลี่ยนไอคอนให้สอดคล้อง
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}