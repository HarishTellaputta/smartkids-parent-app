
class ParentFeedback {
  final int? id;
  final String type;
  final String subject;
  final String message;
  final DateTime? createdAt;
  final int? studentId;
  final String? studentName;
  final String? admissionNo;

  ParentFeedback({
    this.id,
    required this.type,
    required this.subject,
    required this.message,
    this.createdAt,
    this.studentId,
    this.studentName,
    this.admissionNo,
  });

  factory ParentFeedback.fromJson(Map<String, dynamic> json) {
    return ParentFeedback(
      id: json['id'] as int?,
      type: json['type']?.toString() ?? 'COMPLAINT',
      subject: json['subject']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      createdAt: DateTime.tryParse(
        json['createdAt']?.toString() ?? '',
      ),
      studentId: json['studentId'] as int?,
      studentName: json['studentName']?.toString(),
      admissionNo: json['admissionNo']?.toString(),
    );
  }

  Map<String, dynamic> toRequestJson() {
    return {
      'type': type,
      if (studentId != null) 'studentId': studentId,
      'subject': subject,
      'message': message,
    };
  }
}
