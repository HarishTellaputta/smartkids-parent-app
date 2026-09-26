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
            : ((score / totalQuestions) * 100).round());

    final subject =
        attempt.test?.subject.isNotEmpty == true
            ? attempt.test!.subject
            : 'MCQ';

    return Scaffold(
      backgroundColor: const Color(0xffF6F8FC),

      appBar: AppBar(
        title: const Text(
          'Test Result',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor:
            const Color(0xff172033),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            children: [
              const SizedBox(height: 15),

              Container(
                height: 95,
                width: 95,
                decoration: BoxDecoration(
                  color:
                      const Color(0xffDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 52,
                  color: Colors.green,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                autoSubmitted
                    ? 'Test Auto-Submitted'
                    : 'Test Completed!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff172033),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                autoSubmitted
                    ? 'Time limit reached. Your test was submitted automatically.'
                    : 'Your test has been submitted successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 30),

              // SCORE
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 30,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(22),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Your Score',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      '$score / $totalQuestions',
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color:
                            Color(0xff4169E1),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      '$percentage%',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color:
                            Color(0xff4169E1),
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
                      icon:
                          Icons.check_circle_rounded,
                      title: 'Correct',
                      value:
                          '$correctAnswers',
                      color: Colors.green,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _resultStat(
                      icon: Icons.cancel_rounded,
                      title: 'Wrong',
                      value: '$wrongAnswers',
                      color: Colors.red,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _resultStat(
                      icon:
                          Icons.remove_circle_rounded,
                      title: 'Skipped',
                      value: '$unanswered',
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // TEST DETAILS
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Test Details',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color:
                            Color(0xff172033),
                      ),
                    ),

                    const SizedBox(height: 16),

                    _detailRow(
                      icon:
                          Icons.menu_book_rounded,
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
                          '${attempt.test?.duration ?? 0} Minutes',
                    ),

                    _detailRow(
                      icon:
                          Icons.check_circle_outline,
                      title: 'Submission',
                      value: autoSubmitted
                          ? 'Automatically Submitted'
                          : 'Submitted by Student',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
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
                    backgroundColor:
                        const Color(0xff4169E1),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _resultStat({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 18,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 25,
          ),

          const SizedBox(height: 8),

          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 15),
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
              size: 19,
              color:
                  const Color(0xff4169E1),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color:
                    Colors.grey.shade600,
              ),
            ),
          ),

          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color:
                    Color(0xff172033),
              ),
            ),
          ),
        ],
      ),
    );
  }
}