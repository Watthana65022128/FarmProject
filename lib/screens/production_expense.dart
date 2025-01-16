import 'package:flutter/material.dart';
import '../services/expense_service.dart';
import '../widgets/expense_category_detail.dart';

class ProductionExpensePage extends StatefulWidget {
  final int farmId;
  const ProductionExpensePage({super.key, required this.farmId});

  @override
  State<ProductionExpensePage> createState() => _ProductionExpensePageState();
}

class _ProductionExpensePageState extends State<ProductionExpensePage> {
  final ExpenseService _expenseService = ExpenseService();
  bool _isLoading = true;
  Map<String, dynamic> _expenses = {
    'seeds': {'total': 0.0, 'items': []},
    'chemicals': {'total': 0.0, 'items': []},
    'water': {'total': 0.0, 'items': []},
    'electricity': {'total': 0.0, 'items': []},
    'fertilizer': {'total': 0.0, 'items': []},
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

  void _showCategoryDetail(String title, List<Map<String, dynamic>> items, Color color) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExpenseCategoryDetailPage(
          title: title,
          items: items,
          color: color,
        ),
      ),
    );
  }

  Widget _buildExpenseCard({
    required String title,
    required IconData icon,
    required Map<String, dynamic> expenseData,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showCategoryDetail(
          title,
          List<Map<String, dynamic>>.from(expenseData['items']),
          color,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '฿${expenseData['total'].toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                '${expenseData['items'].length} รายการ',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalExpense = _expenses.values
        .fold<double>(0, (sum, category) => sum + (category['total'] as double));

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
                            'ค่าใช้จ่ายรวม',
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
                    expenseData: _expenses['seeds']!,
                    color: Colors.green,
                  ),
                  _buildExpenseCard(
                    title: 'ค่าสารเคมี',
                    icon: Icons.science,
                    expenseData: _expenses['chemicals']!,
                    color: Colors.purple,
                  ),
                  _buildExpenseCard(
                    title: 'ค่าน้ำ',
                    icon: Icons.water_drop,
                    expenseData: _expenses['water']!,
                    color: Colors.blue,
                  ),
                  _buildExpenseCard(
                    title: 'ค่าไฟ',
                    icon: Icons.electric_bolt,
                    expenseData: _expenses['electricity']!,
                    color: Colors.amber,
                  ),
                  _buildExpenseCard(
                    title: 'ค่าปุ๋ย',
                    icon: Icons.eco,
                    expenseData: _expenses['fertilizer']!,
                    color: Colors.brown,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
      ),
    );
  }
}