class TaskMaster {
  final String id;
  final String taskName;
  final String status; // 'enable' or 'disable'
  final String dateTime;

  TaskMaster({
    required this.id,
    required this.taskName,
    required this.status,
    required this.dateTime,
  });

  // toJson method for serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'task_name': taskName,
      'status': status,
      'date_time': dateTime,
    };
  }

  // fromJson factory method for deserialization
  factory TaskMaster.fromJson(Map<String, dynamic> json) {
    return TaskMaster(
      id: json['id'] ?? '',
      taskName: json['task_name'] ?? '',
      status: json['status']?.toString().toLowerCase() ?? 'disable',
      dateTime: json['date_time'] ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskMaster &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
} 