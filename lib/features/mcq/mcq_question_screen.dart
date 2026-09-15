import 'dart:async';
import 'package:flutter/material.dart';

class McqQuestionScreen extends StatefulWidget {
  const McqQuestionScreen({super.key});

  @override
  State<McqQuestionScreen> createState() => _McqQuestionScreenState();
}

class _McqQuestionScreenState extends State<McqQuestionScreen> {
  // ============================================================
  // DUMMY QUESTIONS
  // Later replace this with API data.
  // answer = correct option index
  // ============================================================
  final List<Map<String, dynamic>> questions = [
    // =========================
    // MATHEMATICS
    // =========================
    {
      "question": "What is 25 + 15?",
      "options": ["30", "35", "40", "45"],
      "answer": 2,
    },
    {
      "question": "What is 50 - 20?",
      "options": ["20", "25", "30", "35"],
      "answer": 2,
    },
    {
      "question": "What is 8 + 7?",
      "options": ["13", "14", "15", "16"],
      "answer": 2,
    },

    // =========================
    // GENERAL KNOWLEDGE
    // =========================
    {
      "question": "What is the capital of India?",
      "options": ["Mumbai", "New Delhi", "Hyderabad", "Chennai"],
      "answer": 1,
    },
    {
      "question": "Which is the national animal of India?",
      "options": ["Lion", "Elephant", "Tiger", "Deer"],
      "answer": 2,
    },
    {
      "question": "Which is the national bird of India?",
      "options": ["Parrot", "Peacock", "Sparrow", "Crow"],
      "answer": 1,
    },
    {
      "question": "How many days are there in a week?",
      "options": ["5", "6", "7", "8"],
      "answer": 2,
    },
    {
      "question": "How many months are there in a year?",
      "options": ["10", "11", "12", "13"],
      "answer": 2,
    },

    // =========================
    // SCIENCE / EVS
    // =========================
    {
      "question": "Which planet do we live on?",
      "options": ["Mars", "Earth", "Jupiter", "Venus"],
      "answer": 1,
    },
    {
      "question": "Which part of the plant is usually green?",
      "options": ["Root", "Flower", "Leaf", "Fruit"],
      "answer": 2,
    },
    {
      "question": "Which animal gives us milk?",
      "options": ["Cow", "Lion", "Tiger", "Horse"],
      "answer": 0,
    },

    // =========================
    // ENGLISH
    // =========================
    {
      "question": "What is the opposite of 'Hot'?",
      "options": ["Warm", "Cold", "Big", "Fast"],
      "answer": 1,
    },
    {
      "question": "What is the plural of 'Child'?",
      "options": ["Childs", "Childes", "Children", "Childrens"],
      "answer": 2,
    },
    {
      "question": "Which word is a fruit?",
      "options": ["Apple", "Car", "Table", "Book"],
      "answer": 0,
    },

    // =========================
    // BASIC AWARENESS
    // =========================
    {
      "question": "Which one can fly?",
      "options": ["Dog", "Cat", "Bird", "Cow"],
      "answer": 2,
    },
    {
      "question": "Which color do we get by mixing red and yellow?",
      "options": ["Green", "Orange", "Blue", "Purple"],
      "answer": 1,
    },
    {
      "question": "Which animal is known as the King of the Jungle?",
      "options": ["Tiger", "Elephant", "Lion", "Bear"],
      "answer": 2,
    },
    {
      "question": "Which season is usually very hot?",
      "options": ["Winter", "Summer", "Rainy", "Spring"],
      "answer": 1,
    },
  ];
  // ============================================================
  // STATE
  // ============================================================

  int currentQuestion = 0;

  late List<int> selectedAnswers;

  // 15 minutes
  int remainingSeconds = 15 * 60;

  Timer? timer;

  bool isSubmitting = false;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    selectedAnswers = List<int>.filled(questions.length, -1);

    startTimer();
  }

  // ============================================================
  // TIMER
  // ============================================================

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      if (remainingSeconds <= 1) {
        timer.cancel();

        setState(() {
          remainingSeconds = 0;
        });

        _autoSubmit();

        return;
      }

      setState(() {
        remainingSeconds--;
      });
    });
  }

  String get formattedTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;

    return "${minutes.toString().padLeft(2, '0')}:"
        "${seconds.toString().padLeft(2, '0')}";
  }

  // ============================================================
  // SELECT ANSWER
  // ============================================================

  void selectAnswer(int optionIndex) {
    if (isSubmitting) return;

    setState(() {
      selectedAnswers[currentQuestion] = optionIndex;
    });
  }

  // ============================================================
  // NEXT
  // ============================================================

  void nextQuestion() {
    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;
      });
    }
  }

  // ============================================================
  // PREVIOUS
  // ============================================================

  void previousQuestion() {
    if (currentQuestion > 0) {
      setState(() {
        currentQuestion--;
      });
    }
  }

  // ============================================================
  // SUBMIT BUTTON
  // ============================================================

  Future<void> submitTest() async {
    if (isSubmitting) return;

    final unanswered = selectedAnswers.where((answer) => answer == -1).length;

    if (unanswered > 0) {
      final shouldSubmit = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: const Text(
              "Submit Test?",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Text(
              "You still have $unanswered "
              "unanswered question(s).\n\n"
              "Do you want to submit now?",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: const Text("Continue"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: const Text("Submit"),
              ),
            ],
          );
        },
      );

      if (shouldSubmit != true) return;
    }

    await _submitTest(autoSubmitted: false);
  }

  // ============================================================
  // AUTO SUBMIT
  // ============================================================

  Future<void> _autoSubmit() async {
    if (!mounted || isSubmitting) return;

    await _submitTest(autoSubmitted: true);
  }

  // ============================================================
  // SUBMIT
  // ============================================================

  Future<void> _submitTest({required bool autoSubmitted}) async {
    if (isSubmitting) return;

    setState(() {
      isSubmitting = true;
    });

    timer?.cancel();

    int score = 0;

    for (int i = 0; i < questions.length; i++) {
      final selected = selectedAnswers[i];
      final correct = questions[i]["answer"] as int;

      if (selected == correct) {
        score++;
      }
    }

    final correctAnswers = score;

    final wrongAnswers = selectedAnswers.where((answer) {
      if (answer == -1) return false;

      final index = selectedAnswers.indexOf(answer);

      return true;
    }).length;

    final unanswered = selectedAnswers.where((answer) => answer == -1).length;

    // Small delay only for demo.
    // Later this will be your API call.
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => McqResultScreen(
          totalQuestions: questions.length,
          score: score,
          correctAnswers: correctAnswers,
          wrongAnswers: wrongAnswers,
          unanswered: unanswered,
          autoSubmitted: autoSubmitted,
        ),
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final question = questions[currentQuestion];

    final questionText = question["question"] as String;

    final options = List<String>.from(question["options"]);

    final selectedAnswer = selectedAnswers[currentQuestion];

    final progress = (currentQuestion + 1) / questions.length;

    return Scaffold(
      backgroundColor: const Color(0xffF6F8FC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xff172033),
        elevation: 0,

        automaticallyImplyLeading: false,

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Daily Mathematics Test",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 2),

            Text(
              "Question ${currentQuestion + 1} "
              "of ${questions.length}",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),

        actions: [_timerWidget()],
      ),

      body: SafeArea(
        child: Column(
          children: [
            // Progress
            LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation(Color(0xff4169E1)),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question number
                    Text(
                      "Question ${currentQuestion + 1}",
                      style: const TextStyle(
                        color: Color(0xff4169E1),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Question card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        questionText,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 1.4,
                          color: Color(0xff172033),
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    const Text(
                      "Choose your answer",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Options
                    ...List.generate(options.length, (index) {
                      return _optionCard(
                        index: index,
                        text: options[index],
                        selected: selectedAnswer == index,
                      );
                    }),

                    const SizedBox(height: 25),

                    // Question navigator
                    _questionNavigator(),
                  ],
                ),
              ),
            ),

            // Bottom buttons
            _bottomNavigation(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TIMER WIDGET
  // ============================================================

  Widget _timerWidget() {
    final isLowTime = remainingSeconds <= 60;

    return Container(
      margin: const EdgeInsets.only(right: 12, top: 9, bottom: 9),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isLowTime ? const Color(0xffffe4e6) : const Color(0xffE8F0FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.timer_outlined,
            size: 18,
            color: isLowTime ? Colors.red : const Color(0xff4169E1),
          ),

          const SizedBox(width: 5),

          Text(
            formattedTime,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isLowTime ? Colors.red : const Color(0xff4169E1),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // OPTION CARD
  // ============================================================

  Widget _optionCard({
    required int index,
    required String text,
    required bool selected,
  }) {
    const letters = ["A", "B", "C", "D"];

    return GestureDetector(
      onTap: () {
        selectAnswer(index);
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),

        margin: const EdgeInsets.only(bottom: 12),

        padding: const EdgeInsets.all(15),

        decoration: BoxDecoration(
          color: selected ? const Color(0xffE8F0FF) : Colors.white,

          borderRadius: BorderRadius.circular(15),

          border: Border.all(
            color: selected ? const Color(0xff4169E1) : Colors.grey.shade300,

            width: selected ? 2 : 1,
          ),
        ),

        child: Row(
          children: [
            Container(
              height: 42,
              width: 42,

              alignment: Alignment.center,

              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xff4169E1)
                    : const Color(0xffF1F3F7),

                borderRadius: BorderRadius.circular(12),
              ),

              child: Text(
                letters[index],
                style: TextStyle(
                  fontWeight: FontWeight.bold,

                  color: selected ? Colors.white : Colors.black87,
                ),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,

              color: selected ? const Color(0xff4169E1) : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // QUESTION NAVIGATOR
  // ============================================================

  Widget _questionNavigator() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(18),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            "Questions",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,

            children: List.generate(questions.length, (index) {
              final answered = selectedAnswers[index] != -1;

              final current = index == currentQuestion;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    currentQuestion = index;
                  });
                },

                child: Container(
                  height: 38,
                  width: 38,

                  alignment: Alignment.center,

                  decoration: BoxDecoration(
                    color: current
                        ? const Color(0xff4169E1)
                        : answered
                        ? const Color(0xffDCFCE7)
                        : Colors.white,

                    borderRadius: BorderRadius.circular(10),

                    border: Border.all(
                      color: current
                          ? const Color(0xff4169E1)
                          : answered
                          ? Colors.green
                          : Colors.grey.shade300,
                    ),
                  ),

                  child: Text(
                    "${index + 1}",

                    style: TextStyle(
                      fontWeight: FontWeight.bold,

                      color: current
                          ? Colors.white
                          : answered
                          ? Colors.green.shade700
                          : Colors.black87,
                    ),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              _legend(color: const Color(0xff4169E1), text: "Current"),

              const SizedBox(width: 15),

              _legend(color: Colors.green, text: "Answered"),

              const SizedBox(width: 15),

              _legend(color: Colors.grey, text: "Not Answered"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legend({required Color color, required String text}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 9,
          width: 9,

          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),

        const SizedBox(width: 5),

        Text(text, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
      ],
    );
  }

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  Widget _bottomNavigation() {
    final isLastQuestion = currentQuestion == questions.length - 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),

      decoration: BoxDecoration(
        color: Colors.white,

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),

      child: Row(
        children: [
          // Previous
          if (currentQuestion > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: previousQuestion,

                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),

                child: const Text("Previous"),
              ),
            ),

          if (currentQuestion > 0) const SizedBox(width: 10),

          // Next / Submit
          Expanded(
            child: ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : isLastQuestion
                  ? submitTest
                  : nextQuestion,

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff4169E1),

                foregroundColor: Colors.white,

                disabledBackgroundColor: Colors.grey.shade300,

                minimumSize: const Size(double.infinity, 50),

                elevation: 0,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),

              child: isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      isLastQuestion ? "Submit Test" : "Next",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// RESULT SCREEN
// ============================================================================

class McqResultScreen extends StatelessWidget {
  final int totalQuestions;
  final int score;
  final int correctAnswers;
  final int wrongAnswers;
  final int unanswered;
  final bool autoSubmitted;

  const McqResultScreen({
    super.key,
    required this.totalQuestions,
    required this.score,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.unanswered,
    required this.autoSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = ((score / totalQuestions) * 100).round();

    final passed = percentage >= 40;

    return Scaffold(
      backgroundColor: const Color(0xffF6F8FC),

      appBar: AppBar(
        title: const Text(
          "Test Result",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        centerTitle: true,

        backgroundColor: Colors.white,

        foregroundColor: const Color(0xff172033),

        elevation: 0,

        automaticallyImplyLeading: false,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            children: [
              const SizedBox(height: 15),

              // Result icon
              Container(
                height: 90,
                width: 90,

                decoration: BoxDecoration(
                  color: passed
                      ? const Color(0xffDCFCE7)
                      : const Color(0xffffe4e6),

                  shape: BoxShape.circle,
                ),

                child: Icon(
                  passed
                      ? Icons.celebration_rounded
                      : Icons.sentiment_dissatisfied_rounded,

                  size: 50,

                  color: passed ? Colors.green : Colors.red,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                autoSubmitted ? "Test Auto-Submitted" : "Test Completed!",
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                autoSubmitted
                    ? "Time limit reached. "
                          "Your answers were submitted automatically."
                    : "Great job! "
                          "Your test has been submitted.",
                textAlign: TextAlign.center,

                style: TextStyle(color: Colors.grey.shade600, height: 1.4),
              ),

              const SizedBox(height: 30),

              // Score
              Container(
                width: double.infinity,

                padding: const EdgeInsets.symmetric(vertical: 30),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(22),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),

                      blurRadius: 15,
                    ),
                  ],
                ),

                child: Column(
                  children: [
                    Text(
                      "$score / $totalQuestions",

                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff4169E1),
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      "$percentage%",

                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: _stat(
                      icon: Icons.check_circle,
                      title: "Correct",
                      value: "$correctAnswers",
                      color: Colors.green,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _stat(
                      icon: Icons.cancel,
                      title: "Wrong",
                      value: "$wrongAnswers",
                      color: Colors.red,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _stat(
                      icon: Icons.remove_circle,
                      title: "Skipped",
                      value: "$unanswered",
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 52,

                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff4169E1),

                    foregroundColor: Colors.white,

                    elevation: 0,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),

                  child: const Text(
                    "Back to Home",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(16),
      ),

      child: Column(
        children: [
          Icon(icon, color: color, size: 25),

          const SizedBox(height: 7),

          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 3),

          Text(
            title,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
