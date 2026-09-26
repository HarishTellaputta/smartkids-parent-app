class AttendanceReport {
  final int studentId;
  final String? studentName;
  final String? studentRollNumber;
  final int? classId;
  final String? className;
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays;
  final int presentDays;
  final int absentDays;
  final int leaveDays;
  final double attendancePercentage;

  AttendanceReport({
    required this.studentId,
    this.studentName,
    this.studentRollNumber,
    this.classId,
    this.className,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.presentDays,
    required this.absentDays,
    required this.leaveDays,
    required this.attendancePercentage,
  });

  factory AttendanceReport.fromJson(
    Map<String, dynamic> json,
  ) {
    return AttendanceReport(
      studentId: json['studentId'],
      studentName: json['studentName'],
      studentRollNumber: json['studentRollNumber'],
      classId: json['classId'],
      className: json['className'],
      startDate: DateTime.parse(
        json['startDate'],
      ),
      endDate: DateTime.parse(
        json['endDate'],
      ),
      totalDays: json['totalDays'] ?? 0,
      presentDays: json['presentDays'] ?? 0,
      absentDays: json['absentDays'] ?? 0,
      leaveDays: json['leaveDays'] ?? 0,
      attendancePercentage:
          (json['attendancePercentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}