class Homework {
  final int id;

  final int classId;
  final String className;

  final int sectionId;
  final String sectionName;

  final int assignedByTeacherId;
  final String assignedByTeacherName;
  final String teacherEmployeeId;

  final int subjectId;
  final String subjectName;
  final String subjectCode;

  final String title;
  final String description;

  final String dueDate;

  final String status;

  final String? attachmentUrl;

  final String priority;

  final String createdAt;
  final String updatedAt;

  Homework({
    required this.id,
    required this.classId,
    required this.className,
    required this.sectionId,
    required this.sectionName,
    required this.assignedByTeacherId,
    required this.assignedByTeacherName,
    required this.teacherEmployeeId,
    required this.subjectId,
    required this.subjectName,
    required this.subjectCode,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.status,
    this.attachmentUrl,
    required this.priority,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Homework.fromJson(Map<String, dynamic> json) {
    return Homework(
      id: json['id'] as int,

      classId: json['classId'] as int,
      className: json['className'] ?? '',

      sectionId: json['sectionId'] as int,
      sectionName: json['sectionName'] ?? '',

      assignedByTeacherId:
          json['assignedByTeacherId'] as int,
      assignedByTeacherName:
          json['assignedByTeacherName'] ?? '',
      teacherEmployeeId:
          json['teacherEmployeeId'] ?? '',

      subjectId: json['subjectId'] as int,
      subjectName: json['subjectName'] ?? '',
      subjectCode: json['subjectCode'] ?? '',

      title: json['title'] ?? '',
      description: json['description'] ?? '',

      dueDate: json['dueDate'] ?? '',

      status: json['status'] ?? '',

      attachmentUrl: json['attachmentUrl'],

      priority: json['priority'] ?? '',

      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}