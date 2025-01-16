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
        title: const Text('ค่าใช้จ่ายในการผลิต'),
        centerTitle: true,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadExpenses,
        child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Summary Section
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFFF3FCEE),
                          Colors.grey[50]!,
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: Card(
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
                                color: Colors.green.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.agriculture,
                                color: Colors.green,
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'ค่าใช้จ่ายรวมในการผลิต',
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
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Expense Cards
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildExpenseCard(
                          title: 'ค่าเมล็ดพันธุ์พืช',
                          icon: Icons.grass,
                          expenseData: _expenses['seeds']!,
                          color: Colors.green,
                          description: 'เมล็ดพันธุ์และต้นกล้าสำหรับการเพาะปลูก',
                        ),
                        _buildExpenseCard(
                          title: 'ค่าสารเคมี',
                          icon: Icons.science,
                          expenseData: _expenses['chemicals']!,
                          color: Colors.purple,
                          description: 'สารกำจัดศัตรูพืชและวัชพืช',
                        ),
                        _buildExpenseCard(
                          title: 'ค่าน้ำ',
                          icon: Icons.water_drop,
                          expenseData: _expenses['water']!,
                          color: Colors.blue,
                          description: 'น้ำสำหรับการเพาะปลูก',
                        ),
                        _buildExpenseCard(
                          title: 'ค่าไฟ',
                          icon: Icons.electric_bolt,
                          expenseData: _expenses['electricity']!,
                          color: Colors.amber,
                          description: 'ไฟฟ้าสำหรับระบบการเกษตร',
                        ),
                        _buildExpenseCard(
                          title: 'ค่าปุ๋ย',
                          icon: Icons.eco,
                          expenseData: _expenses['fertilizer']!,
                          color: Colors.brown,
                          description: 'ปุ๋ยและฮอร์โมนบำรุงพืช',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }
}