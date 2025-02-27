import 'package:flutter/material.dart';
import '../services/expense_service.dart';
import '../widgets/expense_pie_chart.dart';
import 'package:intl/intl.dart';
import '../utils/refreshable_state.dart';

class BudgetPage extends StatefulWidget {
  final int farmId;
  final double budget;

  const BudgetPage({
    super.key,
    required this.farmId,
    required this.budget,
  });

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> with RefreshableState {
  final ExpenseService _expenseService = ExpenseService();
  bool _isLoading = true;
  double _managementExpense = 0;
  double _productionExpense = 0;
  Map<String, dynamic> _managementDetails = {};
  Map<String, dynamic> _productionDetails = {};

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

      if (mounted) {
        setState(() {
          _managementDetails = managementData;
          _productionDetails = productionData;

          _managementExpense = managementData.values.fold(
            0.0,
            (sum, category) => sum + (category['total'] as double? ?? 0.0),
          );
          _productionExpense = productionData.values.fold(
            0.0,
            (sum, category) => sum + (category['total'] as double? ?? 0.0),
          );

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
        );
      }
    }
  }

  Widget _buildExpenseSummaryCard() {
    final totalExpense = _managementExpense + _productionExpense;
    final remainingBudget = widget.budget - totalExpense;
    
    // คำนวณเปอร์เซ็นต์การใช้งบประมาณ
    final usagePercentage = widget.budget > 0 
        ? ((totalExpense / widget.budget) * 100).clamp(0.0, 100.0)
        : 0.0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'สรุปงบประมาณ',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBudgetInfoColumn(
                  'งบประมาณทั้งหมด',
                  widget.budget,
                  Colors.blue,
                ),
                _buildBudgetInfoColumn(
                  'ใช้ไปแล้ว',
                  totalExpense,
                  Colors.orange,
                ),
                _buildBudgetInfoColumn(
                  'คงเหลือ',
                  remainingBudget,
                  remainingBudget < 0 ? Colors.red : Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (widget.budget > 0) ...[
              LinearProgressIndicator(
                value: (totalExpense / widget.budget).clamp(0.0, 1.0),
                backgroundColor: Colors.grey[200],
                color: Colors.green,
                minHeight: 8,
              ),
              const SizedBox(height: 8),
              Text(
                'ใช้งบประมาณไปแล้ว ${usagePercentage.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.warning_amber_rounded, 
                         color: Colors.orange[700],
                         size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'กรุณากำหนดวงเงินงบประมาณ',
                      style: TextStyle(
                        color: Colors.orange[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetInfoColumn(String label, double amount, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '฿${NumberFormat("#,##0").format(amount)}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  final Map<String, String> _managementCategories = {
    'equipment': 'ค่าอุปกรณ์',
    'labor': 'ค่าแรง',
    'transportation': 'ค่าขนส่ง',
  };

  final Map<String, String> _productionCategories = {
    'seeds': 'ค่าเมล็ดพันธุ์พืช',
    'chemicals': 'ค่าสารเคมี',
    'water': 'ค่าน้ำ',
    'electricity': 'ค่าไฟ',
    'fertilizer': 'ค่าปุ๋ย',
  };

  Widget _buildExpenseDetailCard(String title, Map<String, dynamic> details, Color color) {
    final isManagement = title.contains('จัดการ');
    final categoriesMap = isManagement ? _managementCategories : _productionCategories;

    List<Widget> expenseItems = [];
    categoriesMap.forEach((key, thaiName) {
      if (details[key] != null) {
        expenseItems.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(thaiName),
                Text(
                  '฿${NumberFormat("#,##0").format(details[key]['total'] ?? 0)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    });

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  title.contains('จัดการ') ? Icons.settings : Icons.agriculture,
                  color: color,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...expenseItems,
          ],
        ),
      ),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildExpenseSummaryCard(),
            const SizedBox(height: 24),
            ExpensePieChart(
              managementExpense: _managementExpense,
              productionExpense: _productionExpense,
            ),
            const SizedBox(height: 24),
            _buildExpenseDetailCard(
              'ค่าจัดการและการดูแล',
              _managementDetails,
              Colors.orange,
            ),
            const SizedBox(height: 16),
            _buildExpenseDetailCard(
              'ค่าใช้จ่ายในการผลิต',
              _productionDetails,
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}