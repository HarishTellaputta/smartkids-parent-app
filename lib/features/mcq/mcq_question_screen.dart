
import 'dart:async';

import 'package:flutter/material.dart';

import 'package:parent_app/models/mcq_attempt.dart';
import 'package:parent_app/models/mcq_question.dart';
import 'package:parent_app/models/student_response.dart';
import 'package:parent_app/services/api_service.dart';
import 'package:parent_app/services/mcq_service.dart';

import 'mcq_result_screen.dart';

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
  static const Color primary = Color(0xff3155D9);
  static const Color primaryDark = Color(0xff2343B8);
  static const Color background = Color(0xffF6F8FC);
  static const Color textDark = Color(0xff172033);
  static const Color textMuted = Color(0xff697386);
  static const Color border = Color(0xffE5E9F0);

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

    _restoreExistingAnswers();

    _setInitialTimer();
    startTimer();
  }

  // ============================================================
  // RESTORE EXISTING ANSWERS
  // ============================================================

  void _restoreExistingAnswers() {
    final questions = attempt.test?.questions ?? [];

    /*
     * If your backend returns selected answers inside McqAttempt,
     * you can map them here.
     *
     * Current implementation keeps the original behavior and
     * initializes unanswered questions as null.
     */
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

  bool get isLowTime => remainingSeconds <= 60;

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
      final response = await McqService.submitMcqAnswer(
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

        _showSnackBar(
          'Unable to save answer (${response.statusCode})',
          isError: true,
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

      _showSnackBar(
        'Failed to save answer.',
        isError: true,
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
  // NAVIGATION
  // ============================================================

  void nextQuestion() {
    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;
      });
    }
  }

  void previousQuestion() {
    if (currentQuestion > 0) {
      setState(() {
        currentQuestion--;
      });
    }
  }

  void goToQuestion(int index) {
    if (index < 0 || index >= questions.length) return;

    setState(() {
      currentQuestion = index;
    });
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
      final shouldSubmit = await _showSubmitConfirmation(
        unanswered,
      );

      if (shouldSubmit != true) return;
    }

    await _submitTest(autoSubmitted: false);
  }

  // ============================================================
  // SUBMIT CONFIRMATION
  // ============================================================

  Future<bool?> _showSubmitConfirmation(
    int unanswered,
  ) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 68,
                  width: 68,
                  decoration: BoxDecoration(
                    color: const Color(0xffFFF4E5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.assignment_turned_in_rounded,
                    color: Color(0xffE68A00),
                    size: 34,
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'Ready to Submit?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: textDark,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  unanswered == 1
                      ? 'You have 1 unanswered question.'
                      : 'You have $unanswered unanswered questions.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: textMuted,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Once you submit, you cannot change your answers.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: textMuted,
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(
                            dialogContext,
                            false,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          minimumSize:
                              const Size.fromHeight(52),
                          side: const BorderSide(
                            color: border,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          'Continue Test',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: textDark,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(
                            dialogContext,
                            true,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          minimumSize:
                              const Size.fromHeight(52),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          'Submit Test',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
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
      final response = await McqService.submitMcqTest(
        attempt.attemptId!,
        widget.student.id,
      );

      if (!mounted) return;

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        final data = ApiService.decodeResponse(response);

        if (data is Map<String, dynamic>) {
          final completedAttempt =
              McqAttempt.fromJson(data);

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

        _showSnackBar(
          'Unable to submit test (${response.statusCode})',
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSubmitting = false;
      });

      _showSnackBar(
        'Failed to submit test.',
        isError: true,
      );
    }
  }

  // ============================================================
  // SNACKBAR
  // ============================================================

  void _showSnackBar(
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        backgroundColor:
            isError ? const Color(0xffDC2626) : textDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
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
    if (questions.isEmpty) {
      return _buildNoQuestions();
    }

    final question = questions[currentQuestion];

    final selectedIndex = _letterToIndex(
      selectedAnswers[currentQuestion],
    );

    final progress =
        (currentQuestion + 1) / questions.length;

    return Scaffold(
      backgroundColor: background,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressHeader(progress),

            Expanded(
              child: SingleChildScrollView(
                physics:
                    const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  18,
                  18,
                  18,
                  24,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    _buildQuestionMeta(),

                    const SizedBox(height: 12),

                    _buildQuestionCard(question),

                    const SizedBox(height: 22),

                    _buildAnswerHeader(),

                    const SizedBox(height: 12),

                    ...List.generate(
                      question.options.length > 4
                          ? 4
                          : question.options.length,
                      (index) {
                        final optionText =
                            question.options[index];

                        return _optionCard(
                          index: index,
                          text: optionText,
                          selected:
                              selectedIndex == index,
                          loading:
                              answerSaving[
                                      question.id] ==
                                  true,
                        );
                      },
                    ),

                    const SizedBox(height: 14),

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
  // APP BAR
  // ============================================================

  PreferredSizeWidget _buildAppBar() {
    final subject =
        attempt.test?.subject.trim().isNotEmpty == true
            ? attempt.test!.subject.trim()
            : 'MCQ Test';

    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: textDark,
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 72,
      titleSpacing: 18,
      title: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  primary,
                  primaryDark,
                ],
              ),
              borderRadius:
                  BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.quiz_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Text(
                  '$subject Test',
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: textDark,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  'Question ${currentQuestion + 1} of ${questions.length}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        _timerWidget(),
      ],
    );
  }

  // ============================================================
  // PROGRESS
  // ============================================================

  Widget _buildProgressHeader(
    double progress,
  ) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            backgroundColor:
                const Color(0xffEDF0F5),
            valueColor:
                const AlwaysStoppedAnimation(
              primary,
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 9,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  size: 15,
                  color: primary,
                ),

                const SizedBox(width: 6),

                const Text(
                  'Keep going!',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: textMuted,
                  ),
                ),

                const Spacer(),

                Text(
                  '${(progress * 100).round()}% completed',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: primary,
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
  // QUESTION META
  // ============================================================

  Widget _buildQuestionMeta() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 11,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: const Color(0xffE8F0FF),
            borderRadius:
                BorderRadius.circular(10),
          ),
          child: Text(
            'QUESTION ${currentQuestion + 1}',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: .4,
              color: primary,
            ),
          ),
        ),

        const Spacer(),

        Text(
          '${selectedAnswers.where((e) => e != null).length}/${questions.length} answered',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: textMuted,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // QUESTION CARD
  // ============================================================

  Widget _buildQuestionCard(
    McqQuestion question,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(22),
        border: Border.all(
          color: border,
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(.035),
            blurRadius: 18,
            offset:
                const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
              color: const Color(0xffEEF2FF),
              borderRadius:
                  BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.help_outline_rounded,
              color: primary,
              size: 19,
            ),
          ),

          const SizedBox(height: 15),

          Text(
            question.question,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              height: 1.45,
              color: textDark,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ANSWER HEADER
  // ============================================================

  Widget _buildAnswerHeader() {
    return Row(
      children: [
        const Text(
          'Choose your answer',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: textDark,
          ),
        ),

        const Spacer(),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 9,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(8),
            border: Border.all(
              color: border,
            ),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.touch_app_rounded,
                size: 13,
                color: textMuted,
              ),
              SizedBox(width: 4),
              Text(
                'Tap one',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TIMER
  // ============================================================

  Widget _timerWidget() {
    return Container(
      margin: const EdgeInsets.only(
        right: 14,
        top: 13,
        bottom: 13,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: isLowTime
            ? const Color(0xffFFF0F1)
            : const Color(0xffEEF2FF),
        borderRadius:
            BorderRadius.circular(12),
        border: Border.all(
          color: isLowTime
              ? const Color(0xffFECACA)
              : const Color(0xffDDE5FF),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isLowTime
                ? Icons.timer_rounded
                : Icons.schedule_rounded,
            size: 17,
            color: isLowTime
                ? const Color(0xffDC2626)
                : primary,
          ),

          const SizedBox(width: 5),

          Text(
            formattedTime,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: isLowTime
                  ? const Color(0xffDC2626)
                  : primary,
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

    final letter = letters[index];

    return GestureDetector(
      onTap: loading || isSubmitting
          ? null
          : () => selectAnswer(index),
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        margin:
            const EdgeInsets.only(bottom: 12),
        padding:
            const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xffEEF3FF)
              : Colors.white,
          borderRadius:
              BorderRadius.circular(17),
          border: Border.all(
            color: selected
                ? primary
                : border,
            width: selected ? 1.7 : 1,
          ),
          boxShadow: [
            if (selected)
              BoxShadow(
                color:
                    primary.withOpacity(.08),
                blurRadius: 12,
                offset:
                    const Offset(0, 5),
              ),
          ],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration:
                  const Duration(milliseconds: 200),
              height: 44,
              width: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: selected
                    ? const LinearGradient(
                        colors: [
                          primary,
                          primaryDark,
                        ],
                      )
                    : null,
                color: selected
                    ? null
                    : const Color(0xffF1F3F7),
                borderRadius:
                    BorderRadius.circular(13),
              ),
              child: Text(
                letter,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight:
                      FontWeight.w900,
                  color: selected
                      ? Colors.white
                      : textDark,
                ),
              ),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.35,
                  fontWeight: selected
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: textDark,
                ),
              ),
            ),

            const SizedBox(width: 8),

            if (loading)
              const SizedBox(
                height: 19,
                width: 19,
                child:
                    CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: primary,
                ),
              )
            else
              AnimatedContainer(
                duration:
                    const Duration(milliseconds: 180),
                height: 22,
                width: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected
                      ? primary
                      : Colors.transparent,
                  border: Border.all(
                    color: selected
                        ? primary
                        : const Color(0xffCBD1DB),
                    width: selected ? 0 : 1.5,
                  ),
                ),
                child: selected
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 15,
                      )
                    : null,
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
    final answeredCount =
        selectedAnswers
            .where((answer) => answer != null)
            .length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Question Navigator',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                ),
              ),

              const Spacer(),

              Text(
                '$answeredCount answered',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: textMuted,
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                List.generate(
              questions.length,
              (index) {
                final answered =
                    selectedAnswers[index] !=
                        null;

                final current =
                    index == currentQuestion;

                return GestureDetector(
                  onTap: isSubmitting
                      ? null
                      : () =>
                          goToQuestion(index),
                  child: AnimatedContainer(
                    duration:
                        const Duration(
                      milliseconds: 180,
                    ),
                    height: 39,
                    width: 39,
                    alignment:
                        Alignment.center,
                    decoration: BoxDecoration(
                      color: current
                          ? primary
                          : answered
                              ? const Color(
                                  0xffDCFCE7,
                                )
                              : const Color(
                                  0xffF7F8FA,
                                ),
                      borderRadius:
                          BorderRadius.circular(
                        11,
                      ),
                      border: Border.all(
                        color: current
                            ? primary
                            : answered
                                ? const Color(
                                    0xff86EFAC,
                                  )
                                : border,
                      ),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            FontWeight.w800,
                        color: current
                            ? Colors.white
                            : answered
                                ? const Color(
                                    0xff15803D,
                                  )
                                : textMuted,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              _legendDot(
                color: primary,
                text: 'Current',
              ),
              const SizedBox(width: 15),
              _legendDot(
                color: const Color(0xff22C55E),
                text: 'Answered',
              ),
              const SizedBox(width: 15),
              _legendDot(
                color: const Color(0xffCBD1DB),
                text: 'Unanswered',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendDot({
    required Color color,
    required String text,
  }) {
    return Row(
      mainAxisSize:
          MainAxisSize.min,
      children: [
        Container(
          height: 7,
          width: 7,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: textMuted,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  Widget _bottomNavigation() {
    final isLastQuestion =
        currentQuestion ==
            questions.length - 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        16,
        11,
        16,
        14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(
            color: border,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(.05),
            blurRadius: 16,
            offset:
                const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          if (currentQuestion > 0) ...[
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: isSubmitting
                    ? null
                    : previousQuestion,
                style:
                    OutlinedButton.styleFrom(
                  minimumSize:
                      const Size.fromHeight(
                    52,
                  ),
                  side:
                      const BorderSide(
                    color: border,
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      15,
                    ),
                  ),
                ),
                child: const Icon(
                  Icons
                      .arrow_back_rounded,
                  color: textDark,
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],

          Expanded(
            flex: 3,
            child: ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : isLastQuestion
                      ? submitTest
                      : nextQuestion,
              style:
                  ElevatedButton.styleFrom(
                backgroundColor: isLastQuestion
                    ? const Color(0xff15803D)
                    : primary,
                foregroundColor:
                    Colors.white,
                disabledBackgroundColor:
                    const Color(0xffD5D9E1),
                minimumSize:
                    const Size.fromHeight(
                  52,
                ),
                elevation: 0,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    15,
                  ),
                ),
              ),
              child: isSubmitting
                  ? const SizedBox(
                      height: 21,
                      width: 21,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2.3,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Icon(
                          isLastQuestion
                              ? Icons
                                  .check_circle_rounded
                              : Icons
                                  .arrow_forward_rounded,
                          size: 19,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isLastQuestion
                              ? 'Submit Test'
                              : 'Next Question',
                          style:
                              const TextStyle(
                            fontSize: 14,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NO QUESTIONS
  // ============================================================

  Widget _buildNoQuestions() {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: textDark,
        elevation: 0,
        title: const Text(
          'MCQ Test',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(24),
              border: Border.all(
                color: border,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 72,
                  width: 72,
                  decoration: BoxDecoration(
                    color:
                        const Color(0xffEEF2FF),
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.quiz_outlined,
                    size: 36,
                    color: primary,
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'No Questions Available',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: textDark,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'There are no questions available for this test.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: textMuted,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

