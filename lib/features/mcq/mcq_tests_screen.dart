import 'package:flutter/material.dart';

import '../../models/mcq_test.dart';
import '../../models/student_response.dart';
import '../../services/api_service.dart';
import '../../services/mcq_service.dart';
import 'daily_test_screen.dart';

class McqTestsScreen extends StatefulWidget {
  final StudentResponse student;

  const McqTestsScreen({super.key, required this.student});

  @override
  State<McqTestsScreen> createState() => _McqTestsScreenState();
}

class _McqTestsScreenState extends State<McqTestsScreen> {
  static const Color primary = Color(0xff3155D9);
  static const Color primaryDark = Color(0xff2343B8);
  static const Color background = Color(0xffF6F8FC);
  static const Color textDark = Color(0xff172033);
  static const Color textMuted = Color(0xff697386);
  static const Color border = Color(0xffE5E9F0);

  List<McqTest> tests = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    debugPrint(
      '📝 McqTestsScreen: Loading tests for '
      '${widget.student.name} '
      '(ID: ${widget.student.id})',
    );

    _loadTests();
  }

  // ============================================================
  // LOAD TESTS
  // ============================================================

  Future<void> _loadTests() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // ==========================================================
      // LOAD AVAILABLE TESTS + STUDENT HISTORY
      // ==========================================================

      final responses = await Future.wait([
        McqService.getMcqTests(),
        McqService.getMcqHistory(widget.student.id),
      ]);

      final testsResponse = responses[0];
      final historyResponse = responses[1];

      debugPrint('📝 MCQ tests API status: ${testsResponse.statusCode}');

      debugPrint('📚 MCQ history API status: ${historyResponse.statusCode}');

      if (!mounted) return;

      // ==========================================================
      // AVAILABLE TESTS
      // ==========================================================

      if (testsResponse.statusCode != 200) {
        setState(() {
          tests = [];
          isLoading = false;
          errorMessage = 'Unable to load MCQ tests.';
        });
        return;
      }

      final testData = ApiService.decodeResponse(testsResponse);

      if (testData is! List) {
        setState(() {
          tests = [];
          isLoading = false;
          errorMessage = 'Invalid test data received.';
        });
        return;
      }

      final loadedTests = testData
          .whereType<Map<String, dynamic>>()
          .map((item) => McqTest.fromJson(item))
          .toList();

      // ==========================================================
      // GET SUBMITTED TEST IDS FROM HISTORY
      // ==========================================================

      final submittedTestIds = <int>{};

      if (historyResponse.statusCode == 200) {
        final historyData = ApiService.decodeResponse(historyResponse);

        if (historyData is List) {
          for (final item in historyData) {
            if (item is! Map<String, dynamic>) {
              continue;
            }

            final testIdValue = item['testId'];

            final status = item['status']?.toString().trim().toUpperCase();

            final submittedAt = item['submittedAt'];

            if (testIdValue == null) {
              continue;
            }

            final testId = int.tryParse(testIdValue.toString());

            if (testId == null) {
              continue;
            }

            // ======================================================
            // ONLY HIDE COMPLETED TESTS
            // ======================================================

            final isSubmitted =
                status == 'SUBMITTED' ||
                status == 'AUTO_SUBMITTED' ||
                submittedAt != null;

            if (isSubmitted) {
              submittedTestIds.add(testId);
            }
          }
        }
      } else {
        debugPrint(
          '⚠️ Could not load MCQ history. '
          'Status: ${historyResponse.statusCode}',
        );
      }

      debugPrint('🚫 Submitted test IDs: $submittedTestIds');

      // ==========================================================
      // FILTER AVAILABLE TESTS
      // ==========================================================

      final visibleTests = loadedTests
          // 12 PM onwards
          .where((test) => _isPMTest(test.startTime))
          // Remove already submitted tests
          .where((test) => !submittedTestIds.contains(test.id))
          .toList();

      debugPrint(
        '✅ Total MCQ tests loaded: '
        '${loadedTests.length}',
      );

      debugPrint(
        '🚫 Already submitted tests: '
        '${submittedTestIds.length}',
      );

      debugPrint(
        '👁️ Final visible tests: '
        '${visibleTests.length}',
      );

      if (!mounted) return;

      setState(() {
        tests = visibleTests;
        isLoading = false;
      });
    } catch (e, stackTrace) {
      debugPrint('❌ MCQ tests/history loading exception: $e');

      debugPrint('📍 StackTrace: $stackTrace');

      if (!mounted) return;

      setState(() {
        tests = [];
        isLoading = false;
        errorMessage = 'Something went wrong while loading tests.';
      });
    }
  }

  bool _isPMTest(String value) {
    final raw = value.trim();

    if (raw.isEmpty) {
      return false;
    }

    final match = RegExp(
      r'^(\d{1,2}):(\d{2})(?::(\d{2}))?\s*([AaPp][Mm])?$',
    ).firstMatch(raw);

    if (match == null) {
      return false;
    }

    int hour = int.tryParse(match.group(1) ?? '') ?? -1;
    final minute = int.tryParse(match.group(2) ?? '') ?? -1;
    final period = match.group(4)?.toUpperCase();

    if (hour < 0 || minute < 0 || minute > 59) {
      return false;
    }

    // 12-hour format: 12:00 AM / 12:00 PM
    if (period != null) {
      if (hour < 1 || hour > 12) {
        return false;
      }

      // AM
      if (period == 'AM') {
        if (hour == 12) {
          hour = 0;
        }
      }
      // PM
      else {
        if (hour != 12) {
          hour += 12;
        }
      }
    }
    // 24-hour format
    else {
      if (hour > 23) {
        return false;
      }
    }

    // Only 12:00 PM onwards is allowed.
    return hour >= 12;
  }
  // ============================================================
  // OPEN TEST
  // ============================================================

  Future<void> _openTest(McqTest test) async {
    debugPrint(
      '📝 Opening MCQ test: '
      'ID=${test.id}, '
      'Subject=${test.subject}',
    );

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DailyTestScreen(test: test, student: widget.student),
      ),
    );

    if (mounted) {
      _loadTests();
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  // ============================================================
  // APP BAR
  // ============================================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: textDark,
      elevation: 0,
      centerTitle: false,
      automaticallyImplyLeading: false,
      toolbarHeight: 68,
      titleSpacing: 18,
      title: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: const Color(0xffF1F4FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                size: 20,
                color: textDark,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [primary, primaryDark]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.quiz_rounded,
              color: Colors.white,
              size: 21,
            ),
          ),

          const SizedBox(width: 11),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MCQ Tests',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: textDark,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Learn • Practice • Improve',
                  style: TextStyle(
                    fontSize: 10,
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
        Container(
          margin: const EdgeInsets.only(right: 14),
          child: IconButton(
            onPressed: isLoading ? null : _loadTests,
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded, color: primary),
          ),
        ),
      ],
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

    if (tests.isEmpty) {
      return _buildEmpty();
    }

    return RefreshIndicator(
      color: primary,
      backgroundColor: Colors.white,
      onRefresh: _loadTests,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
        children: [
          _buildStudentHeader(),

          const SizedBox(height: 18),

          _buildSectionHeader(),

          const SizedBox(height: 13),

          ...tests.map((test) => _buildTestCard(test)),
        ],
      ),
    );
  }

  // ============================================================
  // STUDENT HEADER
  // ============================================================

  Widget _buildStudentHeader() {
    final classText = widget.student.className;

    final sectionText = widget.student.sectionName;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primary, primaryDark],
        ),
        borderRadius: BorderRadius.circular(23),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -28,
            top: -35,
            child: Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.07),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Row(
            children: [
              Container(
                height: 58,
                width: 58,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(.2)),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ready for your test?',
                      style: TextStyle(
                        color: Colors.white.withOpacity(.78),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      widget.student.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 5),

                    if (classText != null || sectionText != null)
                      Text(
                        '${classText ?? ''}'
                        '${sectionText != null ? ' • $sectionText' : ''}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(.78),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
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
  // SECTION HEADER
  // ============================================================

  Widget _buildSectionHeader() {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Available Tests',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: textDark,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Choose a test and start learning',
                style: TextStyle(fontSize: 11, color: textMuted),
              ),
            ],
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xffEEF2FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(Icons.assignment_rounded, size: 14, color: primary),
              const SizedBox(width: 5),
              Text(
                '${tests.length}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TEST CARD
  // ============================================================

  Widget _buildTestCard(McqTest test) {
    final subject = test.subject.trim().isEmpty
        ? 'MCQ Test'
        : test.subject.trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.035),
            blurRadius: 17,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xffEEF2FF), Color(0xffE4EBFF)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.quiz_rounded, color: primary, size: 24),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: textDark,
                      ),
                    ),

                    const SizedBox(height: 5),

                    if (test.className != null || test.sectionName != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.school_rounded,
                            size: 13,
                            color: textMuted,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              '${test.className ?? ''}'
                              '${test.sectionName != null ? ' • ${test.sectionName}' : ''}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                color: textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xffECFDF3),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 6, color: Color(0xff16A34A)),
                    SizedBox(width: 5),
                    Text(
                      'Available',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Color(0xff15803D),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: const Color(0xffF8F9FC),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _infoItem(
                    Icons.help_outline_rounded,
                    '${test.numberOfQuestions} Questions',
                  ),
                ),

                Container(height: 24, width: 1, color: border),

                Expanded(
                  child: _infoItem(
                    Icons.timer_outlined,
                    '${test.duration} min',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _scheduleChip(
                  icon: Icons.calendar_today_rounded,
                  text: _formatDate(test.date),
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: _scheduleChip(
                  icon: Icons.access_time_rounded,
                  text: _formatTime(test.startTime),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 49,
            child: ElevatedButton(
              onPressed: () {
                _openTest(test);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow_rounded, size: 20),
                  SizedBox(width: 7),
                  Text(
                    'Start Test',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
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
  // INFO ITEM
  // ============================================================

  Widget _infoItem(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: primary),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: textDark,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SCHEDULE CHIP
  // ============================================================

  Widget _scheduleChip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: textMuted),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LOADING
  // ============================================================

  Widget _buildLoading() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(18),
      children: [
        _skeleton(height: 120, radius: 23),

        const SizedBox(height: 18),

        Row(
          children: [
            _skeleton(height: 20, width: 150, radius: 6),
            const Spacer(),
            _skeleton(height: 28, width: 42, radius: 9),
          ],
        ),

        const SizedBox(height: 14),

        ...List.generate(
          3,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _testSkeleton(),
          ),
        ),
      ],
    );
  }

  Widget _testSkeleton() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _skeleton(height: 48, width: 48, radius: 14),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _skeleton(height: 17, width: 130, radius: 5),
                    const SizedBox(height: 8),
                    _skeleton(height: 11, width: 100, radius: 4),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _skeleton(height: 45, width: double.infinity, radius: 13),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _skeleton(height: 35, radius: 10)),
              const SizedBox(width: 8),
              Expanded(child: _skeleton(height: 35, radius: 10)),
            ],
          ),
          const SizedBox(height: 15),
          _skeleton(height: 49, width: double.infinity, radius: 14),
        ],
      ),
    );
  }

  Widget _skeleton({
    double? width,
    required double height,
    required double radius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xffEDEFF3),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmpty() {
    return RefreshIndicator(
      color: primary,
      onRefresh: _loadTests,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * .25),

          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  Container(
                    height: 90,
                    width: 90,
                    decoration: BoxDecoration(
                      color: const Color(0xffEEF2FF),
                      borderRadius: BorderRadius.circular(27),
                    ),
                    child: const Icon(
                      Icons.assignment_outlined,
                      size: 42,
                      color: primary,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'No Tests Available',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: textDark,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'There are no MCQ tests available for you right now. Please check again later.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: textMuted,
                    ),
                  ),

                  const SizedBox(height: 20),

                  OutlinedButton.icon(
                    onPressed: _loadTests,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Refresh Tests'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primary,
                      side: const BorderSide(color: primary),
                      minimumSize: const Size(150, 46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
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
  // ERROR
  // ============================================================

  Widget _buildError() {
    return RefreshIndicator(
      color: primary,
      onRefresh: _loadTests,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * .25),

          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  Container(
                    height: 82,
                    width: 82,
                    decoration: BoxDecoration(
                      color: const Color(0xffFFF1F2),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.cloud_off_rounded,
                      size: 39,
                      color: Color(0xffDC2626),
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'Unable to Load Tests',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: textDark,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    errorMessage ?? 'Something went wrong while loading tests.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: textMuted,
                    ),
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton.icon(
                    onPressed: _loadTests,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size(145, 46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
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
  // DATE FORMAT
  // ============================================================

  String _formatDate(String date) {
    if (date.isEmpty) {
      return 'Date unavailable';
    }

    try {
      final parsed = DateTime.parse(date);

      return '${parsed.day.toString().padLeft(2, '0')}/'
          '${parsed.month.toString().padLeft(2, '0')}/'
          '${parsed.year}';
    } catch (_) {
      return date;
    }
  }

  // ============================================================
  // TIME FORMAT
  // ============================================================

  String _formatTime(String time) {
    if (time.isEmpty) {
      return 'Time unavailable';
    }

    try {
      final parts = time.split(':');

      if (parts.length < 2) {
        return time;
      }

      int hour = int.parse(parts[0]);

      final minute = parts[1];

      final period = hour >= 12 ? 'PM' : 'AM';

      hour = hour % 12;

      if (hour == 0) {
        hour = 12;
      }

      return '$hour:$minute $period';
    } catch (_) {
      return time;
    }
  }
}
