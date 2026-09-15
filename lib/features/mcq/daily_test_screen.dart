import 'dart:async';
import 'package:flutter/material.dart';
import 'package:parent_app/models/mcq_test.dart';

class DailyTestScreen extends StatefulWidget {
  final McqTest test;

  const DailyTestScreen({super.key, required this.test});

  @override
  State<DailyTestScreen> createState() => _DailyTestScreenState();
}

class _DailyTestScreenState extends State<DailyTestScreen> {
  // ============================================================
  // DUMMY TEST DATA
  // Later this data will come from your Spring Boot API.
  // ============================================================

  final String testTitle = "Daily Test";
  final String subject = "Mathematics and Knowledge ";
  final String chapter = "Chapter 3 - Addition & Subtraction";

  final int testDurationMinutes = 15;
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

  int currentQuestionIndex = 0;

  // Stores selected option for each question.
  // -1 means unanswered.
  late List<int> selectedAnswers;

  Timer? timer;

  int remainingSeconds = 15 * 60;

  bool testStarted = false;
  bool testSubmitted = false;
  bool autoSubmitted = false;

  int score = 0;
  int correctAnswers = 0;
  int wrongAnswers = 0;
  int unanswered = 0;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    selectedAnswers = List<int>.filled(questions.length, -1);
  }

  // ============================================================
  // START TEST
  // ============================================================

  void startTest() {
    setState(() {
      testStarted = true;
      remainingSeconds = testDurationMinutes * 60;
    });

    startTimer();
  }

  // ============================================================
  // TIMER
  // ============================================================

  void startTimer() {
    timer?.cancel();

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      if (remainingSeconds <= 1) {
        timer.cancel();

        setState(() {
          remainingSeconds = 0;
        });

        autoSubmitTest();
      } else {
        setState(() {
          remainingSeconds--;
        });
      }
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
    if (testSubmitted) return;

    setState(() {
      selectedAnswers[currentQuestionIndex] = optionIndex;
    });
  }

  // ============================================================
  // NEXT QUESTION
  // ============================================================

  void nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    }
  }

  // ============================================================
  // PREVIOUS QUESTION
  // ============================================================

  void previousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
      });
    }
  }

  // ============================================================
  // MANUAL SUBMIT
  // ============================================================

  Future<void> submitTest() async {
    if (testSubmitted) return;

    final shouldSubmit = await showDialog<bool>(
      context: context,
      builder: (context) {
        final answered = selectedAnswers.where((answer) => answer != -1).length;

        return AlertDialog(
          title: const Text("Submit Test?"),
          content: Text(
            "You have answered $answered "
            "out of ${questions.length} questions.\n\n"
            "Are you sure you want to submit?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text("Continue Test"),
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

    if (shouldSubmit == true) {
      calculateResult(auto: false);
    }
  }

  // ============================================================
  // AUTO SUBMIT
  // ============================================================

  void autoSubmitTest() {
    if (testSubmitted) return;

    calculateResult(auto: true);
  }

  // ============================================================
  // CALCULATE RESULT
  // ============================================================

  void calculateResult({required bool auto}) {
    timer?.cancel();

    int correct = 0;
    int wrong = 0;
    int empty = 0;

    for (int i = 0; i < questions.length; i++) {
      final selected = selectedAnswers[i];
      final correctAnswer = questions[i]["answer"] as int;

      if (selected == -1) {
        empty++;
      } else if (selected == correctAnswer) {
        correct++;
      } else {
        wrong++;
      }
    }

    setState(() {
      correctAnswers = correct;
      wrongAnswers = wrong;
      unanswered = empty;

      score = correct;

      testSubmitted = true;
      autoSubmitted = auto;
    });
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
    if (!testStarted) {
      return _buildTestIntroduction();
    }

    if (testSubmitted) {
      return _buildResultScreen();
    }

    return _buildTestScreen();
  }

  // ============================================================
  // TEST INTRODUCTION
  // ============================================================

  Widget _buildTestIntroduction() {
    return Scaffold(
      backgroundColor: const Color(0xffF6F8FC),
      appBar: AppBar(
        title: const Text(
          "Daily MCQ Test",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Icon
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: const Color(0xffE8F0FF),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.quiz_rounded,
                  size: 55,
                  color: Color(0xff4169E1),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                testTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff172033),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                chapter,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
              ),

              const SizedBox(height: 30),

              _infoCard(
                icon: Icons.menu_book_rounded,
                title: "Subject",
                value: subject,
              ),

              _infoCard(
                icon: Icons.help_outline_rounded,
                title: "Questions",
                value: "${questions.length} Questions",
              ),

              _infoCard(
                icon: Icons.timer_outlined,
                title: "Duration",
                value: "$testDurationMinutes Minutes",
              ),

              _infoCard(
                icon: Icons.access_time_rounded,
                title: "Test Time",
                value: "7:00 PM",
              ),

              const SizedBox(height: 25),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xffFFF8E1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xffFFE082)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Color(0xffF59E0B)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "You have 15 minutes to complete this test. "
                        "The test will be submitted automatically when "
                        "the time expires.",
                        style: TextStyle(fontSize: 13, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: startTest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff4169E1),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Start Test",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              Text(
                "Please make sure you have a stable internet connection.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TEST SCREEN
  // ============================================================

  Widget _buildTestScreen() {
    final question = questions[currentQuestionIndex];

    final String questionText = question["question"];
    final List<String> options = List<String>.from(question["options"]);

    final int correctAnswer = question["answer"];

    return Scaffold(
      backgroundColor: const Color(0xffF6F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              testTitle,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              "Question ${currentQuestionIndex + 1} of ${questions.length}",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12, top: 10, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: remainingSeconds <= 60
                  ? Colors.red.shade50
                  : const Color(0xffE8F0FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 18,
                  color: remainingSeconds <= 60
                      ? Colors.red
                      : const Color(0xff4169E1),
                ),
                const SizedBox(width: 5),
                Text(
                  formattedTime,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: remainingSeconds <= 60
                        ? Colors.red
                        : const Color(0xff4169E1),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            LinearProgressIndicator(
              value: (currentQuestionIndex + 1) / questions.length,
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
                    Text(
                      "Question ${currentQuestionIndex + 1}",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff4169E1),
                      ),
                    ),

                    const SizedBox(height: 12),

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

                    const SizedBox(height: 20),

                    ...List.generate(options.length, (index) {
                      final isSelected =
                          selectedAnswers[currentQuestionIndex] == index;

                      return _optionCard(
                        optionIndex: index,
                        optionText: options[index],
                        isSelected: isSelected,
                        onTap: () {
                          selectAnswer(index);
                        },
                      );
                    }),

                    const SizedBox(height: 25),

                    // Question navigator
                    const Text(
                      "Questions",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(questions.length, (index) {
                        final answered = selectedAnswers[index] != -1;

                        final isCurrent = index == currentQuestionIndex;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              currentQuestionIndex = index;
                            });
                          },
                          child: Container(
                            height: 38,
                            width: 38,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isCurrent
                                  ? const Color(0xff4169E1)
                                  : answered
                                  ? const Color(0xffDCFCE7)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isCurrent
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
                                color: isCurrent
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
                  ],
                ),
              ),
            ),

            // Bottom navigation
            Container(
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
                  if (currentQuestionIndex > 0)
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

                  if (currentQuestionIndex > 0) const SizedBox(width: 10),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: currentQuestionIndex == questions.length - 1
                          ? submitTest
                          : nextQuestion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff4169E1),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        currentQuestionIndex == questions.length - 1
                            ? "Submit Test"
                            : "Next",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // OPTION CARD
  // ============================================================

  Widget _optionCard({
    required int optionIndex,
    required String optionText,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final letters = ["A", "B", "C", "D"];

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xffE8F0FF) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? const Color(0xff4169E1) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xff4169E1)
                    : const Color(0xffF1F3F7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                letters[optionIndex],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Text(
                optionText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected
                  ? const Color(0xff4169E1)
                  : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // RESULT SCREEN
  // ============================================================

  Widget _buildResultScreen() {
    final percentage = ((score / questions.length) * 100).round();

    return Scaffold(
      backgroundColor: const Color(0xffF6F8FC),
      appBar: AppBar(
        title: const Text(
          "Test Result",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
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
                  color: percentage >= 60
                      ? const Color(0xffDCFCE7)
                      : const Color(0xffffe4e6),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  percentage >= 60
                      ? Icons.celebration_rounded
                      : Icons.sentiment_dissatisfied_rounded,
                  size: 50,
                  color: percentage >= 60 ? Colors.green : Colors.red,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                autoSubmitted ? "Test Auto-Submitted" : "Test Completed!",
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff172033),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                autoSubmitted
                    ? "Time limit reached. Your answers were submitted automatically."
                    : "Great job! Your test has been submitted.",
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
                      "$score / ${questions.length}",
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
                    child: _resultStat(
                      icon: Icons.check_circle,
                      title: "Correct",
                      value: "$correctAnswers",
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _resultStat(
                      icon: Icons.cancel,
                      title: "Wrong",
                      value: "$wrongAnswers",
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _resultStat(
                      icon: Icons.remove_circle,
                      title: "Skipped",
                      value: "$unanswered",
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Test Details",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _detailRow("Subject", subject),
                    _detailRow("Chapter", chapter),
                    _detailRow("Questions", "${questions.length}"),
                    _detailRow("Duration", "$testDurationMinutes minutes"),
                  ],
                ),
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

  // ============================================================
  // INFO CARD
  // ============================================================

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            height: 45,
            width: 45,
            decoration: BoxDecoration(
              color: const Color(0xffE8F0FF),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: const Color(0xff4169E1)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RESULT STAT
  // ============================================================

  Widget _resultStat({
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

  // ============================================================
  // DETAIL ROW
  // ============================================================

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Colors.grey.shade600)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
