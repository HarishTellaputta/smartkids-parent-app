class McqQuestion {
  final String id;
  final String question;
  final List<String> options;

  const McqQuestion({
    required this.id,
    required this.question,
    required this.options,
  });

  // ============================================================
  // FROM JSON
  // Used when receiving question from Spring Boot API
  // ============================================================

  factory McqQuestion.fromJson(Map<String, dynamic> json) {
    return McqQuestion(
      id: json['id']?.toString() ?? '',
      question: json['question']?.toString() ?? '',

      options: (json['options'] as List<dynamic>? ?? [])
          .map((option) => option.toString())
          .toList(),
    );
  }

  // ============================================================
  // TO JSON
  // Used when sending question data
  // ============================================================

  Map<String, dynamic> toJson() {
    return {'id': id, 'question': question, 'options': options};
  }

  // ============================================================
  // COPY WITH
  // Useful when updating question locally
  // ============================================================

  McqQuestion copyWith({String? id, String? question, List<String>? options}) {
    return McqQuestion(
      id: id ?? this.id,
      question: question ?? this.question,
      options: options ?? this.options,
    );
  }
}
