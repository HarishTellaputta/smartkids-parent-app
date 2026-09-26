
class McqQuestion {
  final int id;
  final String question;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final int marks;

  const McqQuestion({
    required this.id,
    required this.question,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.marks,
  });

  List<String> get options => [
        optionA,
        optionB,
        optionC,
        optionD,
      ];

  factory McqQuestion.fromJson(Map<String, dynamic> json) {
    return McqQuestion(
      id: int.tryParse(
            json['id']?.toString() ?? '',
          ) ??
          0,

      question: json['question']?.toString() ?? '',

      optionA: json['optionA']?.toString() ?? '',

      optionB: json['optionB']?.toString() ?? '',

      optionC: json['optionC']?.toString() ?? '',

      optionD: json['optionD']?.toString() ?? '',

      marks: int.tryParse(
            json['marks']?.toString() ?? '',
          ) ??
          0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'optionA': optionA,
      'optionB': optionB,
      'optionC': optionC,
      'optionD': optionD,
      'marks': marks,
    };
  }

  McqQuestion copyWith({
    int? id,
    String? question,
    String? optionA,
    String? optionB,
    String? optionC,
    String? optionD,
    int? marks,
  }) {
    return McqQuestion(
      id: id ?? this.id,
      question: question ?? this.question,
      optionA: optionA ?? this.optionA,
      optionB: optionB ?? this.optionB,
      optionC: optionC ?? this.optionC,
      optionD: optionD ?? this.optionD,
      marks: marks ?? this.marks,
    );
  }
}

