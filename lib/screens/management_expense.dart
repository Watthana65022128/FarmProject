import 'package:flutter/material.dart';
import '../services/expense_service.dart';
import '../widgets/expense_category_detail.dart';

class ManagementExpensePage extends StatefulWidget {
  final int farmId;
  const ManagementExpensePage({super.key, required this.farmId});

  @override
  State<ManagementExpensePage> createState() => _ManagementExpensePageState();
}

class _ManagementExpensePageState extends State<ManagementExpensePage> {
  final ExpenseService _expenseService = ExpenseService();
  bool _isLoading = true;
  Map<String, dynamic> _expenses = {
    'equipment': {'total': 0.0, 'items': []},
    'labor': {'total': 0.0, 'items': []},
    'transportation': {'total': 0.0, 'items': []},
  };

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    try {
      setState(() => _isLoading = true);
      final expenses = await _expenseService.getManagementExpenses(widget.farmId);
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
    required String description,
  }) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _showCategoryDetail(
          title,
          List<Map<String, dynamic>>.from(expenseData['items']),
          color,
        ),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '฿${expenseData['total'].toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${expenseData['items'].length} รายการ',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ],
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('ค่าจัดการและการดูแล'),
        centerTitle: true,
        backgroundColor: const Color(0xFFF3FCEE),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadExpenses,
        child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Summary Card
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.settings,
                                color: Colors.orange,
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'ค่าใช้จ่ายรวมในการจัดการ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '฿${totalExpense.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Expense Cards
                    _buildExpenseCard(
                      title: 'ค่าอุปกรณ์',
                      icon: Icons.build,
                      expenseData: _expenses['equipment']!,
                      color: Colors.blue,
                      description: 'อุปกรณ์และเครื่องมือทางการเกษตร',
                    ),
                    _buildExpenseCard(
                      title: 'ค่าแรง',
                      icon: Icons.work,
                      expenseData: _expenses['labor']!,
                      color: Colors.green,
                      description: 'ค่าจ้างแรงงานในการทำการเกษตร',
                    ),
                    _buildExpenseCard(
                      title: 'ค่าขนส่ง',
                      icon: Icons.local_shipping,
                      expenseData: _expenses['transportation']!,
                      color: Colors.orange,
                      description: 'ค่าขนส่งและการเดินทาง',
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }
}