class FinancialYear {
  final String financial_year_id;
  final String financial_year;

  const FinancialYear({
    required this.financial_year_id,
    required this.financial_year,
  });

  // Add toJson method for serialization
  Map<String, dynamic> toJson() {
    return {
      'financial_year_id': financial_year_id,
      'financial_year': financial_year,
    };
  }

  factory FinancialYear.fromJson(Map<String, dynamic> json) {
    return FinancialYear(
      financial_year_id: json['f_id'] ?? '',
      financial_year: json['year'] ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FinancialYear &&
          runtimeType == other.runtimeType &&
          financial_year_id == other.financial_year_id;

  @override
  int get hashCode => financial_year_id.hashCode;
}
