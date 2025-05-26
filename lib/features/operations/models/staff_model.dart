class Staff {
  final String staffId;
  final String staffName;
  final String? email;
  final String? phone;

  Staff({required this.staffId, required this.staffName, this.email, this.phone});

  // Add toJson method for serialization
  Map<String, dynamic> toJson() {
    return {'staff_id': staffId, 'staff_name': staffName, 'email': email, 'phone': phone};
  }

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      staffId: json['id'] ?? '',
      staffName: json['name'] ?? '',
      email: json['email'],
      phone: json['phone'],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Staff &&
          runtimeType == other.runtimeType &&
          staffId == other.staffId;

  @override
  int get hashCode => staffId.hashCode;
}
