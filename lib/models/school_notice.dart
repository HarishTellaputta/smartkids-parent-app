class SchoolNotice {
  final int id;

  final String title;
  final String content;

  final String audience;
  final String category;
  final String status;

  final int? classId;
  final int? sectionId;

  final String className;
  final String sectionName;

  final String? publishedAt;
  final String createdAt;

  SchoolNotice({
    required this.id,
    required this.title,
    required this.content,
    required this.audience,
    required this.category,
    required this.status,
    this.classId,
    this.sectionId,
    required this.className,
    required this.sectionName,
    this.publishedAt,
    required this.createdAt,
  });

  factory SchoolNotice.fromJson(Map<String, dynamic> json) {
    return SchoolNotice(
      id: json['id'] as int,

      title: json['title'] ?? '',
      content: json['content'] ?? '',

      audience: json['audience'] ?? '',
      category: json['category'] ?? '',
      status: json['status'] ?? '',

      classId: json['classId'],
      sectionId: json['sectionId'],

      className: json['className'] ?? '',
      sectionName: json['sectionName'] ?? '',

      publishedAt: json['publishedAt'],
      createdAt: json['createdAt'] ?? '',
    );
  }
}