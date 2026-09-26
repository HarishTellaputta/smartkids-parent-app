class AttendanceResponse {
  final int id;
  final int studentId;
  final String? studentName;
  final String? studentRollNumber;
  final int? classId;
  final String? className;
  final int? markedByTeacherId;
  final String? markedByTeacherName;
  final DateTime attendanceDate;
  final String? status;
  final String? remarks;
  final DateTime? markedAt;
  final DateTime? updatedAt;
  final int? updatedByTeacherId;
  final String? updatedByTeacherName;

  AttendanceResponse({
    required this.id,
    required this.studentId,
    this.studentName,
    this.studentRollNumber,
    this.classId,
    this.className,
    this.markedByTeacherId,
    this.markedByTeacherName,
    required this.attendanceDate,
    this.status,
    this.remarks,
    this.markedAt,
    this.updatedAt,
    this.updatedByTeacherId,
    this.updatedByTeacherName,
  });

  factory AttendanceResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return AttendanceResponse(
      id: json['id'],
      studentId: json['studentId'],
      studentName: json['studentName'],
      studentRollNumber: json['studentRollNumber'],
      classId: json['classId'],
      className: json['className'],
      markedByTeacherId: json['markedByTeacherId'],
      markedByTeacherName: json['markedByTeacherName'],
      attendanceDate: DateTime.parse(
        json['attendanceDate'],
      ),
      status: json['status'],
      remarks: json['remarks'],
      markedAt: json['markedAt'] != null
          ? DateTime.tryParse(json['markedAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
      updatedByTeacherId: json['updatedByTeacherId'],
      updatedByTeacherName: json['updatedByTeacherName'],
    );
  }
}