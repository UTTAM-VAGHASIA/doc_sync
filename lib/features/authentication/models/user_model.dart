class User {
  final String? id;
  final String? name;
  final String? contact;
  final String? email;
  final String? password;
  final String? type;
  final String? status;
  final String? dateTime;

  User({
    required this.id,
    required this.name,
    required this.contact,
    required this.email,
    required this.password,
    required this.type,
    required this.status,
    required this.dateTime,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      contact: json['contact'],
      email: json['email'],
      password: json['password'],
      type: json['type'],
      status: json['status'],
      dateTime: json['date_time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contact': contact,
      'email': email,
      'password': password,
      'type': type,
      'status': status,
      'date_time': dateTime,
    };
  }

  Map<String, dynamic> toJsonWithoutPassword() {
    return {
      'id': id,
      'name': name,
      'contact': contact,
      'email': email,
      'type': type,
      'status': status,
      'date_time': dateTime,
    };
  }
}
