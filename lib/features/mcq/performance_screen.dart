import 'package:flutter/material.dart';



import 'package:parent_app/models/mcq_attempt.dart';

import 'package:parent_app/models/student_response.dart';
import '../../services/api_service.dart';

class PerformanceScreen extends StatefulWidget {
  final StudentResponse student;

  const PerformanceScreen({
    super.key,
    required this.student,
  });

  @override
  State<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen> {
  bool isLoading = true;
  String? errorMessage;

  List<McqAttempt> history = [];

  @override
  void initState() {
    super.initState();
    _loadPerformance();
  }

  // ============================================================
  // LOAD MCQ HISTORY
  // ============================================================

  Future<void> _loadPerformance() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await ApiService.getMcqHistory(
        widget.student.id,
      );

      if (!mounted) return;

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        final data = ApiService.decodeResponse(response);

        if (data is List) {
          history = data
              .whereType<Map<String, dynamic>>()
              .map(McqAttempt.fromJson)
              .where(_isCompleted)
              .toList();
        } else {
          history = [];
        }

        setState(() {
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage =
              'Unable to load performance (${response.statusCode})';
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load performance.';
      });
    }
  }

  // ============================================================
  // COMPLETED TESTS ONLY
  // ============================================================

  bool _isCompleted(McqAttempt attempt) {
    final status = attempt.status?.toUpperCase();

    return status == 'SUBMITTED' ||
        status == 'COMPLETED' ||
        attempt.submittedAt != null;
  }

  // ============================================================
  // CALCULATIONS
  // ============================================================

  int get totalTests => history.length;

  int get testsCompleted => history.length;

  double get averageScore {
    if (history.isEmpty) return 0;

    final percentages = history
        .map((attempt) => attempt.percentage ?? 0)
        .toList();

    final total = percentages.fold<double>(
      0,
      (sum, value) => sum + value,
    );

    return total / percentages.length;
  }

  double get highestScore {
    if (history.isEmpty) return 0;

    return history
        .map((attempt) => attempt.percentage ?? 0)
        .reduce((a, b) => a > b ? a : b);
  }

  // ============================================================
  // SUBJECT PERFORMANCE
  // ============================================================

  List<Map<String, dynamic>> get subjectPerformance {
    final Map<String, List<McqAttempt>> grouped = {};

    for (final attempt in history) {
      final subject =
          attempt.test?.subject.trim().isNotEmpty == true
              ? attempt.test!.subject.trim()
              : 'Other';

      grouped.putIfAbsent(subject, () => []);
      grouped[subject]!.add(attempt);
    }

    final result = <Map<String, dynamic>>[];

    for (final entry in grouped.entries) {
      final attempts = entry.value;

      final total = attempts.fold<double>(
        0,
        (sum, attempt) =>
            sum + (attempt.percentage ?? 0),
      );

      final average = attempts.isEmpty
          ? 0.0
          : total / attempts.length;

      result.add({
        'subject': entry.key,
        'score': average.round(),
        'tests': attempts.length,
        'icon': _subjectIcon(entry.key),
      });
    }

    result.sort(
      (a, b) => (b['score'] as int)
          .compareTo(a['score'] as int),
    );

    return result;
  }

  IconData _subjectIcon(String subject) {
    final value = subject.toLowerCase();

    if (value.contains('math')) {
      return Icons.calculate_rounded;
    }

    if (value.contains('english')) {
      return Icons.menu_book_rounded;
    }

    if (value.contains('science')) {
      return Icons.science_rounded;
    }

    if (value.contains('social')) {
      return Icons.public_rounded;
    }

    return Icons.quiz_rounded;
  }

  // ============================================================
  // RECENT TESTS
  // ============================================================

  List<McqAttempt> get recentTests {
    final sorted = [...history];

    sorted.sort((a, b) {
      final aDate =
          a.submittedAt ?? a.startedAt;

      final bDate =
          b.submittedAt ?? b.startedAt;

      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;

      return bDate.compareTo(aDate);
    });

    return sorted.take(5).toList();
  }

  // ============================================================
  // PERFORMANCE LABEL
  // ============================================================

  String get performanceLabel {
    final score = averageScore;

    if (history.isEmpty) {
      return 'No Data';
    }

    if (score >= 90) {
      return 'Excellent';
    }

    if (score >= 75) {
      return 'Very Good';
    }

    if (score >= 60) {
      return 'Good';
    }

    return 'Keep Practicing';
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F8FC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xff172033),
        elevation: 0,
        title: const Text(
          'My Performance',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xff4169E1),
              ),
            )
          : errorMessage != null
              ? _errorView()
              : RefreshIndicator(
                  onRefresh: _loadPerformance,
                  color: const Color(0xff4169E1),
                  child: history.isEmpty
                      ? _emptyView()
                      : _performanceBody(),
                ),
    );
  }

  // ============================================================
  // PERFORMANCE BODY
  // ============================================================

  Widget _performanceBody() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _studentHeader(),

          const SizedBox(height: 20),

          _overallPerformanceCard(),

          const SizedBox(height: 20),

          const Text(
            'Test Statistics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xff172033),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _statCard(
                  icon: Icons.quiz_rounded,
                  title: 'Total Tests',
                  value: '$totalTests',
                  color:
                      const Color(0xff4169E1),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _statCard(
                  icon:
                      Icons.check_circle_rounded,
                  title: 'Completed',
                  value: '$testsCompleted',
                  color: Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _statCard(
                  icon:
                      Icons.analytics_rounded,
                  title: 'Average',
                  value:
                      '${averageScore.round()}%',
                  color: Colors.orange,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _statCard(
                  icon:
                      Icons.emoji_events_rounded,
                  title: 'Best Score',
                  value:
                      '${highestScore.round()}%',
                  color: Colors.purple,
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),

          // SUBJECT PERFORMANCE

          const Text(
            'Subject Performance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xff172033),
            ),
          ),

          const SizedBox(height: 12),

          ...subjectPerformance.map(
            (subject) =>
                _subjectCard(subject: subject),
          ),

          const SizedBox(height: 25),

          // RECENT TESTS

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Tests',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff172033),
                ),
              ),

              if (history.length > 5)
                TextButton(
                  onPressed: () {
                    _showAllTests(context);
                  },
                  child: const Text('View All'),
                ),
            ],
          ),

          const SizedBox(height: 8),

          ...recentTests.map(
            (test) => _recentTestCard(
              test: test,
            ),
          ),

          const SizedBox(height: 25),

          _motivationCard(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ============================================================
  // STUDENT HEADER
  // ============================================================

  Widget _studentHeader() {
    final studentName = widget.student.name;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xff4169E1),
            Color(0xff6387F5),
          ],
        ),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            height: 58,
            width: 58,
            decoration: BoxDecoration(
              color:
                  Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              size: 32,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Student Performance',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  studentName,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 3),

                const Text(
                  'Keep learning, keep growing! 🌟',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
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
  // OVERALL PERFORMANCE
  // ============================================================

  Widget _overallPerformanceCard() {
    final average =
        averageScore.round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset:
                const Offset(0, 4),
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
                      'Overall Performance',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Based on completed MCQ tests',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                      const Color(0xffDCFCE7),
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: Text(
                  performanceLabel,
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),

          Row(
            children: [
              SizedBox(
                height: 120,
                width: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 120,
                      width: 120,
                      child:
                          CircularProgressIndicator(
                        value: average / 100,
                        strokeWidth: 11,
                        backgroundColor:
                            const Color(
                                0xffE8ECF4),
                        valueColor:
                            const AlwaysStoppedAnimation(
                          Color(0xff4169E1),
                        ),
                      ),
                    ),

                    Column(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        Text(
                          '$average%',
                          style:
                              const TextStyle(
                            fontSize: 24,
                            fontWeight:
                                FontWeight.bold,
                            color:
                                Color(0xff4169E1),
                          ),
                        ),
                        const Text(
                          'Average',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 25),

              Expanded(
                child: Column(
                  children: [
                    _performanceLine(
                      'Tests Completed',
                      '$testsCompleted',
                    ),

                    const SizedBox(height: 15),

                    _performanceLine(
                      'Highest Score',
                      '${highestScore.round()}%',
                    ),

                    const SizedBox(height: 15),

                    _performanceLine(
                      'Average Score',
                      '${averageScore.round()}%',
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
  // PERFORMANCE LINE
  // ============================================================

  Widget _performanceLine(
    String title,
    String value,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color:
                  Colors.grey.shade600,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STAT CARD
  // ============================================================

  Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(17),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color:
                  color.withOpacity(0.10),
              borderRadius:
                  BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 21,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            value,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            title,
            style: TextStyle(
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
  // SUBJECT CARD
  // ============================================================

  Widget _subjectCard({
    required Map<String, dynamic> subject,
  }) {
    final int score =
        subject['score'] as int;

    final Color scoreColor =
        score >= 80
            ? Colors.green
            : score >= 60
                ? Colors.orange
                : Colors.red;

    return Container(
      margin:
          const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(17),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration:
                    BoxDecoration(
                  color:
                      const Color(0xffE8F0FF),
                  borderRadius:
                      BorderRadius.circular(
                          12),
                ),
                child: Icon(
                  subject['icon']
                      as IconData,
                  color:
                      const Color(0xff4169E1),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject['subject']
                          as String,
                      style:
                          const TextStyle(
                        fontSize: 14,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      '${subject['tests']} tests completed',
                      style: TextStyle(
                        fontSize: 11,
                        color:
                            Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                '$score%',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight:
                      FontWeight.bold,
                  color: scoreColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          ClipRRect(
            borderRadius:
                BorderRadius.circular(10),
            child:
                LinearProgressIndicator(
              value: score / 100,
              minHeight: 7,
              backgroundColor:
                  const Color(0xffEDF0F5),
              valueColor:
                  AlwaysStoppedAnimation(
                scoreColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RECENT TEST CARD
  // ============================================================

  Widget _recentTestCard({
    required McqAttempt test,
  }) {
    final percentage =
        (test.percentage ?? 0).round();

    final Color scoreColor =
        percentage >= 80
            ? Colors.green
            : percentage >= 60
                ? Colors.orange
                : Colors.red;

    final title =
        test.test?.subject.isNotEmpty == true
            ? '${test.test!.subject} Test'
            : 'MCQ Test';

    final score =
        test.score ?? 0;

    final total =
        test.totalQuestions ??
        test.test?.questions.length ??
        0;

    final date =
        _formatDate(
          test.submittedAt ??
              test.startedAt,
        );

    return Container(
      margin:
          const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            height: 45,
            width: 45,
            decoration:
                BoxDecoration(
              color:
                  const Color(0xffE8F0FF),
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.quiz_rounded,
              color:
                  Color(0xff4169E1),
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
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    fontSize: 13,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '$date • $score/$total',
                  style: TextStyle(
                    fontSize: 11,
                    color:
                        Colors.grey.shade600,
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
            decoration:
                BoxDecoration(
              color: scoreColor
                  .withOpacity(0.10),
              borderRadius:
                  BorderRadius.circular(
                      10),
            ),
            child: Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    FontWeight.bold,
                color: scoreColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDate(DateTime? date) {
    if (date == null) return '-';

    final local = date.toLocal();

    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year}';
  }

  // ============================================================
  // MOTIVATION
  // ============================================================

  Widget _motivationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient:
            const LinearGradient(
          colors: [
            Color(0xffFFF7E6),
            Color(0xfffff0c7),
          ],
        ),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            '🌟',
            style:
                TextStyle(fontSize: 32),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Keep Going!',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                SizedBox(height: 6),

                Text(
                  'Every test is a chance to learn something new. Keep practicing and make your next score even better!',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.5,
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
  // ALL TESTS
  // ============================================================

  void _showAllTests(
    BuildContext context,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor:
          Colors.white,
      isScrollControlled: true,
      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder:
              (context, scrollController) {
            return Padding(
              padding:
                  const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'All Test History',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Expanded(
                    child: ListView.builder(
                      controller:
                          scrollController,
                      itemCount:
                          history.length,
                      itemBuilder:
                          (context, index) {
                        return _recentTestCard(
                          test: history[index],
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // EMPTY VIEW
  // ============================================================

  Widget _emptyView() {
    return RefreshIndicator(
      onRefresh: _loadPerformance,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding:
            const EdgeInsets.all(30),
        children: [
          const SizedBox(height: 100),

          const Icon(
            Icons.analytics_outlined,
            size: 80,
            color:
                Color(0xff4169E1),
          ),

          const SizedBox(height: 20),

          const Text(
            'No Test Results Yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            '${widget.student.name} has not completed any MCQ tests yet.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color:
                  Colors.grey.shade600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR VIEW
  // ============================================================

  Widget _errorView() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(30),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red,
            ),

            const SizedBox(height: 15),

            Text(
              errorMessage ??
                  'Something went wrong.',
              textAlign:
                  TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed:
                  _loadPerformance,
              child:
                  const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}