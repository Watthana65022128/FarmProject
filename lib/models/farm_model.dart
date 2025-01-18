class FarmModel {
  final int? id;
  final String name;
  final String startMonth;
  final String endMonth;
  final double? budget;

  FarmModel({
    this.id,
    required this.name,
    required this.startMonth,
    required this.endMonth,
    this.budget,
  });

  factory FarmModel.fromJson(Map<String, dynamic> json) {
    print('Parsing FarmModel from JSON: $json'); // เพิ่ม log
    return FarmModel(
      id: json['id'] != null ? int.parse(json['id'].toString()) : null,
      name: json['name'] ?? '',
      startMonth: json['startMonth'] ?? '',
      endMonth: json['endMonth'] ?? '',
      budget: json['budget'] != null ? double.parse(json['budget'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'startMonth': startMonth,
      'endMonth': endMonth,
      'budget': budget,
    };
  }

  FarmModel copyWith({
    int? id,
    String? name,
    String? startMonth,
    String? endMonth,
    double? budget,
  }) {
    return FarmModel(
      id: id ?? this.id,
      name: name ?? this.name,
      startMonth: startMonth ?? this.startMonth,
      endMonth: endMonth ?? this.endMonth,
      budget: budget ?? this.budget,
    );
  }

  @override
  String toString() {
    return 'FarmModel(id: $id, name: $name, startMonth: $startMonth, endMonth: $endMonth, budget: $budget)';
  }
}