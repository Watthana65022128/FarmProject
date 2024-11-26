class User {
  final String username;
  final String email;
  final String? password;
  final String? age;
  final String? address;

  User({
    required this.username,
    required this.email,
    required this.password,
     this.age,
     this.address,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      email: json['email'],
      password: json['password'],
      age: json['age'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'age': age,
      'address': address,
    };
  }
}
