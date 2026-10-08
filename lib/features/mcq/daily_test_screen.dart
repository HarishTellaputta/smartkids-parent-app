import 'dart:async';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'package:parent_app/models/mcq_attempt.dart';
import 'package:parent_app/models/mcq_test.dart';
import 'package:parent_app/models/student_response.dart';
import 'package:parent_app/models/mcq_question.dart';
import 'package:parent_app/services/api_service.dart';
import 'package:parent_app/services/mcq_service.dart';

class DailyTestScreen extends StatefulWidget {
  final McqTest test;
  final StudentResponse student;

  const DailyTestScreen({super.key, required this.test, required this.student});

  @override
  State<DailyTestScreen> createState() => _DailyTestScreenState();
}

class _DailyTestScreenState extends State<DailyTestScreen> {
  static const Color primary = Color(0xff3155D9);
  static const Color primaryDark = Color(0xff2343B8);
  static const Color background = Color(0xffF6F8FC);
  static const Color textDark = Color(0xff172033);
  static const Color textMuted = Color(0xff697386);
  static const Color border = Color(0xffE5E9F0);

  // ============================================================
  // TEST STATE
  // ============================================================

  McqAttempt? attempt;

  int currentQuestionIndex = 0;

  final Map<int, String> selectedAnswers = {};

  Timer? _timer;

  /// Remaining seconds for the current attempt.
  int remainingSeconds = 0;

  bool isStartingTest = false;
  bool isSubmittingTest = false;
  bool isAnswering = false;

  bool testStarted = false;
  bool testSubmitted = false;

  /// True only when the timer itself submits the test.
  bool autoSubmitted = false;

  String? errorMessage;

  int resultScore = 0;
  int resultTotal = 0;
  double resultPercentage = 0;

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
    // After starting, backend should return the actual questions
    // inside attempt.test.questions.
    //
    // Before starting, use widget.test.questions.
    return attempt?.test?.questions ?? widget.test.questions;
  }

  int get totalQuestions => questions.length;

  McqQuestion? get currentQuestion {
    if (questions.isEmpty) return null;

    if (currentQuestionIndex >= questions.length) {
      currentQuestionIndex = questions.length - 1;
    }

    return questions[currentQuestionIndex];
  }

  int get answeredCount => selectedAnswers.length;

  int get unansweredCount => totalQuestions - answeredCount;

  double get progress {
    if (totalQuestions == 0) return 0;

    return (currentQuestionIndex + 1) / totalQuestions;
  }

  // ============================================================
  // START TEST
  // ============================================================

  Future<void> startTest() async {
    if (isStartingTest || testStarted || testSubmitted) {
      return;
    }

    setState(() {
      isStartingTest = true;
      errorMessage = null;
    });

    try {
      final response = await McqService.startMcqTest(
        widget.test.id,
        widget.student.id,
      );

      if (!mounted) return;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = ApiService.decodeResponse(response);

        if (data is Map<String, dynamic>) {
          attempt = McqAttempt.fromJson(data);
        }

        // --------------------------------------------------------
        // IMPORTANT:
        // Backend should create:
        //
        // startedAt = current time
        // expiresAt = current time + 30 minutes
        //
        // If expiresAt is available, we use it.
        // Otherwise fallback to exactly 30 minutes.
        // --------------------------------------------------------

        _calculateRemainingTime();

        setState(() {
          testStarted = true;
          isStartingTest = false;
        });

        _startTimer();
      } else {
        setState(() {
          isStartingTest = false;
          errorMessage = 'Unable to start test (${response.statusCode})';
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isStartingTest = false;
        errorMessage = 'Failed to start test. Please try again.';
      });
    }
  }

  // ============================================================
  // TIMER CALCULATION
  // ============================================================

  void _calculateRemainingTime() {
    final expiresAt = attempt?.expiresAt;

    if (expiresAt != null) {
      final now = DateTime.now();

      final difference = expiresAt.toLocal().difference(now);

      remainingSeconds = difference.inSeconds > 0 ? difference.inSeconds : 0;

      return;
    }

    // Exact requirement:
    // Every attempt gets maximum 30 minutes.
    remainingSeconds = 30 * 60;
  }

  // ============================================================
  // START TIMER
  // ============================================================

  void _startTimer() {
    _timer?.cancel();

    if (remainingSeconds <= 0) {
      _autoSubmitTest();
      return;
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      if (remainingSeconds <= 1) {
        _timer?.cancel();

        setState(() {
          remainingSeconds = 0;
        });

        _autoSubmitTest();
        return;
      }

      setState(() {
        remainingSeconds--;
      });
    });
  }

  // ============================================================
  // FORMATTED TIMER
  // ============================================================

  String get formattedTime {
    final minutes = (remainingSeconds ~/ 60).toString().padLeft(2, '0');

    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');

    return '$minutes:$seconds';
  }

  Color get timerColor {
    if (remainingSeconds <= 60) {
      return const Color(0xffDC2626);
    }

    if (remainingSeconds <= 300) {
      return const Color(0xffF59E0B);
    }

    return primary;
  }

  // ============================================================
  // SELECT ANSWER
  // ============================================================

  Future<void> selectAnswer(String answer) async {
    if (isAnswering ||
        isSubmittingTest ||
        testSubmitted ||
        remainingSeconds <= 0 ||
        currentQuestion == null ||
        attempt?.attemptId == null) {
      return;
    }

    final questionId = int.tryParse(currentQuestion!.id.toString());

    if (questionId == null) return;

    setState(() {
      selectedAnswers[questionId] = answer;
      isAnswering = true;
    });

    try {
      final response = await McqService.submitMcqAnswer(
        attempt!.attemptId!,
        widget.student.id,
        questionId,
        answer,
      );

      if (!mounted) return;

      if (response.statusCode < 200 || response.statusCode >= 300) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xffDC2626),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            content: const Text('Unable to save your answer.'),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xffDC2626),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: const Text('Network error. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isAnswering = false;
        });
      }
    }
  }

  // ============================================================
  // AUTO SUBMIT
  // ============================================================

  Future<void> _autoSubmitTest() async {
    if (testSubmitted || isSubmittingTest || attempt?.attemptId == null) {
      return;
    }

    autoSubmitted = true;

    await _submitTest();
  }

  // ============================================================
  // SUBMIT CONFIRMATION
  // ============================================================

  void _showSubmitConfirmation() {
    if (isSubmittingTest || testSubmitted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: border,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                const SizedBox(height: 24),

                Container(
                  height: 64,
                  width: 64,
                  decoration: const BoxDecoration(
                    color: Color(0xffEEF2FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.assignment_turned_in_rounded,
                    color: primary,
                    size: 32,
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'Submit Your Test?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: textDark,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  unansweredCount == 0
                      ? 'You have answered all $totalQuestions questions.'
                      : 'You still have $unansweredCount unanswered question${unansweredCount == 1 ? '' : 's'}.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: textMuted,
                  ),
                ),

                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _miniSubmitStat(
                          Icons.check_circle_rounded,
                          '$answeredCount',
                          'Answered',
                          const Color(0xff16A34A),
                        ),
                      ),
                      Expanded(
                        child: _miniSubmitStat(
                          Icons.help_outline_rounded,
                          '$unansweredCount',
                          'Remaining',
                          const Color(0xffF59E0B),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: textDark,
                          side: const BorderSide(color: border),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          'Continue Test',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _submitTest();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          'Yes, Submit',
                          style: TextStyle(fontWeight: FontWeight.w700),
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

  Widget _miniSubmitStat(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: textDark,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 10, color: textMuted)),
      ],
    );
  }

  // ============================================================
  // SUBMIT TEST
  // ============================================================

  Future<void> _submitTest() async {
    if (isSubmittingTest || testSubmitted || attempt?.attemptId == null) {
      return;
    }

    setState(() {
      isSubmittingTest = true;
    });

    _timer?.cancel();

    try {
      final response = await McqService.submitMcqTest(
        attempt!.attemptId!,
        widget.student.id,
      );

      if (!mounted) return;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = ApiService.decodeResponse(response);

        if (data is Map<String, dynamic>) {
          try {
            final completedAttempt = McqAttempt.fromJson(data);

            attempt = completedAttempt;

            resultScore = completedAttempt.score ?? 0;

            resultTotal = completedAttempt.totalQuestions ?? totalQuestions;

            resultPercentage = completedAttempt.percentage ?? 0;
          } catch (_) {
            _calculateLocalResult();
          }
        } else {
          _calculateLocalResult();
        }

        if (resultTotal <= 0) {
          resultTotal = totalQuestions;
        }

        setState(() {
          isSubmittingTest = false;
          testSubmitted = true;
        });
      } else {
        setState(() {
          isSubmittingTest = false;
        });

        _showErrorSnackBar('Unable to submit test (${response.statusCode})');
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isSubmittingTest = false;
      });

      _showErrorSnackBar('Failed to submit test. Please try again.');
    }
  }

  // ============================================================
  // LOCAL RESULT FALLBACK
  // ============================================================

  void _calculateLocalResult() {
    resultScore = selectedAnswers.length;
    resultTotal = totalQuestions;

    resultPercentage = resultTotal == 0 ? 0 : (resultScore / resultTotal) * 100;
  }

  // ============================================================
  // ERROR
  // ============================================================

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xffDC2626),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Text(message),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    // IMPORTANT:
    // No start-time restriction here.
    //
    // Test availability should be controlled from the test list:
    // 1. Scheduled date must be today.
    // 2. Student class must match test class.
    //
    // Once user opens this screen, they can start anytime today.

    if (isSubmittingTest) {
      return _buildSubmittingScreen();
    }

    if (testSubmitted) {
      return _buildAchievementScreen();
    }

    if (!testStarted) {
      return _buildTestIntroduction();
    }

    return _buildTestScreen();
  }

  // ============================================================
  // INTRODUCTION
  // ============================================================

  Widget _buildTestIntroduction() {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: textDark,
        title: const Text(
          'Daily Test',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          child: Column(
            children: [
              _premiumTestHero(),

              const SizedBox(height: 18),

              _testInfoCard(),

              const SizedBox(height: 18),

              _instructionsCard(),

              const SizedBox(height: 22),

              if (errorMessage != null) _inlineError(),

              const SizedBox(height: 4),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isStartingTest ? null : startTest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: primary.withOpacity(0.5),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 17),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),
                  child: isStartingTest
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.play_arrow_rounded, size: 23),
                            SizedBox(width: 7),
                            Text(
                              'Start Test',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
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
  // HERO
  // ============================================================

  Widget _premiumTestHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [primaryDark, primary, Color(0xff6688F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.20),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -25,
            child: Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: -40,
            child: Container(
              height: 90,
              width: 90,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'DAILY MCQ CHALLENGE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                widget.test.subject,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 7),

              Text(
                'Show what you know. Give your best!',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.78),
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 22),

              Row(
                children: [
                  _heroMiniInfo(
                    Icons.quiz_rounded,
                    '$totalQuestions Questions',
                  ),
                  const SizedBox(width: 10),
                  _heroMiniInfo(Icons.timer_outlined, '30 Min'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroMiniInfo(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TEST INFO
  // ============================================================

  Widget _testInfoCard() {
    return _whiteCard(
      child: Column(
        children: [
          _infoRow(Icons.person_rounded, 'Student', widget.student.name),
          const Divider(height: 22, color: border),
          _infoRow(Icons.calendar_today_rounded, 'Date', widget.test.date),
          const Divider(height: 22, color: border),
          _infoRow(Icons.access_time_rounded, 'Available From', '12:00 AM'),
          const Divider(height: 22, color: border),
          _infoRow(Icons.timer_rounded, 'Attempt Time', '30 minutes'),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Container(
          height: 38,
          width: 38,
          decoration: BoxDecoration(
            color: const Color(0xffEEF2FF),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: primary, size: 19),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 12, color: textMuted),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: textDark,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // INSTRUCTIONS
  // ============================================================

  Widget _instructionsCard() {
    return _whiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Before You Start',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: textDark,
            ),
          ),
          const SizedBox(height: 14),
          _instruction(
            Icons.timer_outlined,
            'Once started, you have 30 minutes to complete the test.',
          ),
          _instruction(
            Icons.touch_app_rounded,
            'Select one answer for each question.',
          ),
          _instruction(
            Icons.cloud_done_rounded,
            'Your answers are saved while you answer.',
          ),
          _instruction(
            Icons.lock_outline_rounded,
            'When time reaches zero, the test is submitted automatically.',
          ),
        ],
      ),
    );
  }

  Widget _instruction(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19, color: primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                height: 1.4,
                color: textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INLINE ERROR
  // ============================================================

  Widget _inlineError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: const Color(0xffFEF2F2),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xffFECACA)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xffDC2626),
            size: 20,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              errorMessage!,
              style: const TextStyle(color: Color(0xffB91C1C), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TEST SCREEN
  // ============================================================

  Widget _buildTestScreen() {
    if (currentQuestion == null) {
      return const Scaffold(
        backgroundColor: background,
        body: Center(child: Text('No questions available.')),
      );
    }

    final questionId = int.tryParse(currentQuestion!.id.toString());

    final selectedAnswer = questionId == null
        ? null
        : selectedAnswers[questionId];

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: textDark,
        automaticallyImplyLeading: false,
        titleSpacing: 18,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Test',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            Text(
              widget.test.subject,
              style: const TextStyle(
                fontSize: 10,
                color: textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [_timerBadge(), const SizedBox(width: 14)],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _questionProgress(),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
                child: Column(
                  children: [
                    _questionHeader(),

                    const SizedBox(height: 14),

                    _questionCard(selectedAnswer: selectedAnswer),

                    const SizedBox(height: 16),

                    _questionNavigator(),

                    const SizedBox(height: 10),
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
  // TIMER BADGE
  // ============================================================

  Widget _timerBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: timerColor.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: timerColor.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          Icon(Icons.timer_rounded, size: 17, color: timerColor),
          const SizedBox(width: 6),
          Text(
            formattedTime,
            style: TextStyle(
              color: timerColor,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // QUESTION PROGRESS
  // ============================================================

  Widget _questionProgress() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(18, 3, 18, 12),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Question ${currentQuestionIndex + 1}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: textMuted,
                ),
              ),
              const Spacer(),
              Text(
                '$answeredCount/$totalQuestions answered',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: const Color(0xffE9EDF5),
              valueColor: const AlwaysStoppedAnimation(primary),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // QUESTION HEADER
  // ============================================================

  Widget _questionHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xffEEF2FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            'QUESTION ${currentQuestionIndex + 1}',
            style: const TextStyle(
              color: primary,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const Spacer(),
        Text(
          '$totalQuestions Questions',
          style: const TextStyle(fontSize: 11, color: textMuted),
        ),
      ],
    );
  }

  // ============================================================
  // QUESTION CARD
  // ============================================================

  Widget _questionCard({required String? selectedAnswer}) {
    final questionText = currentQuestion!.question;

    final options = <String>[
      currentQuestion!.optionA,
      currentQuestion!.optionB,
      currentQuestion!.optionC,
      currentQuestion!.optionD,
    ];

    return _whiteCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            questionText,
            style: const TextStyle(
              fontSize: 17,
              height: 1.45,
              fontWeight: FontWeight.w800,
              color: textDark,
            ),
          ),

          const SizedBox(height: 20),

          ...List.generate(options.length, (index) {
            final option = options[index];

            if (option.trim().isEmpty) {
              return const SizedBox.shrink();
            }

            final letter = String.fromCharCode(65 + index);

            final isSelected = selectedAnswer == letter;

            return _optionTile(
              letter: letter,
              text: option,
              isSelected: isSelected,
              onTap: () {
                selectAnswer(letter);
              },
            );
          }),

          if (isAnswering)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 14,
                    width: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: primary,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Saving answer...',
                    style: TextStyle(fontSize: 11, color: textMuted),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // OPTION
  // ============================================================

  Widget _optionTile({
    required String letter,
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.only(bottom: 11),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xffEEF2FF) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? primary : border,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 38,
                  width: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? primary : const Color(0xffF1F4F9),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    letter,
                    style: TextStyle(
                      color: isSelected ? Colors.white : textMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: textDark,
                    ),
                  ),
                ),

                if (isSelected)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: primary,
                    size: 22,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // QUESTION NAVIGATOR
  // ============================================================

  Widget _questionNavigator() {
    return _whiteCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Question Navigator',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  _legendDot(primary, 'Answered'),
                  const SizedBox(width: 10),
                  _legendDot(const Color(0xffE8ECF3), 'Pending'),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(totalQuestions, (index) {
              final question = questions[index];

              final id = int.tryParse(question.id.toString());

              final answered = id != null && selectedAnswers.containsKey(id);

              final isCurrent = index == currentQuestionIndex;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    currentQuestionIndex = index;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  height: 38,
                  width: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? primary
                        : answered
                        ? const Color(0xffDCFCE7)
                        : const Color(0xffF1F4F8),
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(
                      color: isCurrent
                          ? primary
                          : answered
                          ? const Color(0xffBBF7D0)
                          : border,
                    ),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: isCurrent
                          ? Colors.white
                          : answered
                          ? const Color(0xff15803D)
                          : textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String text) {
    return Row(
      children: [
        Container(
          height: 7,
          width: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 9, color: textMuted)),
      ],
    );
  }

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  Widget _bottomNavigation() {
    final isLast = currentQuestionIndex == totalQuestions - 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (currentQuestionIndex > 0)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      currentQuestionIndex--;
                    });
                  },
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const Text('Previous'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: textDark,
                    side: const BorderSide(color: border),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              )
            else
              const SizedBox.shrink(),

            if (currentQuestionIndex > 0) const SizedBox(width: 10),

            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: isLast
                    ? _showSubmitConfirmation
                    : () {
                        setState(() {
                          currentQuestionIndex++;
                        });
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isLast ? const Color(0xff16A34A) : primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isLast
                          ? Icons.check_circle_rounded
                          : Icons.arrow_forward_rounded,
                      size: 19,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      isLast ? 'Review & Submit' : 'Next Question',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
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
      backgroundColor: background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 92,
                  width: 92,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [primaryDark, primary]),
                    shape: BoxShape.circle,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(28),
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Submitting Your Test',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    color: textDark,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Please wait while we calculate your result...',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, height: 1.5, color: textMuted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ACHIEVEMENT SCREEN
  // ============================================================

  Widget _buildAchievementScreen() {
    final percentage = resultPercentage.round();

    final studentName = widget.student.name.trim();

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FF),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
          child: Column(
            children: [
              _achievementTop(),

              const SizedBox(height: 16),

              _achievementShareCard(
                percentage: percentage,
                studentName: studentName,
              ),

              const SizedBox(height: 16),

              _achievementStats(percentage: percentage),

              const SizedBox(height: 18),

              _achievementMessage(percentage: percentage),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _shareAchievement,
                  icon: const Icon(Icons.share_rounded, size: 19),
                  label: const Text(
                    'Share Achievement',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff16A34A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 11),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primary,
                    side: const BorderSide(color: border),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Back to Tests',
                    style: TextStyle(fontWeight: FontWeight.w800),
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
  // ACHIEVEMENT TOP
  // ============================================================

  Widget _achievementTop() {
    return Column(
      children: [
        Container(
          height: 70,
          width: 70,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xffF59E0B), Color(0xffFBBF24)],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xffF59E0B).withOpacity(0.25),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.emoji_events_rounded,
            color: Colors.white,
            size: 36,
          ),
        ),

        const SizedBox(height: 13),

        const Text(
          'Test Completed!',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w900,
            color: textDark,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          autoSubmitted
              ? 'Time is up — your test was submitted automatically.'
              : 'What a great achievement!',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: textMuted),
        ),
      ],
    );
  }

  // ============================================================
  // ACHIEVEMENT SHARE CARD
  // ============================================================

  Widget _achievementShareCard({
    required int percentage,
    required String studentName,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff18245B), Color(0xff3155D9), Color(0xff6B5FEA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.20),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -35,
            top: -40,
            child: Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.07),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Positioned(
            left: -45,
            bottom: -55,
            child: Container(
              height: 130,
              width: 130,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Column(
            children: [
              const Text(
                '✨ ACHIEVEMENT UNLOCKED ✨',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 22),

              Container(
                height: 74,
                width: 74,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.25)),
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: Color(0xffFCD34D),
                  size: 38,
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'CONGRATULATIONS!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.6,
                ),
              ),

              const SizedBox(height: 9),

              Text(
                studentName.isEmpty ? 'Our Star Student' : studentName,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                'successfully completed',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),

              const SizedBox(height: 5),

              Text(
                '${widget.test.subject} MCQ Test',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.12)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '$resultScore',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            'SCORE',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      height: 45,
                      width: 1,
                      color: Colors.white.withOpacity(0.18),
                    ),

                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '$resultTotal',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            'QUESTIONS',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      height: 45,
                      width: 1,
                      color: Colors.white.withOpacity(0.18),
                    ),

                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '$percentage%',
                            style: const TextStyle(
                              color: Color(0xffFCD34D),
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            'RESULT',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              const Text(
                'Every test is a step towards success! 🌟',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                ),
              ),

              const SizedBox(height: 18),

              Container(height: 1, color: Colors.white.withOpacity(0.12)),

              const SizedBox(height: 13),

              const Text(
                'KEEP LEARNING • KEEP GROWING • KEEP SHINING',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACHIEVEMENT STATS
  // ============================================================

  Widget _achievementStats({required int percentage}) {
    return Row(
      children: [
        Expanded(
          child: _achievementStat(
            Icons.check_circle_rounded,
            '$resultScore/$resultTotal',
            'Correct Score',
            const Color(0xff16A34A),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _achievementStat(
            Icons.percent_rounded,
            '$percentage%',
            'Percentage',
            primary,
          ),
        ),
      ],
    );
  }

  Widget _achievementStat(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: textDark,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(fontSize: 10, color: textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACHIEVEMENT MESSAGE
  // ============================================================

  Widget _achievementMessage({required int percentage}) {
    String title;
    String message;

    if (percentage >= 90) {
      title = 'Outstanding Work! 🏆';
      message = 'An amazing performance! Your hard work is clearly showing.';
    } else if (percentage >= 75) {
      title = 'Excellent Work! 🌟';
      message = 'You did really well. Keep this momentum going!';
    } else if (percentage >= 60) {
      title = 'Great Effort! 💪';
      message = 'You are making progress. Keep practicing and aim even higher!';
    } else {
      title = 'Keep Going! 🚀';
      message =
          'Every test helps you learn. Practice more and your next score can be even better!';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xffFFF9E8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xffFDE68A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🌟', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.45,
                    color: textMuted,
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
  // SHARE
  // ============================================================

  Future<void> _shareAchievement() async {
    final percentage = resultPercentage.round();

    final studentName = widget.student.name.trim();

    final message =
        '''
🎉 CONGRATULATIONS! 🎉

${studentName.isEmpty ? 'Our Star Student' : studentName}
successfully completed the
${widget.test.subject} MCQ Test.

🏆 Score: $resultScore / $resultTotal
📊 Result: $percentage%

✨ Every test is a step towards success!

Keep Learning • Keep Growing • Keep Shining 🌟
''';

    await Share.share(message);
  }

  // ============================================================
  // WHITE CARD
  // ============================================================

  Widget _whiteCard({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(18),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
