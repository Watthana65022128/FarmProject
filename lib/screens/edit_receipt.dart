import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/receipt_model.dart';
import '../services/receipt_service.dart';

class EditReceiptPage extends StatefulWidget {
  final Receipt receipt;
  final String imagePath;
  final int farmId;

  const EditReceiptPage({
    super.key,
    required this.receipt,
    required this.imagePath,
    required this.farmId,
  });

  @override
  State<EditReceiptPage> createState() => _EditReceiptPageState();
}

class _EditReceiptPageState extends State<EditReceiptPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _shopNameController;
  late DateTime _selectedDate;
  late List<ReceiptItem> _items;
  late double _totalAmount;
  final ReceiptService _receiptService = ReceiptService();
  bool _isLoading = false;
  final List<TextEditingController> _descriptionControllers = [];
  final List<TextEditingController> _amountControllers = [];

  @override
  void initState() {
    super.initState();
    _shopNameController = TextEditingController(text: widget.receipt.shopName);
    _selectedDate = widget.receipt.receiptDate;
    _items = List.from(widget.receipt.items);
    _totalAmount = widget.receipt.totalAmount;
    
    // Initialize controllers for each item
    for (var item in _items) {
      _descriptionControllers.add(TextEditingController(text: item.description));
      _amountControllers.add(TextEditingController(text: item.amount.toString()));
    }
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    for (var controller in _descriptionControllers) {
      controller.dispose();
    }
    for (var controller in _amountControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateTotal() {
    if (mounted) {
      double total = 0;
      for (var controller in _amountControllers) {
        total += double.tryParse(controller.text) ?? 0;
      }
      setState(() {
        _totalAmount = total;
      });
    }
  }

  void _addItem() {
    if (mounted) {
      setState(() {
        _items.add(ReceiptItem(
          description: '',
          amount: 0,
          categoryId: 1,
        ));
        _descriptionControllers.add(TextEditingController());
        _amountControllers.add(TextEditingController(text: '0'));
      });
    }
  }

  void _removeItem(int index) {
    if (mounted) {
      setState(() {
        _items.removeAt(index);
        _descriptionControllers[index].dispose();
        _amountControllers[index].dispose();
        _descriptionControllers.removeAt(index);
        _amountControllers.removeAt(index);
        _updateTotal();
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveReceipt() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      if (token == null) {
        throw Exception('กรุณาเข้าสู่ระบบใหม่');
      }

      // Create updated items list
      List<ReceiptItem> updatedItems = [];
      for (int i = 0; i < _items.length; i++) {
        updatedItems.add(ReceiptItem(
          description: _descriptionControllers[i].text,
          amount: double.parse(_amountControllers[i].text),
          categoryId: _items[i].categoryId,
        ));
      }

      final receipt = await _receiptService.createReceipt(
        shopName: _shopNameController.text,
        receiptDate: _selectedDate,
        totalAmount: _totalAmount,
        items: updatedItems,
        farmId: widget.farmId,
        imagePath: widget.imagePath,
        token: token,
      );

      if (context.mounted) {
        Navigator.of(context).pop();
        Navigator.of(context).pop(receipt);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('แก้ไขใบเสร็จ'),
        centerTitle: true,
        backgroundColor: const Color(0xFFF3FCEE),
        foregroundColor: Colors.black,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _shopNameController,
                      decoration: const InputDecoration(
                        labelText: 'ชื่อร้าน',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'กรุณาระบุชื่อร้าน';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: Text(
                        'วันที่: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      ),
                      onTap: _selectDate,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'รายการสินค้า',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: _descriptionControllers[index],
                                  decoration: const InputDecoration(
                                    labelText: 'รายการ',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'กรุณาระบุรายการ';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  controller: _amountControllers[index],
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'ราคา',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (value) {
                                    _updateTotal();
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'กรุณาระบุราคา';
                                    }
                                    if (double.tryParse(value) == null) {
                                      return 'กรุณาระบุตัวเลข';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeItem(index),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton.icon(
                        onPressed: _addItem,
                        icon: const Icon(Icons.add),
                        label: const Text('เพิ่มรายการ'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'ยอดรวม:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_totalAmount.toStringAsFixed(2)} บาท',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveReceipt,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('บันทึกใบเสร็จ'),
            ),
          ],
        ),
      ),
    );
  }
}