import 'package:flutter/material.dart';

import 'package:parent_app/models/mcq_attempt.dart';
import 'package:parent_app/models/student_response.dart';
import 'package:parent_app/services/api_service.dart';

import 'package:parent_app/services/mcq_service.dart';
import 'performance_helpers.dart';
import 'performance_header.dart';
import 'overall_performance_card.dart';
import 'performance_stat_card.dart';
import 'subject_performance_card.dart';
import 'recent_test_card.dart';
import 'motivation_card.dart';

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
  static const Color background = Color(0xFFF6F8FC);
  static const Color textDark = Color(0xFF172033);
  static const Color textMuted = Color(0xFF697386);
  static const Color primary = Color(0xFF3155D9);

  bool isLoading = true;
  String? errorMessage;

  List<McqAttempt> history = [];

  @override
  void initState() {
    super.initState();
    _loadPerformance();
  }

  // ============================================================
  // LOAD PERFORMANCE
  // ============================================================

  Future<void> _loadPerformance() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await McqService.getMcqHistory(
        widget.student.id,
      );

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw Exception(
          'Failed to load performance (${response.statusCode})',
        );
      }

      final decoded = ApiService.decodeResponse(response);

      final List<dynamic> data;

      if (decoded is List) {
        data = decoded;
      } else if (decoded is Map<String, dynamic> &&
          decoded['data'] is List) {
        data = decoded['data'] as List<dynamic>;
      } else if (decoded is Map<String, dynamic> &&
          decoded['content'] is List) {
        data = decoded['content'] as List<dynamic>;
      } else {
        data = [];
      }

      final loadedHistory = data
          .whereType<Map<String, dynamic>>()
          .map(McqAttempt.fromJson)
          .where(_isCompleted)
          .toList();

      if (!mounted) return;

      setState(() {
        history = loadedHistory;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Unable to load performance data.';
      });
    }
  }

  // ============================================================
  // COMPLETED TEST CHECK
  // ============================================================

  bool _isCompleted(McqAttempt attempt) {
    final status = attempt.status?.trim().toUpperCase();

    if (status == 'SUBMITTED' || status == 'COMPLETED') {
      return true;
    }

    return attempt.submittedAt != null;
  }

  // ============================================================
  // CALCULATIONS
  // ============================================================

  int get totalTests => history.length;

  int get testsCompleted => history.length;

  double get averageScore {
    if (history.isEmpty) return 0;

    final total = history.fold<double>(
      0,
      (sum, attempt) {
        return sum + _percentage(attempt);
      },
    );

    return total / history.length;
  }

  double get highestScore {
    if (history.isEmpty) return 0;

    return history
        .map(_percentage)
        .reduce((a, b) => a > b ? a : b);
  }

  double _percentage(McqAttempt attempt) {
    final value = attempt.percentage ?? 0;

    return PerformanceHelpers.clampPercentage(
      value.toDouble(),
    );
  }

  // ============================================================
  // SUBJECT PERFORMANCE
  // ============================================================

  List<Map<String, dynamic>> get subjectPerformance {
    final Map<String, List<double>> grouped = {};

    for (final attempt in history) {
      final rawSubject = attempt.test?.subject.trim();

      final subject = rawSubject == null || rawSubject.isEmpty
          ? 'Other'
          : rawSubject;

      grouped.putIfAbsent(subject, () => []);
      grouped[subject]!.add(_percentage(attempt));
    }

    final result = grouped.entries.map((entry) {
      final scores = entry.value;

      final average = scores.isEmpty
          ? 0.0
          : scores.reduce((a, b) => a + b) / scores.length;

      return {
        'subject': entry.key,
        'score': average.round(),
        'tests': scores.length,
      };
    }).toList();

    result.sort(
      (a, b) => (b['score'] as int).compareTo(
        a['score'] as int,
      ),
    );

    return result;
  }

  // ============================================================
  // RECENT TESTS
  // ============================================================

  List<McqAttempt> get recentTests {
    final sorted = [...history];

    sorted.sort((a, b) {
      final aDate = a.submittedAt ?? a.startedAt;
      final bDate = b.submittedAt ?? b.startedAt;

      if (aDate == null && bDate == null) {
        return 0;
      }

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
    if (history.isEmpty) {
      return 'No Data';
    }

    return PerformanceHelpers.performanceLabel(
      averageScore,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        title: const Text(
          'My Performance',
          style: TextStyle(
            color: textDark,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: const IconThemeData(
          color: textDark,
        ),
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody() {
    if (isLoading) {
      return _buildLoading();
    }

    if (errorMessage != null) {
      return _buildError();
    }

    return RefreshIndicator(
      color: primary,
      onRefresh: _loadPerformance,
      child: history.isEmpty
          ? _buildEmpty()
          : _buildPerformanceContent(),
    );
  }

  // ============================================================
  // PERFORMANCE CONTENT
  // ============================================================

  Widget _buildPerformanceContent() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        28,
      ),
      children: [
        // Student header
        PerformanceHeader(
          student: widget.student,
        ),

        const SizedBox(height: 18),

        // Overall performance
        OverallPerformanceCard(
          averageScore: averageScore,
          highestScore: highestScore,
          testsCompleted: testsCompleted,
          performanceLabel: performanceLabel,
        ),

        const SizedBox(height: 18),

        // Section title
        _sectionTitle(
          title: 'Performance Overview',
          subtitle: 'Your overall test statistics',
        ),

        const SizedBox(height: 11),

        // Statistics
        _buildStatsGrid(),

        const SizedBox(height: 22),

        // Subject performance
        _sectionTitle(
          title: 'Subject Performance',
          subtitle: 'Average score by subject',
        ),

        const SizedBox(height: 11),

        ...subjectPerformance.map(
          (subject) => SubjectPerformanceCard(
            subject: subject['subject'] as String,
            score: subject['score'] as int,
            tests: subject['tests'] as int,
          ),
        ),

        const SizedBox(height: 10),

        // Recent tests
        _buildRecentTestsSection(),

        const SizedBox(height: 10),

        // Motivation
        MotivationCard(
          averageScore: averageScore,
        ),
      ],
    );
  }

  // ============================================================
  // STATISTICS GRID
  // ============================================================

  Widget _buildStatsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final cardWidth = (width - 12) / 2;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: cardWidth,
              child: PerformanceStatCard(
                icon: Icons.assignment_rounded,
                title: 'Total Tests',
                value: '$totalTests',
                color: const Color(0xFF3155D9),
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: PerformanceStatCard(
                icon: Icons.task_alt_rounded,
                title: 'Completed',
                value: '$testsCompleted',
                color: const Color(0xFF16A34A),
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: PerformanceStatCard(
                icon: Icons.analytics_rounded,
                title: 'Average Score',
                value: '${averageScore.round()}%',
                color: const Color(0xFF8B5CF6),
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: PerformanceStatCard(
                icon: Icons.emoji_events_rounded,
                title: 'Highest Score',
                value: '${highestScore.round()}%',
                color: const Color(0xFFF59E0B),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // RECENT TESTS
  // ============================================================

  Widget _buildRecentTestsSection() {
    final tests = recentTests;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          title: 'Recent Tests',
          subtitle: 'Your latest completed tests',
          trailing: history.length > 5
              ? TextButton(
                  onPressed: _showAllTests,
                  style: TextButton.styleFrom(
                    foregroundColor: primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                  ),
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                )
              : null,
        ),

        const SizedBox(height: 11),

        ...tests.map(
          (test) => RecentTestCard(
            test: test,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle({
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        if (trailing != null) trailing,
      ],
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmpty() {
    return RefreshIndicator(
      color: primary,
      onRefresh: _loadPerformance,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 70),

          Container(
            height: 90,
            width: 90,
            margin: const EdgeInsets.symmetric(
              horizontal: 120,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF0FF),
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(
              Icons.analytics_outlined,
              size: 42,
              color: primary,
            ),
          ),

          const SizedBox(height: 22),

          const Text(
            'No Performance Data Yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textDark,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Complete an MCQ test to see your scores, '
            'subject performance and progress here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textMuted,
              fontSize: 12,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 25),

          Center(
            child: OutlinedButton.icon(
              onPressed: _loadPerformance,
              icon: const Icon(
                Icons.refresh_rounded,
                size: 17,
              ),
              label: const Text(
                'Refresh',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: primary,
                side: const BorderSide(
                  color: Color(0xFFD7DDEA),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFE5E9F0),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 58,
                width: 58,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEEEE),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(
                  Icons.cloud_off_rounded,
                  color: Color(0xFFDC2626),
                  size: 28,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Unable to Load Performance',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 7),

              Text(
                errorMessage ??
                    'Something went wrong. Please try again.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: textMuted,
                  fontSize: 11,
                  height: 1.45,
                ),
              ),

              const SizedBox(height: 18),

              ElevatedButton.icon(
                onPressed: _loadPerformance,
                icon: const Icon(
                  Icons.refresh_rounded,
                  size: 17,
                ),
                label: const Text(
                  'Try Again',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
  // LOADING
  // ============================================================

  Widget _buildLoading() {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        20,
      ),
      children: [
        _skeleton(
          height: 150,
          radius: 24,
        ),

        const SizedBox(height: 18),

        _skeleton(
          height: 285,
          radius: 22,
        ),

        const SizedBox(height: 18),

        Row(
          children: [
            Expanded(
              child: _skeleton(
                height: 125,
                radius: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _skeleton(
                height: 125,
                radius: 18,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _skeleton(
                height: 125,
                radius: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _skeleton(
                height: 125,
                radius: 18,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _skeleton({
    required double height,
    required double radius,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: const Color(0xFFE5E9F0),
        ),
      ),
      child: const Center(
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: primary,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // VIEW ALL TESTS
  // ============================================================

  void _showAllTests() {
    final tests = [...history];

    tests.sort((a, b) {
      final aDate = a.submittedAt ?? a.startedAt;
      final bDate = b.submittedAt ?? b.startedAt;

      if (aDate == null && bDate == null) {
        return 0;
      }

      if (aDate == null) return 1;
      if (bDate == null) return -1;

      return bDate.compareTo(aDate);
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.78,
          minChildSize: 0.45,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: background,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(26),
                ),
              ),
              child: Column(
                children: [
                  // Handle
                  const SizedBox(height: 10),

                  Container(
                    height: 4,
                    width: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD6DBE5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      18,
                      0,
                      18,
                      12,
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 42,
                          width: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F0FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.history_rounded,
                            color: primary,
                            size: 21,
                          ),
                        ),

                        const SizedBox(width: 11),

                        const Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'All Tests',
                                style: TextStyle(
                                  color: textDark,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Your complete test history',
                                style: TextStyle(
                                  color: textMuted,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F0FF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${tests.length}',
                            style: const TextStyle(
                              color: primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(
                    height: 1,
                    color: Color(0xFFE5E9F0),
                  ),

                  // List
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        16,
                        16,
                        25,
                      ),
                      itemCount: tests.length,
                      itemBuilder: (context, index) {
                        return RecentTestCard(
                          test: tests[index],
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
}