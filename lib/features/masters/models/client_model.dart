class Client {
  final String clientId;
  final String fileNo;
  final String firmName;
  final String contactPerson;
  final String gstn;
  final String tan;
  final String email;
  final String contactNo;
  final String accountantId;
  final String status;
  final String pan;
  final String otherId;
  final String operation;
  final String groupId;

  const Client({
    required this.clientId,
    required this.fileNo,
    required this.firmName,
    required this.contactPerson,
    required this.gstn,
    required this.tan,
    required this.email,
    required this.contactNo,
    required this.accountantId,
    required this.status,
    required this.pan,
    required this.otherId,
    required this.operation,
    required this.groupId,
  });

  // Add toJson method for serialization
  Map<String, dynamic> toJson() {
    return {
      'id': clientId,
      'file_no': fileNo,
      'firm_name': firmName,
      'contact_person': contactPerson,
      'gstn': gstn,
      'tan': tan,
      'email_id': email,
      'contact_no': contactNo,
      'accountant_id': accountantId,
      'status': status,
      'pan': pan,
      'other_id': otherId,
      'operation': operation,
      'group_id': groupId,
    };
  }

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      clientId: json['id'] ?? '',
      fileNo: json['file_no'] ?? '',
      firmName: json['firm_name'] ?? '',
      contactPerson: json['contact_person'] ?? '',
      gstn: json['gstn'] ?? '',
      tan: json['tan'] ?? '',
      email: json['email_id'] ?? '',
      contactNo: json['contact_no'] ?? '',
      accountantId: json['accountant_id'] ?? '',
      status: json['status'] ?? '',
      pan: json['pan'] ?? '',
      otherId: json['other_id'] ?? '',
      operation: json['operation'] ?? '',
      groupId: json['group_id'] ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Client &&
          runtimeType == other.runtimeType &&
          clientId == other.clientId;

  @override
  int get hashCode => clientId.hashCode;
}
