import 'student_response.dart';

class ParentResponse {
  final int id;
  final String? fatherName;
  final String? motherName;
  final String? guardianName;
  final String? contactPhone;
  final String? contactEmail;
  final String? relationship;
  final String? address;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<StudentResponse> students;

  ParentResponse({
    required this.id,
    this.fatherName,
    this.motherName,
    this.guardianName,
    this.contactPhone,
    this.contactEmail,
    this.relationship,
    this.address,
    this.createdAt,
    this.updatedAt,
    required this.students,
  });

  factory ParentResponse.fromJson(Map<String, dynamic> json) {
    return ParentResponse(
      id: json['id'],
      fatherName: json['fatherName'],
      motherName: json['motherName'],
      guardianName: json['guardianName'],
      contactPhone: json['contactPhone'],
      contactEmail: json['contactEmail'],
      relationship: json['relationship'],
      address: json['address'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
      students: (json['students'] as List<dynamic>? ?? [])
          .map(
            (student) => StudentResponse.fromJson(
              student as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }
}