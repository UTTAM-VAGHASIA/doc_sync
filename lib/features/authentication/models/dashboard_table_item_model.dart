// dashboard_table_item_model.dart

class DashboardTableItemModel {
  final int? id;
  final String? name;
  final int? pending;
  final int? alloted;
  final int? completed;
  final int? reAlloted;
  final int? awaitingClient;

  DashboardTableItemModel({
    this.id,
    this.name,
    this.pending,
    this.alloted,
    this.completed,
    this.reAlloted,
    this.awaitingClient,
  });

  
  factory DashboardTableItemModel.fromJson(Map<String, dynamic> json) {
    return DashboardTableItemModel(
      id: json['id'] as int?,
      name: json['name'] as String?,
      pending: json['pending'] as int?,
      alloted: json['alloted'] as int?,
      completed: json['completed'] as int?,
      reAlloted: json['re_alloted'] as int?,
      awaitingClient: json['awaiting_client'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'pending': pending,
      'alloted': alloted,
      'completed': completed,
      're_alloted': reAlloted,
      'awaiting_client': awaitingClient,
    };
  }

  @override
  String toString() {
    return 'DashboardTableItemModel(id: $id, name: $name, pending: $pending, alloted: $alloted, completed: $completed, reAlloted: $reAlloted, awaitingClient: $awaitingClient)';
  }
}