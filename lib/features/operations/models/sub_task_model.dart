class SubTask {
  final String id;
  final String subTaskName;
  final String? taskId;

  const SubTask({
    required this.id,
    required this.subTaskName,
    this.taskId,
  });

  // Add toJson method for serialization
  Map<String, dynamic> toJson() {
    return {
      'subtaskid': id,
      'subTaskName': subTaskName,
    };
  }

  factory SubTask.fromJson(Map<String, dynamic> json, ) {
    return SubTask(
      id: json['id'] ?? '',
      subTaskName: json['sub_task_name'] ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubTask &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
