import 'package:flutter/material.dart';
import '../widgets/overview_card.dart';
import '../screens/management_expense.dart';
import '../screens/production_expense.dart';
import '../models/farm_model.dart';
import '../services/farm_service.dart';
import 'package:intl/intl.dart';

class OverviewPage extends StatefulWidget {
  final FarmModel farm;

  const OverviewPage({
    super.key,
    required this.farm,
  });

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  String _budget = '0';
  final FarmService _farmService = FarmService();

  @override
  void initState() {
    super.initState();
    // ตั้งค่าเริ่มต้นของ budget จาก farm model
    if (widget.farm.budget != null) {
      setState(() {
        _budget = widget.farm.budget!.toString();
      });
    }
  }

  void _updateBudget(String amount) async {
    if (widget.farm.id == null) return;

    try {
      final budget = double.tryParse(amount);
      if (budget == null) return;

      final success = await _farmService.updateBudget(widget.farm.id!, budget);

      if (mounted) {
        if (success) {
          setState(() {
            _budget = amount;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('อัพเดทงบประมาณสำเร็จ'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ไม่สามารถอัพเดทงบประมาณได้'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'วงเงินงบประมาณ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '฿${NumberFormat("#,##0.00").format(double.tryParse(_budget) ?? 0)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  EditAmountButton(
                    onAmountSubmitted: _updateBudget,
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end, // จัดให้อยู่ด่านล่างสุด
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
                        builder: (context) => const ProductionExpensePage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class EditAmountButton extends StatelessWidget {
  final Function(String) onAmountSubmitted;

  const EditAmountButton({
    Key? key,
    required this.onAmountSubmitted,
  }) : super(key: key);

  Future<void> _showAmountDialog(BuildContext context) async {
    final TextEditingController controller = TextEditingController();

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'กำหนดวงเงินงบประมาณ',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              hintText: 'ระบุจำนวนเงิน',
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              border: UnderlineInputBorder(),
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    child: const Text(
                      'ยกเลิก',
                      style: TextStyle(color: Colors.black87),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('ตกลง'),
                    onPressed: () {
                      if (controller.text.isNotEmpty) {
                        onAmountSubmitted(controller.text);
                      }
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: InkWell(
        onTap: () => _showAmountDialog(context),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.grey.shade400,
              width: 2,
            ),
          ),
          child: const Icon(
            Icons.edit,
            size: 20,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }
}
