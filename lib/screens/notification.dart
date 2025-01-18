import 'package:flutter/material.dart';
import '../services/expense_service.dart';
import 'package:intl/intl.dart';
import '../utils/refreshable_state.dart';

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

class _NotificationPageState extends State<NotificationPage> with RefreshableState {
  final ExpenseService _expenseService = ExpenseService();
  bool _isLoading = true;
  double _totalExpense = 0;
  double _usagePercentage = 0;
  bool _showWarningLevel1 = false; // 60%
  bool _showWarningLevel2 = false; // 80%
  bool _showWarningLevel3 = false; // 90%

  @override
  void refreshData() {
    _loadData();
  }

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

      setState(() {
        _showWarningLevel1 = _usagePercentage >= 60;
        _showWarningLevel2 = _usagePercentage >= 80;
        _showWarningLevel3 = _usagePercentage >= 90;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
        );
      }
    }
  }

  Color _getWarningColor() {
    if (_usagePercentage >= 90) return Colors.red;
    if (_usagePercentage >= 80) return Colors.orange;
    if (_usagePercentage >= 60) return Colors.yellow.shade700;
    return Colors.green;
  }

  String _getWarningMessage() {
    if (_usagePercentage >= 90) {
      return 'คำเตือน: ใช้งบประมาณเกิน 90% แล้ว\nควรระมัดระวังการใช้จ่ายอย่างยิ่ง!';
    }
    if (_usagePercentage >= 80) {
      return 'คำเตือน: ใช้งบประมาณเกิน 80% แล้ว\nควรพิจารณาลดค่าใช้จ่ายลง';
    }
    if (_usagePercentage >= 60) {
      return 'แจ้งเตือน: ใช้งบประมาณเกิน 60% แล้ว\nควรเริ่มระมัดระวังการใช้จ่าย';
    }
    return 'การใช้งบประมาณอยู่ในเกณฑ์ปกติ';
  }

  IconData _getWarningIcon() {
    if (_usagePercentage >= 90) return Icons.error_outline;
    if (_usagePercentage >= 80) return Icons.warning_amber_rounded;
    if (_usagePercentage >= 60) return Icons.info_outline;
    return Icons.check_circle_outline;
  }

  Widget _buildWarningCard() {
    final warningColor = _getWarningColor();
    final warningMessage = _getWarningMessage();
    final warningIcon = _getWarningIcon();
    final remainingBudget = widget.budget - _totalExpense;
    final formattedUsagePercentage = _usagePercentage.toStringAsFixed(1);

    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: warningColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Warning Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: warningColor.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                warningIcon,
                color: warningColor,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),

            // Warning Title
            Text(
              'ใช้งบประมาณไปแล้ว $formattedUsagePercentage%',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: warningColor,
              ),
            ),
            const SizedBox(height: 8),

            // Warning Message
            Text(
              warningMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // Budget Details
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
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
                    warningColor,
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

            // Progress Bar
            const SizedBox(height: 24),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _usagePercentage / 100,
                backgroundColor: Colors.grey.shade200,
                color: warningColor,
                minHeight: 12,
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
            fontSize: 18,
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
            _buildWarningCard(),
          ],
        ),
      ),
    );
  }
}