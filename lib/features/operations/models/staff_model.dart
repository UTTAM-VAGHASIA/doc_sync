class Staff {
  final String staff_id;
  final String staff_name;

  Staff({required this.staff_id, required this.staff_name});

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      staff_id: json['id'] as String? ?? '',
      staff_name: json['name'] as String? ?? 'Unknown Staff',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Staff &&
          runtimeType == other.runtimeType &&
          staff_id == other.staff_id;

  @override
  int get hashCode => staff_id.hashCode;
}
