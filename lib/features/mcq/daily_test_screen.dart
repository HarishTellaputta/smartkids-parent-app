import 'dart:async';

import 'package:flutter/material.dart';

import 'package:parent_app/models/mcq_attempt.dart';
import 'package:parent_app/models/mcq_test.dart';
import 'package:parent_app/models/student_response.dart';
import 'package:parent_app/services/api_service.dart';
import '../../models/mcq_question.dart';

class DailyTestScreen extends StatefulWidget {
  final McqTest test;
  final StudentResponse student;

  const DailyTestScreen({
    super.key,
    required this.test,
    required this.student,
  });

  @override
  State<DailyTestScreen> createState() => _DailyTestScreenState();
}

class _DailyTestScreenState extends State<DailyTestScreen> {
  // ============================================================
  // BACKEND ATTEMPT
  // ============================================================

  McqAttempt? attempt;

  bool isStartingTest = false;
  bool isSubmittingTest = false;
  bool isAnswering = false;

  // ============================================================
  // STATE
  // ============================================================

  int currentQuestionIndex = 0;

  // -1 = unanswered
  // 0 = A
  // 1 = B
  // 2 = C
  // 3 = D
  List<int> selectedAnswers = [];

  Timer? timer;

  int remainingSeconds = 0;

  bool testStarted = false;
  bool testSubmitted = false;
  bool autoSubmitted = false;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
  }

  // ============================================================
  // QUESTIONS
  // ============================================================

 List<McqQuestion> get questions {
  return attempt?.test?.questions ?? <McqQuestion>[];
}

  // ============================================================
  // START TEST FROM BACKEND
  // ============================================================

  Future<void> startTest() async {
    if (isStartingTest || testStarted) return;

    setState(() {
      isStartingTest = true;
    });

    try {
      final response = await ApiService.startMcqTest(
        widget.test.id,
        widget.student.id,
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = ApiService.decodeResponse(response);

        if (data is! Map<String, dynamic>) {
          throw Exception('Invalid test response from server');
        }

        final startedAttempt = McqAttempt.fromJson(data);

        final backendQuestions =
            startedAttempt.test?.questions ?? [];

        if (backendQuestions.isEmpty) {
          setState(() {
            isStartingTest = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'No questions are available for this test.',
              ),
            ),
          );

          return;
        }

        int calculatedRemainingSeconds =
            widget.test.duration * 60;

        if (startedAttempt.expiresAt != null) {
          final difference =
              startedAttempt.expiresAt!.difference(DateTime.now());

          calculatedRemainingSeconds =
              difference.inSeconds.clamp(0, 24 * 60 * 60);
        }

        setState(() {
          attempt = startedAttempt;

          selectedAnswers = List<int>.filled(
            backendQuestions.length,
            -1,
          );

          currentQuestionIndex = 0;

          remainingSeconds = calculatedRemainingSeconds;

          testStarted = true;
          testSubmitted = false;
          autoSubmitted = false;

          isStartingTest = false;
        });

        if (remainingSeconds <= 0) {
          await _autoSubmitTest();
        } else {
          _startTimer();
        }
      } else {
        setState(() {
          isStartingTest = false;
        });

        final errorMessage = _extractErrorMessage(
          response,
          'Unable to start test',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$errorMessage (${response.statusCode})',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isStartingTest = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to start test: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // TIMER
  // ============================================================

  void _startTimer() {
    timer?.cancel();

    timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted) return;

        if (remainingSeconds <= 1) {
          timer.cancel();

          setState(() {
            remainingSeconds = 0;
          });

          _autoSubmitTest();

          return;
        }

        setState(() {
          remainingSeconds--;
        });
      },
    );
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

  Future<void> selectAnswer(int optionIndex) async {
    if (testSubmitted ||
        isAnswering ||
        attempt?.attemptId == null ||
        questions.isEmpty) {
      return;
    }

    final question = questions[currentQuestionIndex];

    final previousAnswer =
        selectedAnswers[currentQuestionIndex];

    setState(() {
      selectedAnswers[currentQuestionIndex] = optionIndex;
      isAnswering = true;
    });

    try {
      final answer = _optionLetter(optionIndex);

      final response = await ApiService.submitMcqAnswer(
        attempt!.attemptId!,
        widget.student.id,
        question.id,
        answer,
      );

      if (!mounted) return;

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        final data = ApiService.decodeResponse(response);

        if (data is Map<String, dynamic>) {
          final updatedAttempt =
              McqAttempt.fromJson(data);

          setState(() {
            attempt = updatedAttempt;
            isAnswering = false;
          });
        } else {
          setState(() {
            isAnswering = false;
          });
        }
      } else {
        setState(() {
          selectedAnswers[currentQuestionIndex] =
              previousAnswer;
          isAnswering = false;
        });

        final errorMessage = _extractErrorMessage(
          response,
          'Unable to save answer',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$errorMessage (${response.statusCode})',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        selectedAnswers[currentQuestionIndex] =
            previousAnswer;

        isAnswering = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to save answer: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // OPTION LETTER
  // ============================================================

  String _optionLetter(int index) {
    const letters = ['A', 'B', 'C', 'D'];

    if (index < 0 || index >= letters.length) {
      return 'A';
    }

    return letters[index];
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
    if (testSubmitted ||
        isSubmittingTest ||
        attempt?.attemptId == null) {
      return;
    }

    if (isAnswering) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please wait while your answer is being saved.',
          ),
        ),
      );

      return;
    }

    final answered =
        selectedAnswers.where((answer) => answer != -1).length;

    final shouldSubmit = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Submit Test?",
          ),
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
              child: const Text(
                "Continue Test",
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text(
                "Submit",
              ),
            ),
          ],
        );
      },
    );

    if (shouldSubmit == true) {
      await _submitTest(auto: false);
    }
  }

  // ============================================================
  // AUTO SUBMIT
  // ============================================================

  Future<void> _autoSubmitTest() async {
    if (testSubmitted || isSubmittingTest) {
      return;
    }

    await _submitTest(auto: true);
  }

  // ============================================================
  // SUBMIT TEST TO BACKEND
  // ============================================================

  Future<void> _submitTest({
    required bool auto,
  }) async {
    if (testSubmitted ||
        isSubmittingTest ||
        attempt?.attemptId == null) {
      return;
    }

    timer?.cancel();

    setState(() {
      isSubmittingTest = true;
      autoSubmitted = auto;
    });

    try {
      final response = await ApiService.submitMcqTest(
        attempt!.attemptId!,
        widget.student.id,
      );

      if (!mounted) return;

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        final data = ApiService.decodeResponse(response);

        if (data is! Map<String, dynamic>) {
          throw Exception(
            'Invalid submit response from server',
          );
        }

        final submittedAttempt =
            McqAttempt.fromJson(data);

        setState(() {
          attempt = submittedAttempt;
          testSubmitted = true;
          isSubmittingTest = false;
        });
      } else {
        setState(() {
          isSubmittingTest = false;
        });

        final errorMessage = _extractErrorMessage(
          response,
          'Unable to submit test',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$errorMessage (${response.statusCode})',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSubmittingTest = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to submit test: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // ERROR MESSAGE
  // ============================================================

  String _extractErrorMessage(
    dynamic response,
    String fallback,
  ) {
    try {
      final data = ApiService.decodeResponse(response);

      if (data is Map<String, dynamic>) {
        final message = data['message'] ??
            data['error'] ??
            data['detail'];

        if (message != null &&
            message.toString().trim().isNotEmpty) {
          return message.toString();
        }
      }
    } catch (_) {}

    return fallback;
  }

  // ============================================================
  // TOTAL MARKS
  // ============================================================

 int get totalMarks {
  if (questions.isEmpty) {
    return 0;
  }

  return questions.fold<int>(
    0,
    (sum, question) => sum + question.marks,
  );
}

  // ============================================================
  // RESULT VALUES
  // ============================================================

  int get resultTotalQuestions {
    return attempt?.totalQuestions ??
        questions.length;
  }

  int get resultScore {
    return attempt?.score ?? 0;
  }

  int get resultCorrect {
    return attempt?.correctAnswers ?? 0;
  }

  int get resultWrong {
    return attempt?.wrongAnswers ?? 0;
  }

  int get resultUnanswered {
    final total = resultTotalQuestions;

    final attempted =
        resultCorrect + resultWrong;

    final unanswered = total - attempted;

    return unanswered < 0 ? 0 : unanswered;
  }

  int get resultAttempted {
    return resultCorrect + resultWrong;
  }

  double get resultPercentage {
    if (attempt?.percentage != null) {
      return attempt!.percentage!;
    }

    if (totalMarks <= 0) {
      return 0;
    }

    return (resultScore / totalMarks) * 100;
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

    if (isSubmittingTest) {
      return _buildSubmittingScreen();
    }

    return _buildTestScreen();
  }

  // ============================================================
  // TEST INTRODUCTION
  // ============================================================

  Widget _buildTestIntroduction() {
    final duration = widget.test.duration;
    final questionCount = widget.test.numberOfQuestions;

    final testDate = widget.test.date.isNotEmpty
        ? widget.test.date
        : "Not specified";

    final startTime = widget.test.startTime.isNotEmpty
        ? widget.test.startTime
        : "Not specified";

    final classSection = [
      if ((widget.test.className ?? '').isNotEmpty)
        widget.test.className!,
      if ((widget.test.sectionName ?? '').isNotEmpty)
        widget.test.sectionName!,
    ].join(" - ");

    return Scaffold(
      backgroundColor: const Color(0xffF6F8FC),
      appBar: AppBar(
        title: const Text(
          "Daily MCQ Test",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
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

              // ==================================================
              // ICON
              // ==================================================

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

              // ==================================================
              // TITLE
              // ==================================================

              Text(
                "Daily MCQ Test",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff172033),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                widget.test.subject,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                ),
              ),

              if (classSection.isNotEmpty) ...[
                const SizedBox(height: 5),
                Text(
                  classSection,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],

              const SizedBox(height: 30),

              // ==================================================
              // SUBJECT
              // ==================================================

              _infoCard(
                icon: Icons.menu_book_rounded,
                title: "Subject",
                value: widget.test.subject,
              ),

              // ==================================================
              // QUESTIONS
              // ==================================================

              _infoCard(
                icon: Icons.help_outline_rounded,
                title: "Questions",
                value: "$questionCount Questions",
              ),

              // ==================================================
              // DURATION
              // ==================================================

              _infoCard(
                icon: Icons.timer_outlined,
                title: "Duration",
                value: "$duration Minutes",
              ),

              // ==================================================
              // TEST TIME
              // ==================================================

              _infoCard(
                icon: Icons.access_time_rounded,
                title: "Test Time",
                value: startTime,
              ),

              // ==================================================
              // TEST DATE
              // ==================================================

              _infoCard(
                icon: Icons.calendar_today_outlined,
                title: "Test Date",
                value: testDate,
              ),

              const SizedBox(height: 13),

              // ==================================================
              // INFORMATION
              // ==================================================

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xffFFF8E1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xffFFE082),
                  ),
                ),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Color(0xffF59E0B),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "You have $duration minutes "
                        "to complete this test. "
                        "The test will be submitted "
                        "automatically when the time expires.",
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ==================================================
              // START BUTTON
              // ==================================================

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed:
                      isStartingTest ? null : startTest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xff4169E1),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        const Color(0xffAFC0F5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                  ),
                  child: isStartingTest
                      ? const SizedBox(
                          height: 23,
                          width: 23,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Start Test",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 15),

              Text(
                "Please make sure you have a stable internet connection.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                ),
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
    if (questions.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xffF6F8FC),
        appBar: AppBar(
          title: const Text("MCQ Test"),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
        body: const Center(
          child: Text(
            "No questions available.",
          ),
        ),
      );
    }

    final question =
        questions[currentQuestionIndex];

    final selectedAnswer =
        selectedAnswers[currentQuestionIndex];

    final options = [
      question.optionA,
      question.optionB,
      question.optionC,
      question.optionD,
    ];

    return Scaffold(
      backgroundColor: const Color(0xffF6F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              "Daily MCQ Test",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Question ${currentQuestionIndex + 1} "
              "of ${questions.length}",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(
              right: 12,
              top: 10,
              bottom: 10,
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: remainingSeconds <= 60
                  ? Colors.red.shade50
                  : const Color(0xffE8F0FF),
              borderRadius:
                  BorderRadius.circular(12),
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
                    fontWeight:
                        FontWeight.bold,
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
            // ==================================================
            // PROGRESS BAR
            // ==================================================

            LinearProgressIndicator(
              value:
                  (currentQuestionIndex + 1) /
                      questions.length,
              minHeight: 5,
              backgroundColor:
                  Colors.grey.shade200,
              valueColor:
                  const AlwaysStoppedAnimation(
                Color(0xff4169E1),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    // ==========================================
                    // QUESTION NUMBER
                    // ==========================================

                    Text(
                      "Question ${currentQuestionIndex + 1}",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight:
                            FontWeight.bold,
                        color:
                            Color(0xff4169E1),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ==========================================
                    // QUESTION
                    // ==========================================

                    Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.all(20),
                      decoration:
                          BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withOpacity(0.04),
                            blurRadius: 12,
                            offset:
                                const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        question.question,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight:
                              FontWeight.bold,
                          height: 1.4,
                          color:
                              Color(0xff172033),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ==========================================
                    // OPTIONS
                    // ==========================================

                    ...List.generate(
                      options.length,
                      (index) {
                        final isSelected =
                            selectedAnswer ==
                                index;

                        return _optionCard(
                          optionIndex: index,
                          optionText:
                              options[index],
                          isSelected:
                              isSelected,
                          onTap: () {
                            selectAnswer(index);
                          },
                        );
                      },
                    ),

                    if (isAnswering) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 16,
                            width: 16,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Saving answer...",
                            style: TextStyle(
                              fontSize: 11,
                              color:
                                  Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 25),

                    // ==========================================
                    // QUESTION NAVIGATOR
                    // ==========================================

                    const Text(
                      "Questions",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          List.generate(
                        questions.length,
                        (index) {
                          final answered =
                              selectedAnswers[index] !=
                                  -1;

                          final isCurrent =
                              index ==
                                  currentQuestionIndex;

                          return GestureDetector(
                            onTap:
                                isAnswering
                                    ? null
                                    : () {
                                        setState(() {
                                          currentQuestionIndex =
                                              index;
                                        });
                                      },
                            child: Container(
                              height: 38,
                              width: 38,
                              alignment:
                                  Alignment.center,
                              decoration:
                                  BoxDecoration(
                                color: isCurrent
                                    ? const Color(
                                        0xff4169E1,
                                      )
                                    : answered
                                        ? const Color(
                                            0xffDCFCE7,
                                          )
                                        : Colors.white,
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  10,
                                ),
                                border:
                                    Border.all(
                                  color: isCurrent
                                      ? const Color(
                                          0xff4169E1,
                                        )
                                      : answered
                                          ? Colors.green
                                          : Colors
                                              .grey
                                              .shade300,
                                ),
                              ),
                              child: Text(
                                "${index + 1}",
                                style:
                                    TextStyle(
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                  color: isCurrent
                                      ? Colors.white
                                      : answered
                                          ? Colors
                                              .green
                                              .shade700
                                          : Colors
                                              .black87,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ==================================================
            // BOTTOM NAVIGATION
            // ==================================================

            Container(
              padding:
                  const EdgeInsets.fromLTRB(
                16,
                12,
                16,
                16,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.black.withOpacity(
                      0.06,
                    ),
                    blurRadius: 12,
                    offset:
                        const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (currentQuestionIndex > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed:
                            isAnswering
                                ? null
                                : previousQuestion,
                        style:
                            OutlinedButton.styleFrom(
                          minimumSize:
                              const Size(
                            double.infinity,
                            50,
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              14,
                            ),
                          ),
                        ),
                        child:
                            const Text(
                          "Previous",
                        ),
                      ),
                    ),

                  if (currentQuestionIndex > 0)
                    const SizedBox(width: 10),

                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          isAnswering ||
                                  isSubmittingTest
                              ? null
                              : currentQuestionIndex ==
                                      questions.length -
                                          1
                                  ? submitTest
                                  : nextQuestion,
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(
                          0xff4169E1,
                        ),
                        foregroundColor:
                            Colors.white,
                        minimumSize:
                            const Size(
                          double.infinity,
                          50,
                        ),
                        elevation: 0,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            14,
                          ),
                        ),
                      ),
                      child: Text(
                        currentQuestionIndex ==
                                questions.length -
                                    1
                            ? "Submit Test"
                            : "Next",
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
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
    const letters = ["A", "B", "C", "D"];

    return GestureDetector(
      onTap: isAnswering ? null : onTap,
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 200),
        margin:
            const EdgeInsets.only(bottom: 12),
        padding:
            const EdgeInsets.all(15),
        decoration:
            BoxDecoration(
          color: isSelected
              ? const Color(0xffE8F0FF)
              : Colors.white,
          borderRadius:
              BorderRadius.circular(15),
          border: Border.all(
            color: isSelected
                ? const Color(0xff4169E1)
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              alignment:
                  Alignment.center,
              decoration:
                  BoxDecoration(
                color: isSelected
                    ? const Color(
                        0xff4169E1,
                      )
                    : const Color(
                        0xffF1F3F7,
                      ),
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
              ),
              child: Text(
                letters[optionIndex],
                style: TextStyle(
                  fontWeight:
                      FontWeight.bold,
                  color: isSelected
                      ? Colors.white
                      : Colors.black87,
                ),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Text(
                optionText,
                style:
                    const TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w500,
                ),
              ),
            ),

            Icon(
              isSelected
                  ? Icons
                      .radio_button_checked
                  : Icons
                      .radio_button_off,
              color: isSelected
                  ? const Color(
                      0xff4169E1,
                    )
                  : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SUBMITTING SCREEN
  // ============================================================

  Widget _buildSubmittingScreen() {
    return Scaffold(
      backgroundColor:
          const Color(0xffF6F8FC),
      appBar: AppBar(
        title: const Text(
          "Test Result",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor:
            Colors.black87,
        elevation: 0,
        automaticallyImplyLeading:
            false,
      ),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: Color(0xff4169E1),
            ),
            SizedBox(height: 18),
            Text(
              "Submitting your test...",
              style: TextStyle(
                fontSize: 16,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
            SizedBox(height: 6),
            Text(
              "Please wait",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
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
    final percentage =
        resultPercentage;

    final scoreColor =
        _getScoreColor(percentage);

    final submittedAt =
        attempt?.submittedAt;

    final submittedTime =
        submittedAt != null
            ? _formatDateTime(
                submittedAt,
              )
            : "Just now";

    return Scaffold(
      backgroundColor:
          const Color(0xffF6F8FC),
      appBar: AppBar(
        title: const Text(
          "Test Result",
          style: TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor:
            Colors.white,
        foregroundColor:
            Colors.black87,
        elevation: 0,
        automaticallyImplyLeading:
            false,
      ),
      body: SafeArea(
        child:
            SingleChildScrollView(
          padding:
              const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 15),

              // ==================================================
              // RESULT ICON
              // ==================================================

              Container(
                height: 90,
                width: 90,
                decoration:
                    BoxDecoration(
                  color: scoreColor
                      .withOpacity(0.10),
                  shape:
                      BoxShape.circle,
                ),
                child: Icon(
                  percentage >= 60
                      ? Icons
                          .celebration_rounded
                      : Icons
                          .school_rounded,
                  size: 50,
                  color:
                      scoreColor,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                autoSubmitted
                    ? "Test Auto-Submitted"
                    : "Test Completed!",
                style:
                    const TextStyle(
                  fontSize: 25,
                  fontWeight:
                      FontWeight.bold,
                  color:
                      Color(0xff172033),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                autoSubmitted
                    ? "Time limit reached. "
                        "Your answers were "
                        "submitted automatically."
                    : "Your test has been "
                        "submitted successfully.",
                textAlign:
                    TextAlign.center,
                style:
                    TextStyle(
                  color:
                      Colors.grey.shade600,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 30),

              // ==================================================
              // SCORE
              // ==================================================

              Container(
                width:
                    double.infinity,
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 30,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      Colors.white,
                  borderRadius:
                      BorderRadius.circular(
                    22,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors
                          .black
                          .withOpacity(
                        0.04,
                      ),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child:
                    Column(
                  children: [
                    Text(
                      "$resultScore / $totalMarks",
                      style:
                          TextStyle(
                        fontSize: 42,
                        fontWeight:
                            FontWeight.bold,
                        color:
                            scoreColor,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      "${percentage.toStringAsFixed(0)}%",
                      style:
                          TextStyle(
                        fontSize: 18,
                        color:
                            scoreColor,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // STATISTICS
              // ==================================================

              Row(
                children: [
                  Expanded(
                    child:
                        _resultStat(
                      icon:
                          Icons.check_circle,
                      title:
                          "Correct",
                      value:
                          "$resultCorrect",
                      color:
                          Colors.green,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child:
                        _resultStat(
                      icon:
                          Icons.cancel,
                      title:
                          "Wrong",
                      value:
                          "$resultWrong",
                      color:
                          Colors.red,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child:
                        _resultStat(
                      icon:
                          Icons.remove_circle,
                      title:
                          "Skipped",
                      value:
                          "$resultUnanswered",
                      color:
                          Colors.orange,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // ==================================================
              // TEST DETAILS
              // ==================================================

              Container(
                width:
                    double.infinity,
                padding:
                    const EdgeInsets.all(
                  18,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      Colors.white,
                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),
                ),
                child:
                    Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    const Text(
                      "Test Details",
                      style:
                          TextStyle(
                        fontSize: 17,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    _detailRow(
                      "Subject",
                      widget.test.subject,
                    ),

                    _detailRow(
                      "Questions",
                      "$resultTotalQuestions",
                    ),

                    _detailRow(
                      "Attempted",
                      "$resultAttempted",
                    ),

                    _detailRow(
                      "Duration",
                      "${widget.test.duration} minutes",
                    ),

                    _detailRow(
                      "Submitted",
                      submittedTime,
                    ),

                    _detailRow(
                      "Status",
                      attempt?.status ??
                          "SUBMITTED",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ==================================================
              // BACK BUTTON
              // ==================================================

              SizedBox(
                width:
                    double.infinity,
                height: 52,
                child:
                    ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                    );
                  },
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(
                      0xff4169E1,
                    ),
                    foregroundColor:
                        Colors.white,
                    elevation: 0,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        15,
                      ),
                    ),
                  ),
                  child:
                      const Text(
                    "Back to Home",
                    style:
                        TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                    ),
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
  // SCORE COLOR
  // ============================================================

  Color _getScoreColor(
    double percentage,
  ) {
    if (percentage >= 80) {
      return Colors.green;
    }

    if (percentage >= 60) {
      return Colors.orange;
    }

    return Colors.red;
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDateTime(
    DateTime dateTime,
  ) {
    final local =
        dateTime.toLocal();

    final day =
        local.day.toString().padLeft(
              2,
              '0',
            );

    final month =
        local.month.toString().padLeft(
              2,
              '0',
            );

    final year =
        local.year.toString();

    final hour =
        local.hour % 12 == 0
            ? 12
            : local.hour % 12;

    final minute =
        local.minute.toString().padLeft(
              2,
              '0',
            );

    final period =
        local.hour >= 12
            ? "PM"
            : "AM";

    return "$day/$month/$year "
        "$hour:$minute $period";
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
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),
      padding:
          const EdgeInsets.all(
        16,
      ),
      decoration:
          BoxDecoration(
        color:
            Colors.white,
        borderRadius:
            BorderRadius.circular(
          16,
        ),
      ),
      child:
          Row(
        children: [
          Container(
            height: 45,
            width: 45,
            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xffE8F0FF,
              ),
              borderRadius:
                  BorderRadius.circular(
                13,
              ),
            ),
            child:
                Icon(
              icon,
              color:
                  const Color(
                0xff4169E1,
              ),
            ),
          ),

          const SizedBox(
            width: 14,
          ),

          Expanded(
            child:
                Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  title,
                  style:
                      TextStyle(
                    fontSize: 12,
                    color: Colors
                        .grey
                        .shade600,
                  ),
                ),
                const SizedBox(
                  height: 3,
                ),
                Text(
                  value,
                  style:
                      const TextStyle(
                    fontSize: 15,
                    fontWeight:
                        FontWeight.bold,
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
      padding:
          const EdgeInsets.symmetric(
        vertical: 18,
        horizontal: 8,
      ),
      decoration:
          BoxDecoration(
        color:
            Colors.white,
        borderRadius:
            BorderRadius.circular(
          16,
        ),
      ),
      child:
          Column(
        children: [
          Icon(
            icon,
            color:
                color,
            size: 25,
          ),

          const SizedBox(
            height: 7,
          ),

          Text(
            value,
            style:
                const TextStyle(
              fontSize: 20,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 3,
          ),

          Text(
            title,
            style:
                TextStyle(
              fontSize: 11,
              color:
                  Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DETAIL ROW
  // ============================================================

  Widget _detailRow(
    String title,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 12,
      ),
      child:
          Row(
        mainAxisAlignment:
            MainAxisAlignment
                .spaceBetween,
        children: [
          Text(
            title,
            style:
                TextStyle(
              color:
                  Colors.grey.shade600,
            ),
          ),

          const SizedBox(
            width: 15,
          ),

          Flexible(
            child:
                Text(
              value,
              textAlign:
                  TextAlign.end,
              style:
                  const TextStyle(
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),
        ],
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
}