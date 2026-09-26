class StudentFeeResponse {
  final int id;
  final int studentId;
  final int? feeStructureId;
  final String? studentName;
  final String? feeName;
  final String? status;
  final double totalAmount;
  final double paidAmount;
  final double pendingAmount;
  final DateTime? dueDate;

  StudentFeeResponse({
    required this.id,
    required this.studentId,
    this.feeStructureId,
    this.studentName,
    this.feeName,
    this.status,
    required this.totalAmount,
    required this.paidAmount,
    required this.pendingAmount,
    this.dueDate,
  });

  factory StudentFeeResponse.fromJson(Map<String, dynamic> json) {
    return StudentFeeResponse(
      id: json['id'],
      studentId: json['studentId'],
      feeStructureId: json['feeStructureId'],
      studentName: json['studentName'],
      feeName: json['feeName'],
      status: json['status'],
      totalAmount: _toDouble(json['totalAmount']),
      paidAmount: _toDouble(json['paidAmount']),
      pendingAmount: _toDouble(json['pendingAmount']),
      dueDate: json['dueDate'] != null
          ? DateTime.tryParse(json['dueDate'])
          : null,
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0.0;
  }
}