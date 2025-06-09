// Sub Task Master Model
// TODO: Implement Sub Task Master model 

class SubTaskMaster {
  final String id;
  final String taskId;
  final String taskName;
  final String subTaskName;
  final String amount;
  final String status; // 'enable' or 'disable'
  final String dateTime;

  SubTaskMaster({
    required this.id,
    required this.taskId,
    required this.taskName,
    required this.subTaskName,
    required this.amount,
    required this.status,
    required this.dateTime,
  });

  // toJson method for serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'task_id': taskId,
      'task_name': taskName,
      'sub_task_name': subTaskName,
      'amount': amount,
      'status': status,
      'date_time': dateTime,
    };
  }

  // fromJson factory method for deserialization
  factory SubTaskMaster.fromJson(Map<String, dynamic> json) {
    return SubTaskMaster(
      id: json['id'] ?? '',
      taskId: json['task_id'] ?? '',
      taskName: json['task_name'] ?? '',
      subTaskName: json['sub_task_name'] ?? '',
      amount: json['amount'] ?? '0',
      status: json['status']?.toString().toLowerCase() ?? 'disable',
      dateTime: json['date_time'] ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubTaskMaster &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
} 