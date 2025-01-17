import 'package:flutter/material.dart';
import '../services/expense_service.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatefulWidget {
  final int farmId;
  final double budget;

  const NotificationPage({
    super.key,
    required this.farmId,
    required this.budget,
  });

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final ExpenseService _expenseService = ExpenseService();
  bool _isLoading = true;
  double _totalExpense = 0;
  bool _showBudgetAlert = false;
  double _usagePercentage = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);

      final managementData = await _expenseService.getManagementExpenses(widget.farmId);
      final productionData = await _expenseService.getProductionExpenses(widget.farmId);

      final managementTotal = managementData.values.fold(
        0.0,
        (sum, category) => sum + (category['total'] as double),
      );
      final productionTotal = productionData.values.fold(
        0.0,
        (sum, category) => sum + (category['total'] as double),
      );

      _totalExpense = managementTotal + productionTotal;
      _usagePercentage = (widget.budget > 0) 
        ? (_totalExpense / widget.budget * 100) 
        : 0;
      _showBudgetAlert = _usagePercentage >= 80;

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
        );
      }
    }
  }

  Widget _buildBudgetAlertCard() {
    if (!_showBudgetAlert) {
      return Card(
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 48,
              ),
              SizedBox(height: 16),
              Text(
                'ไม่มีการแจ้งเตือนในขณะนี้',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'การใช้งบประมาณของคุณอยู่ในเกณฑ์ปกติ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final remainingBudget = widget.budget - _totalExpense;
    final formattedUsagePercentage = _usagePercentage.toStringAsFixed(1);

    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: Colors.red.shade700,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'คำเตือน: ใช้งบประมาณไปแล้ว $formattedUsagePercentage%',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'คุณได้ใช้งบประมาณเกินกว่า 80% แล้ว\nกรุณาตรวจสอบและวางแผนการใช้จ่าย',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildBudgetInfo(
                    'งบประมาณทั้งหมด',
                    widget.budget,
                    Colors.blue,
                  ),
                  const Divider(height: 24),
                  _buildBudgetInfo(
                    'ใช้ไปแล้ว',
                    _totalExpense,
                    Colors.red,
                  ),
                  const Divider(height: 24),
                  _buildBudgetInfo(
                    'คงเหลือ',
                    remainingBudget,
                    Colors.green,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('รีเฟรชข้อมูล'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade700,
                side: BorderSide(color: Colors.red.shade700),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetInfo(String label, double amount, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          '฿${NumberFormat("#,##0.00").format(amount)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            _buildBudgetAlertCard(),
          ],
        ),
      ),
    );
  }
}