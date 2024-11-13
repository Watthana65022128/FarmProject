class FarmModel {
  final int? id;
  final String name;
  final String startMonth;
  final String endMonth;

  FarmModel({
    this.id,
    required this.name,
    required this.startMonth,
    required this.endMonth,
  });

  // แปลงจาก JSON เป็น Model
  factory FarmModel.fromJson(Map<String, dynamic> json) {
    return FarmModel(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      name: json['name'] ?? '',
      startMonth: json['startMonth'] ?? '',
      endMonth: json['endMonth'] ?? '',
    );
  }

  // แปลงจาก Model เป็น JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'startMonth': startMonth,
      'endMonth': endMonth,
    };
  }

  // แปลงจาก Map เป็น Model (alias ของ fromJson เพื่อความเข้ากันได้กับโค้ดเดิม)
  factory FarmModel.fromMap(Map<String, dynamic> map) => FarmModel.fromJson(map);

  // แปลงจาก Model เป็น Map (alias ของ toJson เพื่อความเข้ากันได้กับโค้ดเดิม)
  Map<String, dynamic> toMap() => toJson();

  // สร้าง copy ของ Model พร้อมอัพเดทข้อมูลบางส่วน
  FarmModel copyWith({
    int? id,
    String? name,
    String? startMonth,
    String? endMonth,
  }) {
    return FarmModel(
      id: id ?? this.id,
      name: name ?? this.name,
      startMonth: startMonth ?? this.startMonth,
      endMonth: endMonth ?? this.endMonth,
    );
  }

  @override
  String toString() {
    return 'FarmModel(id: $id, name: $name, startMonth: $startMonth, endMonth: $endMonth)';
  }
}
