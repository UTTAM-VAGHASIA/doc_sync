class Accountant {
  final String accountantId;
  final String name;

  const Accountant({
    required this.accountantId,
    required this.name,
  });

  // toJson method for serialization
  Map<String, dynamic> toJson() {
    return {
      'id': accountantId,
      'accountant_name': name,
    };
  }

  // fromJson factory method for deserialization
  factory Accountant.fromJson(Map<String, dynamic> json) {
    return Accountant(
      accountantId: json['id'] ?? '',
      name: json['accountant_name'] ?? '',
    );
  }
} 