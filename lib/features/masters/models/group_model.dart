class Group {
  final String id;
  final String clientGroupId;
  final String groupName;
  final String clientName;
  final String status; // 'enable' or 'disable'

  Group({
    required this.id,
    required this.clientGroupId,
    required this.groupName,
    required this.clientName,
    required this.status,
  });

  // toJson method for serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_group_id': clientGroupId,
      'group_name': groupName,
      'client_name': clientName,
      'status': status,
    };
  }

  // fromJson factory method for deserialization
  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'] ?? '',
      clientGroupId: json['client_group_id'] ?? '',
      groupName: json['group_name'] ?? '',
      clientName: json['client_name'] ?? '',
      status: json['status']?.toString().toLowerCase() ?? 'disable',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Group &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
} 