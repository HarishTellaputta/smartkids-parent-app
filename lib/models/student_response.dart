class StudentResponse {
  final int id;
  final String? admissionNo;
  final String name;
  final String? email;
  final String? phone;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? bloodGroup;
  final DateTime? admissionDate;

  final int? classId;
  final String? className;

  final int? sectionId;
  final String? sectionName;

  final int? parentId;
  final String? parentName;

  final int? academicYearId;
  final String? academicYearName;

  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  StudentResponse({
    required this.id,
    this.admissionNo,
    required this.name,
    this.email,
    this.phone,
    this.dateOfBirth,
    this.gender,
    this.bloodGroup,
    this.admissionDate,
    this.classId,
    this.className,
    this.sectionId,
    this.sectionName,
    this.parentId,
    this.parentName,
    this.academicYearId,
    this.academicYearName,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory StudentResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return StudentResponse(
      id: json['id'],
      admissionNo: json['admissionNo'],
      name: json['name'] ?? '',
      email: json['email'],
      phone: json['phone'],

      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'])
          : null,

      gender: json['gender'],
      bloodGroup: json['bloodGroup'],

      admissionDate: json['admissionDate'] != null
          ? DateTime.tryParse(json['admissionDate'])
          : null,

      classId: json['classId'],
      className: json['className'],

      sectionId: json['sectionId'],
      sectionName: json['sectionName'],

      parentId: json['parentId'],
      parentName: json['parentName'],

      academicYearId: json['academicYearId'],
      academicYearName: json['academicYearName'],

      status: json['status'],

      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,

      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }
}