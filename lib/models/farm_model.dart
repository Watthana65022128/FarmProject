class FarmModel {
  final String name;
  final String startMonth;
  final String endMonth;

  FarmModel({
    required this.name,
    required this.startMonth,
    required this.endMonth,
  });

  factory FarmModel.fromJson(Map<String, dynamic> json) {
    return FarmModel(
      name: json['name'],
      startMonth: json['startMonths'],
      endMonth: json['endMonth'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'startMonth': startMonth,
      'endMonth': endMonth,
    };
  }
}