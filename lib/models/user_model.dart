class User {
  final String? id;
  final String username;
  final String email;
  final String? password;
  final String? age;
  final String? address;
  final bool? isAdmin;
  final bool? isBanned;
  final String? bannedReason;
  final DateTime? bannedAt;

  User({
    this.id,
    required this.username,
    required this.email,
    this.password,
    this.age,
    this.address,
    this.isAdmin = false,
    this.isBanned = false,
    this.bannedReason,
    this.bannedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString(),
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      password: json['password'],
      age: json['age']?.toString(),
      address: json['address'],
      isAdmin: json['isAdmin'] ?? false,
      isBanned: json['isBanned'] ?? false,
      bannedReason: json['bannedReason'],
      bannedAt: json['bannedAt'] != null 
        ? DateTime.parse(json['bannedAt']) 
        : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'age': age,
      'address': address,
      'isAdmin': isAdmin,
      'isBanned': isBanned,
      'bannedReason': bannedReason,
      'bannedAt': bannedAt?.toIso8601String(),
    };
  }
}