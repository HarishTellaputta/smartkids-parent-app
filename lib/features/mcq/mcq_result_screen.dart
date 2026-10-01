
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:parent_app/models/mcq_attempt.dart';

class McqResultScreen extends StatelessWidget {
  final McqAttempt attempt;
  final bool autoSubmitted;

  const McqResultScreen({
    super.key,
    required this.attempt,
    required this.autoSubmitted,
  });

  static const Color primary = Color(0xff3155D9);
  static const Color primaryDark = Color(0xff2343B8);
  static const Color background = Color(0xffF6F8FC);
  static const Color textDark = Color(0xff172033);
  static const Color textMuted = Color(0xff697386);
  static const Color border = Color(0xffE5E9F0);

  @override
  Widget build(BuildContext context) {
    final totalQuestions =
        attempt.totalQuestions ??
        attempt.test?.questions.length ??
        0;

    final score = attempt.score ?? 0;

    final correctAnswers =
        attempt.correctAnswers ?? 0;

    final wrongAnswers =
        attempt.wrongAnswers ?? 0;

    final answered =
        correctAnswers + wrongAnswers;

    final unanswered =
        totalQuestions - answered < 0
            ? 0
            : totalQuestions - answered;

    final percentage =
        attempt.percentage?.round() ??
        (totalQuestions == 0
            ? 0
            : ((score / totalQuestions) * 100)
                .round());

    final subject =
        attempt.test?.subject.isNotEmpty == true
            ? attempt.test!.subject
            : 'MCQ';

    final duration =
        attempt.test?.duration ?? 0;

    return Scaffold(
      backgroundColor: background,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          physics:
              const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            18,
            18,
            18,
            28,
          ),
          child: Column(
            children: [
              _buildAchievementHeader(),

              const SizedBox(height: 20),

              _buildScoreCard(
                score: score,
                totalQuestions: totalQuestions,
                percentage: percentage,
              ),

              const SizedBox(height: 14),

              _buildStats(
                correct: correctAnswers,
                wrong: wrongAnswers,
                skipped: unanswered,
              ),

              const SizedBox(height: 16),

              _buildPerformanceMessage(
                percentage: percentage,
              ),

              const SizedBox(height: 16),

              _buildTestDetails(
                subject: subject,
                totalQuestions: totalQuestions,
                duration: duration,
              ),

              const SizedBox(height: 22),

              _buildHomeButton(context),

              const SizedBox(height: 10),

              const Text(
                'Keep learning • Keep growing • Keep shining ✨',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // APP BAR
  // ============================================================

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
  ) {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: textDark,
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: true,
      title: const Text(
        'Test Result',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: textDark,
        ),
      ),
    );
  }

  // ============================================================
  // ACHIEVEMENT HEADER
  // ============================================================

  Widget _buildAchievementHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        22,
        26,
        22,
        24,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primary,
            primaryDark,
          ],
        ),
        borderRadius:
            BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color:
                primary.withOpacity(.20),
            blurRadius: 24,
            offset:
                const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -25,
            top: -35,
            child: Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: Colors.white
                    .withOpacity(.07),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Positioned(
            left: -35,
            bottom: -65,
            child: Container(
              height: 130,
              width: 130,
              decoration: BoxDecoration(
                color: Colors.white
                    .withOpacity(.05),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Column(
            children: [
              Container(
                height: 68,
                width: 68,
                decoration: BoxDecoration(
                  color: Colors.white
                      .withOpacity(.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white
                        .withOpacity(.22),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: Colors.white,
                  size: 35,
                ),
              ),

              const SizedBox(height: 15),

              Text(
                autoSubmitted
                    ? 'TIME\'S UP!'
                    : 'TEST COMPLETED!',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .4,
                ),
              ),

              const SizedBox(height: 7),

              Text(
                autoSubmitted
                    ? 'Your test was submitted automatically.'
                    : 'Great job! Your answers have been submitted.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white
                      .withOpacity(.82),
                  fontSize: 12,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 15),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white
                      .withOpacity(.12),
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.menu_book_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      attempt.test?.subject
                                  .isNotEmpty ==
                              true
                          ? attempt.test!.subject
                          : 'MCQ Test',
                      style:
                          const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SCORE CARD
  // ============================================================

  Widget _buildScoreCard({
    required int score,
    required int totalQuestions,
    required int percentage,
  }) {
    final safePercentage =
        percentage.clamp(0, 100);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(24),
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
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Score',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                            FontWeight.w800,
                        color: textDark,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Your performance summary',
                      style: TextStyle(
                        fontSize: 11,
                        color: textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                      const Color(0xffEEF2FF),
                  borderRadius:
                      BorderRadius.circular(9),
                ),
                child: Text(
                  '$safePercentage%',
                  style: const TextStyle(
                    color: primary,
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          SizedBox(
            height: 175,
            width: 175,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 175,
                  width: 175,
                  child:
                      CircularProgressIndicator(
                    value:
                        safePercentage / 100,
                    strokeWidth: 13,
                    backgroundColor:
                        const Color(
                            0xffEDF0F5),
                    valueColor:
                        const AlwaysStoppedAnimation(
                      primary,
                    ),
                    strokeCap:
                        StrokeCap.round,
                  ),
                ),

                Container(
                  height: 132,
                  width: 132,
                  decoration:
                      const BoxDecoration(
                    color: Color(0xffF8F9FC),
                    shape: BoxShape.circle,
                  ),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Text(
                        '$score',
                        style:
                            const TextStyle(
                          fontSize: 39,
                          fontWeight:
                              FontWeight.w900,
                          color: textDark,
                        ),
                      ),
                      Text(
                        'out of $totalQuestions',
                        style:
                            const TextStyle(
                          fontSize: 11,
                          fontWeight:
                              FontWeight.w600,
                          color: textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 17),

          Text(
            _scoreLabel(safePercentage),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: textDark,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            '$safePercentage% score achieved',
            style: const TextStyle(
              fontSize: 11,
              color: textMuted,
            ),
          ),
        ],
      ),
    );
  }

  String _scoreLabel(int percentage) {
    if (percentage >= 90) {
      return 'Excellent work! 🌟';
    }

    if (percentage >= 75) {
      return 'Great performance! 👏';
    }

    if (percentage >= 50) {
      return 'Good effort! 💪';
    }

    return 'Keep practicing! 📚';
  }

  // ============================================================
  // RESULT STATS
  // ============================================================

  Widget _buildStats({
    required int correct,
    required int wrong,
    required int skipped,
  }) {
    return Row(
      children: [
        Expanded(
          child: _resultStat(
            icon:
                Icons.check_circle_rounded,
            title: 'Correct',
            value: '$correct',
            color:
                const Color(0xff16A34A),
            background:
                const Color(0xffECFDF3),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _resultStat(
            icon: Icons.cancel_rounded,
            title: 'Wrong',
            value: '$wrong',
            color:
                const Color(0xffDC2626),
            background:
                const Color(0xffFFF1F2),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _resultStat(
            icon:
                Icons.remove_circle_rounded,
            title: 'Skipped',
            value: '$skipped',
            color:
                const Color(0xffD97706),
            background:
                const Color(0xfffff7ed),
          ),
        ),
      ],
    );
  }

  Widget _resultStat({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required Color background,
  }) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        vertical: 17,
        horizontal: 5,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(17),
        border: Border.all(
          color: border,
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 37,
            width: 37,
            decoration: BoxDecoration(
              color: background,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),

          const SizedBox(height: 9),

          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: textDark,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: textMuted,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PERFORMANCE MESSAGE
  // ============================================================

  Widget _buildPerformanceMessage({
    required int percentage,
  }) {
    IconData icon;
    String title;
    String message;

    if (percentage >= 90) {
      icon = Icons.auto_awesome_rounded;
      title = 'Outstanding!';
      message =
          'You are showing excellent understanding. Keep this momentum going.';
    } else if (percentage >= 75) {
      icon = Icons.celebration_rounded;
      title = 'Well Done!';
      message =
          'A strong performance. Keep practicing to reach the next level.';
    } else if (percentage >= 50) {
      icon = Icons.trending_up_rounded;
      title = 'Good Effort!';
      message =
          'You are making progress. Review the difficult topics and try again.';
    } else {
      icon = Icons.menu_book_rounded;
      title = 'Keep Practicing!';
      message =
          'Every test is a learning opportunity. Practice regularly and improve.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xffEEF2FF),
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xffDDE5FF),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: primary,
              size: 22,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w800,
                    color: textDark,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 11,
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
  // TEST DETAILS
  // ============================================================

  Widget _buildTestDetails({
    required String subject,
    required int totalQuestions,
    required int duration,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
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
          const Text(
            'Test Details',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: textDark,
            ),
          ),

          const SizedBox(height: 16),

          _detailRow(
            icon: Icons.menu_book_rounded,
            title: 'Subject',
            value: subject,
          ),

          _detailRow(
            icon:
                Icons.help_outline_rounded,
            title: 'Questions',
            value:
                '$totalQuestions',
          ),

          _detailRow(
            icon:
                Icons.timer_outlined,
            title: 'Duration',
            value:
                '$duration Minutes',
          ),

          _detailRow(
            icon:
                Icons.check_circle_outline_rounded,
            title: 'Submission',
            value: autoSubmitted
                ? 'Automatically Submitted'
                : 'Submitted by Student',
            last: true,
          ),
        ],
      ),
    );
  }

  Widget _detailRow({
    required IconData icon,
    required String title,
    required String value,
    bool last = false,
  }) {
    return Padding(
      padding:
          EdgeInsets.only(
        bottom: last ? 0 : 13,
      ),
      child: Row(
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color:
                  const Color(0xffF1F4FA),
              borderRadius:
                  BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: primary,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: textMuted,
                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ),

          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 12,
                fontWeight:
                    FontWeight.w700,
                color: textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HOME BUTTON
  // ============================================================

  Widget _buildHomeButton(
    BuildContext context,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: () {
          Navigator.popUntil(
            context,
            (route) => route.isFirst,
          );
        },
        style:
            ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(16),
          ),
        ),
        child: const Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.home_rounded,
              size: 19,
            ),
            SizedBox(width: 8),
            Text(
              'Back to Home',
              style: TextStyle(
                fontSize: 14,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

