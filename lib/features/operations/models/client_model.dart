class Client {
  final String client_id;
  final String file_no;
  final String firm_name;
  final String contact_person;
  final String contact_no;
  final String accountant_id;
  final String status;
  final String pan;
  final String other_id;
  final String operation;

  Client({
    required this.client_id,
    required this.file_no,
    required this.firm_name,
    required this.contact_person,
    required this.contact_no,
    required this.accountant_id,
    required this.status,
    required this.pan,
    required this.other_id,
    required this.operation,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      client_id: json['id'] as String? ?? '',
      file_no: json['file_no'] as String? ?? '',
      firm_name: json['firm_name'] as String? ?? '',
      contact_person: json['contact_person'] as String? ?? '',
      contact_no: json['contact_no'] as String? ?? '',
      accountant_id: json['accountant_id'] as String? ?? '',
      status: json['status'] as String? ?? '',
      pan: json['pan'] as String? ?? '',
      other_id: json['other_id'] as String? ?? '',
      operation: json['operation'] as String? ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Client &&
          runtimeType == other.runtimeType &&
          client_id == other.client_id;

  @override
  int get hashCode => client_id.hashCode;
}
