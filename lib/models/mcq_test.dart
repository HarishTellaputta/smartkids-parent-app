
import 'mcq_question.dart';

class McqTest {
  final int id;
  final int? classId;
  final int? sectionId;
  final String? className;
  final String? sectionName;
  final String subject;
  final String date;
  final String startTime;
  final int duration;
  final int numberOfQuestions;
  final String status;
  final List<McqQuestion> questions;

  const McqTest({
    required this.id,
    this.classId,
    this.sectionId,
    this.className,
    this.sectionName,
    required this.subject,
    required this.date,
    required this.startTime,
    required this.duration,
    required this.numberOfQuestions,
    required this.status,
    required this.questions,
  });

  int get totalQuestions => questions.length;

  factory McqTest.fromJson(Map<String, dynamic> json) {
    return McqTest(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,

      classId: json['classId'] == null
          ? null
          : int.tryParse(json['classId'].toString()),

      sectionId: json['sectionId'] == null
          ? null
          : int.tryParse(json['sectionId'].toString()),

      className: json['className']?.toString(),

      sectionName: json['sectionName']?.toString(),

      subject: json['subject']?.toString() ?? '',

      date: json['date']?.toString() ?? '',

      startTime: json['startTime']?.toString() ?? '',

      duration: int.tryParse(
            json['duration']?.toString() ?? '',
          ) ??
          0,

      numberOfQuestions: int.tryParse(
            json['numberOfQuestions']?.toString() ?? '',
          ) ??
          0,

      status: json['status']?.toString() ?? '',

      questions:
          (json['questions'] as List<dynamic>? ?? [])
              .whereType<Map<String, dynamic>>()
              .map(
                (question) => McqQuestion.fromJson(question),
              )
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'classId': classId,
      'sectionId': sectionId,
      'className': className,
      'sectionName': sectionName,
      'subject': subject,
      'date': date,
      'startTime': startTime,
      'duration': duration,
      'numberOfQuestions': numberOfQuestions,
      'status': status,
      'questions': questions
          .map((question) => question.toJson())
          .toList(),
    };
  }
}

