class StudentBirthdayChat {
  final int studentId;
  final String studentName;
  final String admissionNo;
  final DateTime dateOfBirth;
  final DateTime birthdayDate;
  final bool birthdayToday;
  final bool photoAlreadyAdded;
  final int? birthdayStatusId;
  final String? photoUrl;
  final String? message;

  StudentBirthdayChat({
    required this.studentId,
    required this.studentName,
    required this.admissionNo,
    required this.dateOfBirth,
    required this.birthdayDate,
    required this.birthdayToday,
    required this.photoAlreadyAdded,
    this.birthdayStatusId,
    this.photoUrl,
    this.message,
  });

  factory StudentBirthdayChat.fromJson(Map<String, dynamic> json) {
    return StudentBirthdayChat(
      studentId: json['studentId'] as int,
      studentName: json['studentName'] ?? '',
      admissionNo: json['admissionNo'] ?? '',
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      birthdayDate: DateTime.parse(json['birthdayDate']),
      birthdayToday: json['birthdayToday'] ?? false,
      photoAlreadyAdded: json['photoAlreadyAdded'] ?? false,
      birthdayStatusId: json['birthdayStatusId'],
      photoUrl: json['photoUrl'],
      message: json['message'],
    );
  }
}