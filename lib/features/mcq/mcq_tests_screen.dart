import 'package:flutter/material.dart';

import '../../models/mcq_test.dart';
import '../../models/student_response.dart';
import '../../services/api_service.dart';
import 'daily_test_screen.dart';

class McqTestsScreen extends StatefulWidget {
  final StudentResponse student;

  const McqTestsScreen({
    super.key,
    required this.student,
  });

  @override
  State<McqTestsScreen> createState() => _McqTestsScreenState();
}

class _McqTestsScreenState extends State<McqTestsScreen> {
  List<McqTest> tests = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    print(
      '📝 McqTestsScreen: Loading tests for '
      '${widget.student.name} '
      '(ID: ${widget.student.id})',
    );

    _loadTests();
  }

  // ============================================================
  // LOAD AVAILABLE MCQ TESTS
  // ============================================================

  Future<void> _loadTests() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await ApiService.getMcqTests();

      print(
        '📝 MCQ tests API status: ${response.statusCode}',
      );

      print(
        '📝 MCQ tests API response: ${response.body}',
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = ApiService.decodeResponse(response);

        if (data is List) {
          final loadedTests = data
              .whereType<Map<String, dynamic>>()
              .map(
                (item) => McqTest.fromJson(item),
              )
              .toList();

          print(
            '✅ MCQ tests loaded: ${loadedTests.length}',
          );

          setState(() {
            tests = loadedTests;
            isLoading = false;
          });
        } else {
          print(
            '⚠️ MCQ API response is not a List',
          );

          setState(() {
            tests = [];
            isLoading = false;
            errorMessage = 'Invalid test data received.';
          });
        }
      } else {
        print(
          '❌ MCQ tests API failed: '
          '${response.statusCode}',
        );

        setState(() {
          tests = [];
          isLoading = false;
          errorMessage =
              'Unable to load MCQ tests.';
        });
      }
    } catch (e, stackTrace) {
      print(
        '❌ MCQ tests loading exception: $e',
      );

      print(
        '📍 StackTrace: $stackTrace',
      );

      if (!mounted) return;

      setState(() {
        tests = [];
        isLoading = false;
        errorMessage =
            'Something went wrong while loading tests.';
      });
    }
  }

  // ============================================================
  // OPEN TEST
  // ============================================================

  Future<void> _openTest(McqTest test) async {
    print(
      '📝 Opening MCQ test: '
      'ID=${test.id}, '
      'Subject=${test.subject}',
    );

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DailyTestScreen(
          test: test,
          student: widget.student,
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F8FC),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black87,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          'MCQ Tests',
          style: TextStyle(
            color: Color(0xFF1565C0),
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,

        actions: [
          IconButton(
            onPressed: isLoading ? null : _loadTests,
            icon: const Icon(
              Icons.refresh,
              color: Colors.blue,
            ),
          ),
        ],
      ),

      body: _buildBody(),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return _buildError();
    }

    if (tests.isEmpty) {
      return _buildEmpty();
    }

    return RefreshIndicator(
      onRefresh: _loadTests,

      child: ListView(
        padding: const EdgeInsets.all(16),

        children: [
          _buildStudentHeader(),

          const SizedBox(height: 20),

          const Text(
            'Available Tests',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          ...tests.map(
            (test) => _buildTestCard(test),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STUDENT HEADER
  // ============================================================

  Widget _buildStudentHeader() {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            child: Icon(
              Icons.person,
              size: 30,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                const Text(
                  'Student',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  widget.student.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                if (widget.student.className != null)
                  Text(
                    '${widget.student.className}'
                    '${widget.student.sectionName != null ? ' - ${widget.student.sectionName}' : ''}',
                    style: const TextStyle(
                      color: Colors.grey,
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
  // TEST CARD
  // ============================================================

  Widget _buildTestCard(McqTest test) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(11),

                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),

                child: const Icon(
                  Icons.quiz,
                  color: Colors.blue,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      test.subject.isEmpty
                          ? 'MCQ Test'
                          : test.subject,

                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    if (test.className != null ||
                        test.sectionName != null)
                      Text(
                        '${test.className ?? ''}'
                        '${test.sectionName != null ? ' • ${test.sectionName}' : ''}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              _infoItem(
                Icons.help_outline,
                '${test.numberOfQuestions} Questions',
              ),

              const SizedBox(width: 18),

              _infoItem(
                Icons.timer_outlined,
                '${test.duration} min',
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              _infoItem(
                Icons.calendar_today_outlined,
                _formatDate(test.date),
              ),

              const SizedBox(width: 18),

              _infoItem(
                Icons.access_time,
                _formatTime(test.startTime),
              ),
            ],
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,

            child: ElevatedButton.icon(
              onPressed: () {
                _openTest(test);
              },

              icon: const Icon(Icons.play_arrow),

              label: const Text(
                'Start Test',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 13,
                ),

                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
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

  Widget _infoItem(
    IconData icon,
    String text,
  ) {
    return Expanded(
      child: Row(
        children: [
          Icon(
            icon,
            size: 17,
            color: Colors.grey.shade600,
          ),

          const SizedBox(width: 6),

          Expanded(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,

              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Icon(
              Icons.quiz_outlined,
              size: 70,
              color: Colors.grey.shade400,
            ),

            const SizedBox(height: 16),

            const Text(
              'No MCQ Tests Available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'There are no tests available for this student right now.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 20),

            OutlinedButton.icon(
              onPressed: _loadTests,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Icon(
              Icons.error_outline,
              size: 65,
              color: Colors.red.shade300,
            ),

            const SizedBox(height: 16),

            Text(
              errorMessage!,
              textAlign: TextAlign.center,

              style: const TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _loadTests,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDate(String date) {
    if (date.isEmpty) {
      return 'Date not available';
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
      return 'Time not available';
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