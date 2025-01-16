import 'package:flutter/material.dart';
import '../services/expense_service.dart';

class ProductionExpensePage extends StatefulWidget {
  final int farmId;
  const ProductionExpensePage({super.key, required this.farmId});

  @override
  State<ProductionExpensePage> createState() => _ProductionExpensePageState();
}

class _ProductionExpensePageState extends State<ProductionExpensePage> {
  final ExpenseService _expenseService = ExpenseService();
  bool _isLoading = true;
  Map<String, double> _expenses = {
    'seeds': 0,
    'chemicals': 0,
    'water': 0,
    'electricity': 0,
    'fertilizer': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    try {
      setState(() => _isLoading = true);
      final expenses = await _expenseService.getProductionExpenses(widget.farmId);
      setState(() {
        _expenses = expenses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
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

  Widget _buildExpenseCard({
    required String title,
    required IconData icon,
    required double amount,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '฿${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalExpense = _expenses.values.reduce((a, b) => a + b);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ค่าใช้จ่ายในการผลิต'),
        centerTitle: true,
        backgroundColor: const Color(0xFFF3FCEE),
        foregroundColor: Colors.black,
      ),
      body: RefreshIndicator(
        onRefresh: _loadExpenses,
        child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text(
                            'รวมค่าใช้จ่ายทั้งหมด',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '฿${totalExpense.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildExpenseCard(
                    title: 'ค่าเมล็ดพันธุ์พืช',
                    icon: Icons.grass,
                    amount: _expenses['seeds']!,
                    color: Colors.green,
                  ),
                  _buildExpenseCard(
                    title: 'ค่าสารเคมี',
                    icon: Icons.science,
                    amount: _expenses['chemicals']!,
                    color: Colors.purple,
                  ),
                  _buildExpenseCard(
                    title: 'ค่าน้ำ',
                    icon: Icons.water_drop,
                    amount: _expenses['water']!,
                    color: Colors.blue,
                  ),
                  _buildExpenseCard(
                    title: 'ค่าไฟ',
                    icon: Icons.electric_bolt,
                    amount: _expenses['electricity']!,
                    color: Colors.amber,
                  ),
                  _buildExpenseCard(
                    title: 'ค่าปุ๋ย',
                    icon: Icons.eco,
                    amount: _expenses['fertilizer']!,
                    color: Colors.brown,
                  ),
                  // Add padding at the bottom for better scrolling experience
                  const SizedBox(height: 20),
                ],
              ),
            ),
      ),
    );
  }
}