import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/receipt_model.dart';
import '../services/receipt_service.dart';
import '../auth/auth_service.dart';

class TransactionListPage extends StatefulWidget {
  final int farmId;
  
  const TransactionListPage({
    super.key,
    required this.farmId,
  });

  @override
  State<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage> {
  String _selectedFilter = 'today';
  List<Receipt> _receipts = [];
  bool _isLoading = false;
  final ReceiptService _receiptService = ReceiptService();
  final AuthService _authService = AuthService();

  final List<Map<String, dynamic>> _filterOptions = [
    {'key': 'today', 'label': 'วันนี้'},
    {'key': 'week', 'label': 'สัปดาห์นี้'},
    {'key': 'month', 'label': '1 เดือน'},
    {'key': 'threeMonths', 'label': '3 เดือน'},
    {'key': 'sixMonths', 'label': '6 เดือน'},
  ];

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    final token = await _authService.getToken();
    if (token != null) {
      _receiptService.setToken(token);
      _fetchReceipts();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('กรุณาเข้าสู่ระบบใหม่')),
        );
      }
    }
  }

  Future<void> _fetchReceipts() async {
    setState(() => _isLoading = true);
    
    try {
      final receipts = await _receiptService.getReceipts(
        farmId: widget.farmId,
        dateFilter: _selectedFilter,
      );
      
      if (mounted) {
        setState(() {
          _receipts = receipts;
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

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: _filterOptions.map((filter) {
          final isSelected = _selectedFilter == filter['key'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter['label']),
              selected: isSelected,
              onSelected: (_) {
                setState(() => _selectedFilter = filter['key']);
                _fetchReceipts();
              },
              selectedColor: Colors.green.withOpacity(0.2),
              checkmarkColor: Colors.green,
              backgroundColor: Colors.grey.withOpacity(0.1),
              labelStyle: TextStyle(
                color: isSelected ? Colors.green : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTransactionList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_receipts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'ไม่พบรายการธุรกรรม',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchReceipts,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _receipts.length,
        itemBuilder: (context, index) {
          final receipt = _receipts[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                // TODO: Navigate to receipt detail
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.receipt, color: Colors.green),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                receipt.shopName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('dd/MM/yyyy HH:mm').format(receipt.receiptDate),
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '฿${NumberFormat("#,##0.00").format(receipt.totalAmount)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${receipt.items.length} รายการ',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFilterChips(),
        const Divider(height: 1),
        Expanded(
          child: _buildTransactionList(),
        ),
      ],
    );
  }
}