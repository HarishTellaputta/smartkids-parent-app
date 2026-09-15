
import 'mcq_question.dart';

class McqTest {
  final String id;
  final String title;
  final String subject;
  final String chapter;
  final String testDate;
  final String startTime;
  final int durationMinutes;
  final List<McqQuestion> questions;

  const McqTest({
    required this.id,
    required this.title,
    required this.subject,
    required this.chapter,
    required this.testDate,
    required this.startTime,
    required this.durationMinutes,
    required this.questions,
  });

  int get totalQuestions => questions.length;

  // ============================================================
  // DUMMY TEST
  // Later this will come from your backend API.
  // ============================================================

  factory McqTest.dummy() {
    return const McqTest(
      id: "TEST001",
      title: "Daily Mathematics Test",
      subject: "Mathematics",
      chapter: "Addition & Subtraction",
      testDate: "09 Aug 2026",
      startTime: "7:00 PM",
      durationMinutes: 15,
      questions: [
        McqQuestion(
          id: "Q001",
          question: "What is 25 + 15?",
          options: [
            "30",
            "35",
            "40",
            "45",
          ],
        ),

        McqQuestion(
          id: "Q002",
          question: "What is 50 - 20?",
          options: [
            "20",
            "25",
            "30",
            "35",
          ],
        ),

        McqQuestion(
          id: "Q003",
          question: "What is 8 + 7?",
          options: [
            "13",
            "14",
            "15",
            "16",
          ],
        ),

        McqQuestion(
          id: "Q004",
          question: "What is 100 - 45?",
          options: [
            "45",
            "50",
            "55",
            "65",
          ],
        ),

        McqQuestion(
          id: "Q005",
          question: "Which number is greater?",
          options: [
            "18",
            "25",
            "12",
            "20",
          ],
        ),

        McqQuestion(
          id: "Q006",
          question: "What is 12 + 18?",
          options: [
            "20",
            "25",
            "30",
            "35",
          ],
        ),

        McqQuestion(
          id: "Q007",
          question: "What is 40 - 15?",
          options: [
            "15",
            "20",
            "25",
            "30",
          ],
        ),

        McqQuestion(
          id: "Q008",
          question: "What is 6 + 9?",
          options: [
            "13",
            "14",
            "15",
            "16",
          ],
        ),

        McqQuestion(
          id: "Q009",
          question: "What is 75 - 25?",
          options: [
            "40",
            "45",
            "50",
            "55",
          ],
        ),

        McqQuestion(
          id: "Q010",
          question: "What is 10 + 20?",
          options: [
            "20",
            "25",
            "30",
            "40",
          ],
        ),
      ],
    );
  }

  // ============================================================
  // FROM JSON
  // This will be useful when connecting Spring Boot API.
  // ============================================================

  factory McqTest.fromJson(Map<String, dynamic> json) {
    return McqTest(
      id: json["id"]?.toString() ?? "",
      title: json["title"]?.toString() ?? "",
      subject: json["subject"]?.toString() ?? "",
      chapter: json["chapter"]?.toString() ?? "",
      testDate: json["testDate"]?.toString() ?? "",
      startTime: json["startTime"]?.toString() ?? "",
      durationMinutes:
          json["durationMinutes"] ?? 15,

      questions:
          (json["questions"] as List<dynamic>? ?? [])
              .map(
                (question) => McqQuestion.fromJson(
                  question as Map<String, dynamic>,
                ),
              )
              .toList(),
    );
  }

  // ============================================================
  // TO JSON
  // Useful when sending data to backend.
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "subject": subject,
      "chapter": chapter,
      "testDate": testDate,
      "startTime": startTime,
      "durationMinutes": durationMinutes,
      "questions":
          questions.map((question) {
        return question.toJson();
      }).toList(),
    };
  }
}
