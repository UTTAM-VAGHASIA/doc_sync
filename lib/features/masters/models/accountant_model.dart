class Accountant {
  final String id;
  final String accountantName;
  final String contact1;
  final String contact2;
  final String status;
  final String dateTime;

  Accountant({
    required this.id,
    required this.accountantName,
    required this.contact1,
    required this.contact2,
    required this.status,
    required this.dateTime,
  });

  // toJson method for serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountant_name': accountantName,
      'contact1': contact1,
      'contact2': contact2,
      'status': status,
      'date_time': dateTime,
    };
  }

  // fromJson factory method for deserialization
  factory Accountant.fromJson(Map<String, dynamic> json) {
    return Accountant(
      id: json['id'] ?? '',
      accountantName: json['accountant_name'] ?? '',
      contact1: json['contact1'] ?? '',
      contact2: json['contact2'] ?? '',
      status: json['status']?.toString().toLowerCase() ?? 'disable',
      dateTime: json['date_time'] ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Accountant &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
} 