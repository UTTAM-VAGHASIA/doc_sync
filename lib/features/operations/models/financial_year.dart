class FinancialYear {
  final String financial_year_id;
  final String financial_year;

  FinancialYear({
    required this.financial_year_id,
    required this.financial_year,
  });

  factory FinancialYear.fromJson(Map<String, dynamic> json) {
    return FinancialYear(
      financial_year_id: json['f_id'] as String? ?? '',
      financial_year: json['year'] as String? ?? 'Unknown FinancialYear',
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
