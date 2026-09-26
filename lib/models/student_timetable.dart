class StudentTimetable {
  final int id;

  final int teacherId;
  final String teacherName;

  final int classId;
  final String className;

  final int sectionId;
  final String sectionName;

  final int subjectId;
  final String subjectName;
  final String subjectCode;

  final String dayOfWeek;
  final String startTime;
  final String endTime;

  final String? roomNumber;

  StudentTimetable({
    required this.id,
    required this.teacherId,
    required this.teacherName,
    required this.classId,
    required this.className,
    required this.sectionId,
    required this.sectionName,
    required this.subjectId,
    required this.subjectName,
    required this.subjectCode,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.roomNumber,
  });

  factory StudentTimetable.fromJson(
    Map<String, dynamic> json,
  ) {
    return StudentTimetable(
      id: json['id'] as int,

      teacherId: json['teacherId'] as int,
      teacherName: json['teacherName'] ?? '',

      classId: json['classId'] as int,
      className: json['className'] ?? '',

      sectionId: json['sectionId'] as int,
      sectionName: json['sectionName'] ?? '',

      subjectId: json['subjectId'] as int,
      subjectName: json['subjectName'] ?? '',
      subjectCode: json['subjectCode'] ?? '',

      dayOfWeek: json['dayOfWeek'] ?? '',

      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',

      roomNumber: json['roomNumber'],
    );
  }
}