class Group {
  final String groupId;
  final String groupName;
  final String status;

  const Group({
    required this.groupId,
    required this.groupName,
    required this.status,
  });

  // toJson method for serialization
  Map<String, dynamic> toJson() {
    return {
      'group_id': groupId,
      'group_name': groupName,
      'status': status,
    };
  }

  // fromJson factory method for deserialization
  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      groupId: json['group_id'] ?? '',
      groupName: json['group_name'] ?? '',
      status: json['status'] ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Group &&
          runtimeType == other.runtimeType &&
          groupId == other.groupId;

  @override
  int get hashCode => groupId.hashCode;
} 