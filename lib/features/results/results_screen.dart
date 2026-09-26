
import 'package:flutter/material.dart';

import '../../models/student_response.dart';
import '../../services/api_service.dart';

class ResultsScreen extends StatefulWidget {
  final StudentResponse student;

  const ResultsScreen({
    super.key,
    required this.student,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  bool isLoading = true;
  String? errorMessage;

  List<Map<String, dynamic>> results = [];

  String examName = "Exam Results";

  double totalMarks = 0;
  double totalMaxMarks = 0;
  double percentage = 0;

  String overallGrade = "-";

  int? classRank;
  int? sectionRank;

  String? remarks;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  // ============================================================
  // LOAD RESULTS
  // ============================================================

  Future<void> _loadResults() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // ----------------------------------------------------------
      // 1. Get student's published results
      // ----------------------------------------------------------

      final resultResponse =
          await ApiService.getStudentExamResults(
        widget.student.id,
      );

      debugPrint("========== RESULTS API ==========");
      debugPrint("STATUS: ${resultResponse.statusCode}");
      debugPrint("BODY: ${resultResponse.body}");
      debugPrint("=================================");

      if (resultResponse.statusCode != 200) {
        setState(() {
          errorMessage =
              "Unable to load exam results. "
              "(${resultResponse.statusCode})";
          isLoading = false;
        });
        return;
      }

      final resultData =
          ApiService.decodeResponse(resultResponse);

      if (resultData is! List) {
        setState(() {
          results = [];
          isLoading = false;
        });
        return;
      }

      // ----------------------------------------------------------
      // 2. Get exam schedules using student's section
      // ----------------------------------------------------------

      Map<int, Map<String, dynamic>> scheduleMap = {};

      if (widget.student.sectionId != null) {
        final scheduleResponse =
            await ApiService.getExamSchedules(
          sectionId: widget.student.sectionId,
        );

        debugPrint("========== SCHEDULE API ==========");
        debugPrint(
          "STATUS: ${scheduleResponse.statusCode}",
        );
        debugPrint(
          "BODY: ${scheduleResponse.body}",
        );
        debugPrint("==================================");

        if (scheduleResponse.statusCode == 200) {
          final scheduleData =
              ApiService.decodeResponse(scheduleResponse);

          if (scheduleData is List) {
            for (final item in scheduleData) {
              if (item is! Map) continue;

              final schedule =
                  Map<String, dynamic>.from(item);

              final id = _toInt(schedule['id']);

              if (id != null) {
                scheduleMap[id] = schedule;
              }
            }
          }
        }
      }

      // ----------------------------------------------------------
      // 3. Combine result + schedule
      // ----------------------------------------------------------

      final List<Map<String, dynamic>> loadedResults = [];

      for (final item in resultData) {
        if (item is! Map) continue;

        final result =
            Map<String, dynamic>.from(item);

        final scheduleId =
            _toInt(result['examScheduleId']);

        final schedule =
            scheduleId != null
                ? scheduleMap[scheduleId]
                : null;

        final marks =
            _toDouble(result['marksObtained']);

        final maxMarks =
            _toDouble(result['maxMarks']);

        final resultPercentage =
            _toDouble(result['percentage']);

        loadedResults.add({
          'id': result['id'],
          'examScheduleId': scheduleId,

          // From schedule
          'subjectName':
              schedule?['subjectName'] ??
              'Subject',

          'subjectCode':
              schedule?['subjectCode'],

          'examinationName':
              schedule?['examinationName'] ??
              'Examination',

          'examDate':
              schedule?['examDate'],

          // From result
          'marksObtained': marks,
          'maxMarks': maxMarks,
          'percentage': resultPercentage,

          'grade':
              result['grade']?.toString() ?? '-',

          'classRank':
              _toInt(result['classRank']),

          'sectionRank':
              _toInt(result['sectionRank']),

          'remarks':
              result['remarks']?.toString(),

          'status':
              result['status']?.toString(),

          'isPublished':
              result['isPublished'] == true,
        });
      }

      // ----------------------------------------------------------
      // 4. Calculate summary
      // ----------------------------------------------------------

      double calculatedTotal = 0;
      double calculatedMax = 0;

      for (final result in loadedResults) {
        calculatedTotal +=
            (result['marksObtained'] as double?) ?? 0;

        calculatedMax +=
            (result['maxMarks'] as double?) ?? 0;
      }

      double calculatedPercentage = 0;

      if (calculatedMax > 0) {
        calculatedPercentage =
            (calculatedTotal / calculatedMax) * 100;
      }

      // ----------------------------------------------------------
      // 5. Get overall information
      // ----------------------------------------------------------

      String calculatedExamName = "Exam Results";

      if (loadedResults.isNotEmpty) {
        calculatedExamName =
            loadedResults.first['examinationName']
                    ?.toString() ??
                "Exam Results";
      }

      String calculatedGrade = "-";

      if (loadedResults.isNotEmpty) {
        calculatedGrade =
            _calculateOverallGrade(
          calculatedPercentage,
        );
      }

      int? calculatedClassRank;
      int? calculatedSectionRank;
      String? calculatedRemarks;

      if (loadedResults.isNotEmpty) {
        calculatedClassRank =
            loadedResults.first['classRank'];

        calculatedSectionRank =
            loadedResults.first['sectionRank'];

        // First non-empty remark
        for (final result in loadedResults) {
          final r = result['remarks']?.toString();

          if (r != null && r.trim().isNotEmpty) {
            calculatedRemarks = r;
            break;
          }
        }
      }

      if (!mounted) return;

      setState(() {
        results = loadedResults;

        totalMarks = calculatedTotal;
        totalMaxMarks = calculatedMax;
        percentage = calculatedPercentage;

        examName = calculatedExamName;
        overallGrade = calculatedGrade;

        classRank = calculatedClassRank;
        sectionRank = calculatedSectionRank;

        remarks = calculatedRemarks;

        isLoading = false;
      });
    } catch (e) {
      debugPrint("RESULTS API ERROR: $e");

      if (!mounted) return;

      setState(() {
        errorMessage = "Failed to load exam results.";
        isLoading = false;
      });
    }
  }

  // ============================================================
  // HELPERS
  // ============================================================

  int? _toInt(dynamic value) {
    if (value == null) return null;

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value.toString());
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value.toString(),
        ) ??
        0;
  }

  String _calculateOverallGrade(
    double percentage,
  ) {
    if (percentage >= 90) return "A+";
    if (percentage >= 80) return "A";
    if (percentage >= 70) return "B+";
    if (percentage >= 60) return "B";
    if (percentage >= 50) return "C";
    if (percentage >= 40) return "D";

    return "F";
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(1);
  }

  Color _subjectColor(int index) {
    const colors = [
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];

    return colors[index % colors.length];
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F8FC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Exam Results",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _loadResults,
            icon: const Icon(
              Icons.refresh,
              color: Colors.blue,
            ),
          ),
        ],
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : errorMessage != null
              ? _errorView()
              : RefreshIndicator(
                  onRefresh: _loadResults,
                  child: _buildContent(),
                ),
    );
  }

  // ============================================================
  // CONTENT
  // ============================================================

  Widget _buildContent() {
    if (results.isEmpty) {
      return _emptyView();
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        _studentCard(),

        const SizedBox(height: 15),

        _summaryCard(),

        const SizedBox(height: 25),

        const Text(
          "Subject Wise Marks",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),

        const SizedBox(height: 15),

        ...results.asMap().entries.map(
          (entry) {
            return _resultCard(
              entry.value,
              entry.key,
            );
          },
        ),

        if (remarks != null &&
            remarks!.trim().isNotEmpty) ...[
          const SizedBox(height: 10),
          _remarksCard(),
        ],

        const SizedBox(height: 25),

        SizedBox(
          height: 55,
          child: ElevatedButton.icon(
            onPressed: () {
              // PDF report can be integrated later.
            },
            icon: const Icon(Icons.download),
            label: const Text(
              "Download Report Card",
            ),
          ),
        ),

        const SizedBox(height: 30),
      ],
    );
  }

  // ============================================================
  // STUDENT CARD
  // ============================================================

  Widget _studentCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xff1565C0),
            Color(0xff42A5F5),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Text(
              widget.student.name.isNotEmpty
                  ? widget.student.name[0].toUpperCase()
                  : "?",
              style: const TextStyle(
                color: Color(0xff1565C0),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  widget.student.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  widget.student.className ??
                      widget.student.sectionName ??
                      "Class information unavailable",
                  style: const TextStyle(
                    color: Colors.white70,
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
  // SUMMARY CARD
  // ============================================================

  Widget _summaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xff1565C0),
            Color(0xff42A5F5),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 38,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.workspace_premium,
              color: Colors.amber,
              size: 40,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            examName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceAround,
            children: [
              _ResultBox(
                "${percentage.toStringAsFixed(1)}%",
                "Percentage",
              ),

              _ResultBox(
                overallGrade,
                "Grade",
              ),

              _ResultBox(
                classRank?.toString() ?? "-",
                "Class Rank",
              ),
            ],
          ),

          if (sectionRank != null) ...[
            const SizedBox(height: 16),
            Text(
              "Section Rank: $sectionRank",
              style: const TextStyle(
                color: Colors.white70,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // RESULT CARD
  // ============================================================

  Widget _resultCard(
    Map<String, dynamic> result,
    int index,
  ) {
    final color = _subjectColor(index);

    final marks =
        (result['marksObtained'] as double?) ?? 0;

    final maxMarks =
        (result['maxMarks'] as double?) ?? 0;

    final resultPercentage =
        (result['percentage'] as double?) ??
            (maxMarks > 0
                ? (marks / maxMarks) * 100
                : 0);

    final grade =
        result['grade']?.toString() ?? "-";

    final subject =
        result['subjectName']?.toString() ??
            "Subject";

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                      color.withOpacity(.15),
                  child: Icon(
                    Icons.book,
                    color: color,
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: Text(
                    subject,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: Text(
                    grade,
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            LinearProgressIndicator(
              value: (resultPercentage / 100)
                  .clamp(0.0, 1.0),
              minHeight: 8,
              borderRadius:
                  BorderRadius.circular(10),
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${_formatNumber(marks)}/${_formatNumber(maxMarks)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  "${resultPercentage.toStringAsFixed(0)}%",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // REMARKS
  // ============================================================

  Widget _remarksCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              "Teacher Remarks",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              remarks!,
              style: const TextStyle(
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _emptyView() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height:
              MediaQuery.of(context).size.height * .65,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 70,
                    color: Colors.grey.shade400,
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    "No published results available",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Results will appear here once "
                    "the school publishes them.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _errorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red.shade300,
            ),

            const SizedBox(height: 15),

            Text(
              errorMessage ??
                  "Unable to load results.",
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 18),

            ElevatedButton.icon(
              onPressed: _loadResults,
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// RESULT BOX
// ================================================================

class _ResultBox extends StatelessWidget {
  final String value;
  final String title;

  const _ResultBox(
    this.value,
    this.title,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}

