import 'package:flutter/material.dart';
import '../widgets/overview_card.dart';
import '../screens/management_expense.dart';
import '../screens/production_expense.dart';

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              OverviewCard(
                title: 'ค่าจัดการและการดูแล',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ManagementExpensePage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              OverviewCard(
                title: 'ค่าใช้จ่ายในการผลิต',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProductionExpensePage(), // เปลี่ยนหน้าไปยัง ProductionExpensePage
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}