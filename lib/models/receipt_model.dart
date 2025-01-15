class Receipt {
  final String shopName;
  final DateTime receiptDate;
  final double totalAmount;
  final List<ReceiptItem> items;
  final String? imageUrl;

  Receipt({
    required this.shopName,
    required this.receiptDate,
    required this.totalAmount,
    required this.items,
    this.imageUrl,
  });

  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
      shopName: json['shopName'] ?? '',
      receiptDate: json['receiptDate'] != null 
        ? DateTime.parse(json['receiptDate']) 
        : DateTime.now(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'],
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => ReceiptItem.fromJson(item))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shopName': shopName,
      'receiptDate': receiptDate.toIso8601String(),
      'totalAmount': totalAmount,
      'imageUrl': imageUrl,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class ReceiptItem {
  final String description;
  final double amount;
  final int categoryId;

  ReceiptItem({
    required this.description,
    required this.amount,
    required this.categoryId,
  });

  factory ReceiptItem.fromJson(Map<String, dynamic> json) {
    return ReceiptItem(
      description: json['description'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      categoryId: json['categoryId'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'amount': amount,
      'categoryId': categoryId,
    };
  }
}