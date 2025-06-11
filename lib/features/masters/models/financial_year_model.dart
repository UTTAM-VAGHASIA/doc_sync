class FinancialYear {
  final String fId;
  final String year;
  final String addBy;
  final String createdOn;

  FinancialYear({
    required this.fId,
    required this.year,
    required this.addBy,
    required this.createdOn,
  });

  // toJson method for serialization
  Map<String, dynamic> toJson() {
    return {
      'f_id': fId,
      'year': year,
      'add_by': addBy,
      'created_on': createdOn,
    };
  }

  // fromJson factory method for deserialization
  factory FinancialYear.fromJson(Map<String, dynamic> json) {
    return FinancialYear(
      fId: json['f_id'] ?? '',
      year: json['year'] ?? '',
      addBy: json['add_by'] ?? '',
      createdOn: json['created_on'] ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FinancialYear &&
          runtimeType == other.runtimeType &&
          fId == other.fId;

  @override
  int get hashCode => fId.hashCode;
} 