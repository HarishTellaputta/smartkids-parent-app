import 'dart:async';

import 'package:flutter/material.dart';

import '../mcq/daily_test_screen.dart';
import '../mcq/mcq_question_screen.dart';
import '../mcq/mcq_result_screen.dart';
import '../mcq/performance_screen.dart';
import 'mcq_result_screen.dart';
import 'package:parent_app/models/mcq_attempt.dart';
import 'package:parent_app/models/student_response.dart';
import 'package:parent_app/models/mcq_question.dart';
import 'package:parent_app/services/api_service.dart';

class McqQuestionScreen extends StatefulWidget {
  final McqAttempt attempt;
  final StudentResponse student;

  const McqQuestionScreen({
    super.key,
    required this.attempt,
    required this.student,
  });

  @override
  State<McqQuestionScreen> createState() => _McqQuestionScreenState();
}

class _McqQuestionScreenState extends State<McqQuestionScreen> {
  late McqAttempt attempt;

  int currentQuestion = 0;

  late List<String?> selectedAnswers;

  int remainingSeconds = 0;

  Timer? timer;

  bool isSubmitting = false;

  final Map<int, bool> answerSaving = {};

  @override
  void initState() {
    super.initState();

    attempt = widget.attempt;

    final questions = attempt.test?.questions ?? [];

    selectedAnswers = List<String?>.filled(
      questions.length,
      null,
    );

    _setInitialTimer();

    startTimer();
  }

  // ============================================================
  // TIMER
  // ============================================================

  void _setInitialTimer() {
    if (attempt.expiresAt != null) {
      final difference = attempt.expiresAt!
          .difference(DateTime.now())
          .inSeconds;

      remainingSeconds = difference > 0 ? difference : 0;
    } else if (attempt.test?.duration != null) {
      remainingSeconds = attempt.test!.duration * 60;
    }
  }

  void startTimer() {
    timer?.cancel();

    timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

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
      },
    );
  }

  String get formattedTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  // ============================================================
  // QUESTIONS
  // ============================================================

  List<McqQuestion> get questions {
    return attempt.test?.questions ?? [];
  }

  // ============================================================
  // SELECT ANSWER
  // ============================================================

  Future<void> selectAnswer(int optionIndex) async {
    if (isSubmitting) return;

    if (currentQuestion >= questions.length) return;

    final question = questions[currentQuestion];

    final answer = _indexToLetter(optionIndex);

    setState(() {
      selectedAnswers[currentQuestion] = answer;
      answerSaving[question.id] = true;
    });

    try {
      final response = await ApiService.submitMcqAnswer(
        attempt.attemptId!,
        widget.student.id,
        question.id,
        answer,
      );

      if (!mounted) return;

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        setState(() {
          selectedAnswers[currentQuestion] = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Unable to save answer (${response.statusCode})',
            ),
          ),
        );
      } else {
        final data = ApiService.decodeResponse(response);

        if (data is Map<String, dynamic>) {
          setState(() {
            attempt = McqAttempt.fromJson(data);
          });
        }
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        selectedAnswers[currentQuestion] = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save answer: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          answerSaving[question.id] = false;
        });
      }
    }
  }

  String _indexToLetter(int index) {
    switch (index) {
      case 0:
        return 'A';
      case 1:
        return 'B';
      case 2:
        return 'C';
      case 3:
        return 'D';
      default:
        return 'A';
    }
  }

  int _letterToIndex(String? answer) {
    switch (answer?.toUpperCase()) {
      case 'A':
        return 0;
      case 'B':
        return 1;
      case 'C':
        return 2;
      case 'D':
        return 3;
      default:
        return -1;
    }
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
  // SUBMIT
  // ============================================================

  Future<void> submitTest() async {
    if (isSubmitting) return;

    final unanswered = selectedAnswers
        .where((answer) => answer == null)
        .length;

    if (unanswered > 0) {
      final shouldSubmit = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: const Text(
              'Submit Test?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'You still have $unanswered '
              'unanswered question(s).\n\n'
              'Do you want to submit now?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: const Text('Continue'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: const Text('Submit'),
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
  // SUBMIT API
  // ============================================================

  Future<void> _submitTest({
    required bool autoSubmitted,
  }) async {
    if (isSubmitting) return;

    if (attempt.attemptId == null) {
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    timer?.cancel();

    try {
      final response = await ApiService.submitMcqTest(
        attempt.attemptId!,
        widget.student.id,
      );

      if (!mounted) return;

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        final data = ApiService.decodeResponse(response);

        if (data is Map<String, dynamic>) {
          final completedAttempt = McqAttempt.fromJson(data);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => McqResultScreen(
                attempt: completedAttempt,
                autoSubmitted: autoSubmitted,
              ),
            ),
          );
        } else {
          setState(() {
            isSubmitting = false;
          });
        }
      } else {
        setState(() {
          isSubmitting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Unable to submit test (${response.statusCode})',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit test: $e'),
        ),
      );
    }
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
    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('MCQ Test'),
        ),
        body: const Center(
          child: Text('No questions available.'),
        ),
      );
    }

    final question = questions[currentQuestion];

    final selectedIndex = _letterToIndex(
      selectedAnswers[currentQuestion],
    );

    final progress =
        (currentQuestion + 1) / questions.length;

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
            Text(
              attempt.test?.subject.isNotEmpty == true
                  ? '${attempt.test!.subject} Test'
                  : 'MCQ Test',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Question ${currentQuestion + 1} '
              'of ${questions.length}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        actions: [
          _timerWidget(),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation(
                Color(0xff4169E1),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Question ${currentQuestion + 1}',
                      style: const TextStyle(
                        color: Color(0xff4169E1),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.black.withOpacity(0.04),
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
                          fontWeight: FontWeight.bold,
                          height: 1.4,
                          color: Color(0xff172033),
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    const Text(
                      'Choose your answer',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    ...List.generate(
                      4,
                      (index) {
                        final optionText =
                            question.options[index];

                        return _optionCard(
                          index: index,
                          text: optionText,
                          selected:
                              selectedIndex == index,
                          loading:
                              answerSaving[question.id] ==
                                  true,
                        );
                      },
                    ),

                    const SizedBox(height: 25),

                    _questionNavigator(),
                  ],
                ),
              ),
            ),

            _bottomNavigation(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TIMER
  // ============================================================

  Widget _timerWidget() {
    final isLowTime = remainingSeconds <= 60;

    return Container(
      margin: const EdgeInsets.only(
        right: 12,
        top: 9,
        bottom: 9,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      decoration: BoxDecoration(
        color: isLowTime
            ? const Color(0xffffe4e6)
            : const Color(0xffE8F0FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.timer_outlined,
            size: 18,
            color: isLowTime
                ? Colors.red
                : const Color(0xff4169E1),
          ),
          const SizedBox(width: 5),
          Text(
            formattedTime,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isLowTime
                  ? Colors.red
                  : const Color(0xff4169E1),
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
    required bool loading,
  }) {
    const letters = ['A', 'B', 'C', 'D'];

    return GestureDetector(
      onTap: loading || isSubmitting
          ? null
          : () => selectAnswer(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xffE8F0FF)
              : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selected
                ? const Color(0xff4169E1)
                : Colors.grey.shade300,
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
                  color:
                      selected ? Colors.white : Colors.black87,
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

            if (loading)
              const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            else
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: selected
                    ? const Color(0xff4169E1)
                    : Colors.grey.shade400,
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
            'Questions',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(
              questions.length,
              (index) {
                final answered =
                    selectedAnswers[index] != null;

                final current =
                    index == currentQuestion;

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
                      borderRadius:
                          BorderRadius.circular(10),
                      border: Border.all(
                        color: current
                            ? const Color(0xff4169E1)
                            : answered
                                ? Colors.green
                                : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      '${index + 1}',
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
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  Widget _bottomNavigation() {
    final isLastQuestion =
        currentQuestion == questions.length - 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        16,
        12,
        16,
        16,
      ),
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
          if (currentQuestion > 0)
            Expanded(
              child: OutlinedButton(
                onPressed:
                    isSubmitting ? null : previousQuestion,
                style: OutlinedButton.styleFrom(
                  minimumSize:
                      const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Previous'),
              ),
            ),

          if (currentQuestion > 0)
            const SizedBox(width: 10),

          Expanded(
            child: ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : isLastQuestion
                      ? submitTest
                      : nextQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xff4169E1),
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    Colors.grey.shade300,
                minimumSize:
                    const Size(double.infinity, 50),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(14),
                ),
              ),
              child: isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      isLastQuestion
                          ? 'Submit Test'
                          : 'Next',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}