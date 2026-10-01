import 'package:flutter/material.dart';

import '../../models/student_response.dart';
import '../../services/api_service.dart';
import '../../services/exam_service.dart';

class ResultsScreen extends StatefulWidget {
  final StudentResponse student;

  const ResultsScreen({super.key, required this.student});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  // ============================================================
  // THEME
  // ============================================================

  static const Color primary = Color(0xFF3155D9);
  static const Color primaryDark = Color(0xFF2343B8);
  static const Color background = Color(0xFFF6F8FC);
  static const Color textDark = Color(0xFF172033);
  static const Color textMuted = Color(0xFF697386);
  static const Color border = Color(0xFFE5E9F0);

  // ============================================================
  // STATE
  // ============================================================

  bool isLoading = true;
  String? errorMessage;

  List<Map<String, dynamic>> allResults = [];
  List<Map<String, dynamic>> results = [];

  List<String> availableExams = [];
  String? selectedExam;

  List<Map<String, dynamic>> gradeRules = [];

  double totalMarks = 0;
  double totalMaxMarks = 0;
  double percentage = 0;

  String overallGrade = '-';

  int? classRank;
  int? sectionRank;

  String? remarks;

  // ============================================================
  // INIT
  // ============================================================

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
      // 1. STUDENT RESULTS
      // ----------------------------------------------------------

      final resultResponse = await ExamService.getStudentExamResults(
        widget.student.id,
      );

      debugPrint('========== RESULTS API ==========');
      debugPrint('STATUS: ${resultResponse.statusCode}');
      debugPrint('BODY: ${resultResponse.body}');
      debugPrint('=================================');

      if (resultResponse.statusCode != 200) {
        if (!mounted) return;

        setState(() {
          errorMessage =
              'Unable to load exam results. '
              '(${resultResponse.statusCode})';
          isLoading = false;
        });

        return;
      }

      final resultData = ApiService.decodeResponse(resultResponse);

      if (resultData is! List) {
        if (!mounted) return;

        setState(() {
          allResults = [];
          results = [];
          availableExams = [];
          isLoading = false;
        });

        return;
      }

      // ----------------------------------------------------------
      // 2. EXAM SCHEDULES
      // ----------------------------------------------------------

      Map<int, Map<String, dynamic>> scheduleMap = {};

      if (widget.student.sectionId != null) {
        final scheduleResponse = await ExamService.getExamSchedules(
          sectionId: widget.student.sectionId,
        );

        debugPrint('========== SCHEDULE API ==========');
        debugPrint('STATUS: ${scheduleResponse.statusCode}');
        debugPrint('BODY: ${scheduleResponse.body}');
        debugPrint('==================================');

        if (scheduleResponse.statusCode == 200) {
          final scheduleData = ApiService.decodeResponse(scheduleResponse);

          if (scheduleData is List) {
            for (final item in scheduleData) {
              if (item is! Map) continue;

              final schedule = Map<String, dynamic>.from(item);

              final id = _toInt(schedule['id']);

              if (id != null) {
                scheduleMap[id] = schedule;
              }
            }
          }
        }
      }

      // ----------------------------------------------------------
      // 3. GRADE RULES
      // ----------------------------------------------------------

      try {
        final gradeResponse = await ExamService.getGradeRules();

        if (gradeResponse.statusCode == 200) {
          final gradeData = ApiService.decodeResponse(gradeResponse);

          if (gradeData is List) {
            gradeRules = gradeData
                .whereType<Map>()
                .map((item) => Map<String, dynamic>.from(item))
                .toList();
          }
        }
      } catch (e) {
        debugPrint('GRADE RULES ERROR: $e');
      }

      // ----------------------------------------------------------
      // 4. COMBINE RESULT + SCHEDULE
      // ----------------------------------------------------------

      final List<Map<String, dynamic>> loadedResults = [];

      for (final item in resultData) {
        if (item is! Map) continue;

        final result = Map<String, dynamic>.from(item);

        final scheduleId = _toInt(result['examScheduleId']);

        final schedule = scheduleId != null ? scheduleMap[scheduleId] : null;

        final marks = _toDouble(result['marksObtained']);

        final maxMarks = _toDouble(result['maxMarks']);

        final resultPercentage = _toDouble(result['percentage']);

        final examinationName =
            schedule?['examinationName'] ??
            result['examinationName'] ??
            'Examination';

        loadedResults.add({
          'id': result['id'],
          'examScheduleId': scheduleId,

          'subjectName':
              schedule?['subjectName'] ?? result['subjectName'] ?? 'Subject',

          'subjectCode': schedule?['subjectCode'] ?? result['subjectCode'],

          'examinationName': examinationName.toString(),

          'examDate': schedule?['examDate'] ?? result['examDate'],

          'marksObtained': marks,
          'maxMarks': maxMarks,
          'percentage': resultPercentage,

          'grade': result['grade']?.toString() ?? '-',

          'classRank': _toInt(result['classRank']),

          'sectionRank': _toInt(result['sectionRank']),

          'remarks': result['remarks']?.toString(),

          'status': result['status']?.toString(),

          'isPublished': result['isPublished'] == true,
        });
      }

      // ----------------------------------------------------------
      // 5. FIND AVAILABLE EXAMS
      // ----------------------------------------------------------

      final examSet = <String>{};

      for (final result in loadedResults) {
        final name = result['examinationName']?.toString().trim();

        if (name != null && name.isNotEmpty) {
          examSet.add(name);
        }
      }

      final exams = examSet.toList();

      if (!mounted) return;

      setState(() {
        allResults = loadedResults;
        availableExams = exams;

        selectedExam = exams.isNotEmpty ? exams.first : null;

        isLoading = false;
      });

      // ----------------------------------------------------------
      // 6. APPLY SELECTED EXAM
      // ----------------------------------------------------------

      _applySelectedExam();
    } catch (e) {
      debugPrint('RESULTS API ERROR: $e');

      if (!mounted) return;

      setState(() {
        errorMessage = 'Failed to load exam results.';
        isLoading = false;
      });
    }
  }

  // ============================================================
  // APPLY EXAM
  // ============================================================

  void _applySelectedExam() {
    final exam = selectedExam;

    if (exam == null) {
      setState(() {
        results = [];
        _resetSummary();
      });
      return;
    }

    final filtered = allResults.where((result) {
      return result['examinationName']?.toString().trim() == exam.trim();
    }).toList();

    double calculatedTotal = 0;
    double calculatedMax = 0;

    for (final result in filtered) {
      calculatedTotal += (result['marksObtained'] as double?) ?? 0;

      calculatedMax += (result['maxMarks'] as double?) ?? 0;
    }

    double calculatedPercentage = 0;

    if (calculatedMax > 0) {
      calculatedPercentage = (calculatedTotal / calculatedMax) * 100;
    }

    int? calculatedClassRank;
    int? calculatedSectionRank;
    String? calculatedRemarks;

    if (filtered.isNotEmpty) {
      calculatedClassRank = filtered.first['classRank'];

      calculatedSectionRank = filtered.first['sectionRank'];

      for (final result in filtered) {
        final remark = result['remarks']?.toString();

        if (remark != null && remark.trim().isNotEmpty) {
          calculatedRemarks = remark;
          break;
        }
      }
    }

    final grade = filtered.isNotEmpty
        ? _calculateOverallGrade(calculatedPercentage)
        : '-';

    setState(() {
      results = filtered;

      totalMarks = calculatedTotal;
      totalMaxMarks = calculatedMax;
      percentage = calculatedPercentage;

      overallGrade = grade;

      classRank = calculatedClassRank;
      sectionRank = calculatedSectionRank;

      remarks = calculatedRemarks;
    });
  }

  // ============================================================
  // SELECT EXAM
  // ============================================================

  void _selectExam(String exam) {
    setState(() {
      selectedExam = exam;
    });

    _applySelectedExam();
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

    return double.tryParse(value.toString()) ?? 0;
  }

  String _calculateOverallGrade(double value) {
    if (gradeRules.isNotEmpty) {
      for (final rule in gradeRules) {
        final minimum = _toDouble(rule['minimumPercentage']);

        final maximum = _toDouble(rule['maximumPercentage']);

        if (value >= minimum && value <= maximum) {
          return rule['grade']?.toString() ?? '-';
        }
      }
    }

    // Fallback if grade rules are not available.
    if (value >= 90) return 'A+';
    if (value >= 80) return 'A';
    if (value >= 70) return 'B+';
    if (value >= 60) return 'B';
    if (value >= 50) return 'C';
    if (value >= 40) return 'D';

    return 'F';
  }

  void _resetSummary() {
    totalMarks = 0;
    totalMaxMarks = 0;
    percentage = 0;
    overallGrade = '-';
    classRank = null;
    sectionRank = null;
    remarks = null;
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(1);
  }

  Color _scoreColor(double score) {
    if (score >= 80) {
      return const Color(0xFF16A34A);
    }

    if (score >= 60) {
      return const Color(0xFFF59E0B);
    }

    return const Color(0xFFDC2626);
  }

  Color _subjectColor(int index) {
    const colors = [
      Color(0xFF3155D9),
      Color(0xFF7C3AED),
      Color(0xFF0F766E),
      Color(0xFFEA580C),
      Color(0xFFDB2777),
      Color(0xFF2563EB),
    ];

    return colors[index % colors.length];
  }

  String _performanceText() {
    if (percentage >= 90) {
      return 'Excellent Performance';
    }

    if (percentage >= 75) {
      return 'Very Good Performance';
    }

    if (percentage >= 60) {
      return 'Good Performance';
    }

    return 'Keep Practicing';
  }

  String _formatExamDate() {
    if (results.isEmpty) return '';

    final value = results.first['examDate'];

    if (value == null) return '';

    final raw = value.toString();

    if (raw.isEmpty) return '';

    try {
      final date = DateTime.parse(raw).toLocal();

      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    } catch (_) {
      return raw;
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
      body: isLoading
          ? _loadingView()
          : errorMessage != null
          ? _errorView()
          : RefreshIndicator(
              color: primary,
              onRefresh: _loadResults,
              child: _buildContent(),
            ),
    );
  }

  // ============================================================
  // APP BAR
  // ============================================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      centerTitle: false,
      titleSpacing: 20,
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Exam Results',
            style: TextStyle(
              color: textDark,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 2),
          Text(
            'Track academic performance',
            style: TextStyle(
              color: textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 12, top: 9, bottom: 9),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F4FA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            tooltip: 'Refresh',
            onPressed: _loadResults,
            icon: const Icon(Icons.refresh_rounded, color: primary, size: 21),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CONTENT
  // ============================================================

  Widget _buildContent() {
    if (allResults.isEmpty) {
      return _emptyView();
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
      children: [
        _studentCard(),

        const SizedBox(height: 16),

        _examSelector(),

        const SizedBox(height: 16),

        if (results.isEmpty)
          _selectedExamEmpty()
        else ...[
          _summaryCard(),

          const SizedBox(height: 22),

          _sectionHeader(
            title: 'Subject Performance',
            subtitle: '${results.length} subjects',
          ),

          const SizedBox(height: 11),

          ...results.asMap().entries.map((entry) {
            return _resultCard(entry.value, entry.key);
          }),

          if (remarks != null && remarks!.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            _remarksCard(),
          ],

          const SizedBox(height: 20),

          _reportCardButton(),

          const SizedBox(height: 8),
        ],
      ],
    );
  }

  // ============================================================
  // STUDENT CARD
  // ============================================================

  Widget _studentCard() {
    final name = widget.student.name.trim().isEmpty
        ? 'Student'
        : widget.student.name.trim();

    final classText =
        widget.student.className ??
        widget.student.sectionName ??
        'Class information unavailable';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [primaryDark, primary, Color(0xFF5B7FF0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(23),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -55,
            child: Container(
              height: 135,
              width: 135,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.07),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 30,
            bottom: -65,
            child: Container(
              height: 105,
              width: 105,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Row(
            children: [
              Container(
                height: 62,
                width: 62,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.25),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    name[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.13),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'ACADEMIC RESULTS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.7,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(
                          Icons.school_rounded,
                          size: 14,
                          color: Colors.white.withOpacity(0.78),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            classText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.78),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
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
  // EXAM SELECTOR
  // ============================================================

  Widget _examSelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --------------------------------------------------------
          // HEADER
          // --------------------------------------------------------
          Row(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [primaryDark, primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withOpacity(0.18),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.assignment_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Examination',
                      style: TextStyle(
                        color: textDark,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Select an exam to view results',
                      style: TextStyle(
                        color: textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              if (availableExams.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F4FA),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.layers_rounded,
                        color: primary,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${availableExams.length}',
                        style: const TextStyle(
                          color: primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 15),

          // --------------------------------------------------------
          // PREMIUM EXAM SELECTOR
          // --------------------------------------------------------
          PopupMenuButton<String>(
            initialValue: selectedExam,
            onSelected: _selectExam,
            offset: const Offset(0, 8),
            constraints: const BoxConstraints(minWidth: 320, maxWidth: 500),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(17),
            ),
            elevation: 8,
            color: Colors.white,
            itemBuilder: (context) {
              return availableExams.map((exam) {
                final isSelected = exam == selectedExam;

                return PopupMenuItem<String>(
                  value: exam,
                  height: 64,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? primary.withOpacity(0.07)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 34,
                          width: 34,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? primary.withOpacity(0.12)
                                : const Color(0xFFF3F5F9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.event_note_rounded,
                            color: isSelected ? primary : textMuted,
                            size: 17,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Text(
                            exam,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isSelected ? primary : textDark,
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                            ),
                          ),
                        ),

                        if (isSelected)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: primary,
                            size: 19,
                          ),
                      ],
                    ),
                  ),
                );
              }).toList();
            },

            // ------------------------------------------------------
            // SELECTED EXAM BOX
            // ------------------------------------------------------
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFFF7F9FF), primary.withOpacity(0.035)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: primary.withOpacity(0.16),
                  width: 1.1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      color: primary,
                      size: 20,
                    ),
                  ),

                  const SizedBox(width: 11),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CURRENT EXAMINATION',
                          style: TextStyle(
                            color: textMuted,
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.7,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          selectedExam ?? 'Select Examination',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: textDark,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  Container(
                    height: 34,
                    width: 34,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: border),
                    ),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: primary,
                      size: 20,
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
  // SUMMARY
  // ============================================================

  Widget _summaryCard() {
    final scoreColor = _scoreColor(percentage);

    final examDate = _formatExamDate();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [primaryDark, primary, Color(0xFF5B7FF0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -45,
            top: -50,
            child: Container(
              height: 135,
              width: 135,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.07),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.13),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.workspace_premium_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedExam ?? 'Exam Results',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (examDate.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Exam Date • $examDate',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.70),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _scoreCircle(percentage),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _performanceText(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Overall percentage',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.68),
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: scoreColor.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Grade $overallGrade',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _summaryItem(
                        Icons.stars_rounded,
                        _formatNumber(totalMarks),
                        'Marks Obtained',
                      ),
                    ),
                    _verticalDivider(),
                    Expanded(
                      child: _summaryItem(
                        Icons.assignment_rounded,
                        _formatNumber(totalMaxMarks),
                        'Maximum Marks',
                      ),
                    ),
                    _verticalDivider(),
                    Expanded(
                      child: _summaryItem(
                        Icons.emoji_events_rounded,
                        classRank?.toString() ?? '-',
                        'Class Rank',
                      ),
                    ),
                  ],
                ),
              ),
              if (sectionRank != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.groups_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Section Rank',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.72),
                          fontSize: 10,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '$sectionRank',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SCORE CIRCLE
  // ============================================================

  Widget _scoreCircle(double value) {
    final safeValue = value.clamp(0.0, 100.0);

    return SizedBox(
      height: 112,
      width: 112,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: 112,
            width: 112,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: 9,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation(
                Colors.white.withOpacity(0.16),
              ),
            ),
          ),
          SizedBox(
            height: 112,
            width: 112,
            child: CircularProgressIndicator(
              value: safeValue / 100,
              strokeWidth: 9,
              backgroundColor: Colors.transparent,
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${safeValue.round()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                'Score',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.65),
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(IconData icon, String value, String title) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.80), size: 17),
        const SizedBox(height: 5),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: TextStyle(
            color: Colors.white.withOpacity(0.62),
            fontSize: 8,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(
      height: 42,
      width: 1,
      color: Colors.white.withOpacity(0.12),
    );
  }

  // ============================================================
  // SECTION HEADER
  // ============================================================

  Widget _sectionHeader({required String title, required String subtitle}) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: textDark,
                  fontSize: 18,
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: border),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.analytics_rounded, size: 13, color: primary),
              SizedBox(width: 5),
              Text(
                'Marks',
                style: TextStyle(
                  color: textMuted,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // RESULT CARD
  // ============================================================

  Widget _resultCard(Map<String, dynamic> result, int index) {
    final color = _subjectColor(index);

    final marks = (result['marksObtained'] as double?) ?? 0;

    final maxMarks = (result['maxMarks'] as double?) ?? 0;

    final resultPercentage =
        (result['percentage'] as double?) ??
        (maxMarks > 0 ? (marks / maxMarks) * 100 : 0);

    final safePercentage = resultPercentage.clamp(0.0, 100.0);

    final scoreColor = _scoreColor(safePercentage);

    final grade = result['grade']?.toString() ?? '-';

    final subject = result['subjectName']?.toString() ?? 'Subject';

    final subjectCode = result['subjectCode']?.toString();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 47,
                width: 47,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(Icons.menu_book_rounded, color: color, size: 22),
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
                        color: textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (subjectCode != null &&
                        subjectCode.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subjectCode,
                        style: const TextStyle(
                          color: textMuted,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: scoreColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: scoreColor.withOpacity(0.12)),
                ),
                child: Text(
                  grade,
                  style: TextStyle(
                    color: scoreColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: safePercentage / 100,
                    minHeight: 7,
                    backgroundColor: const Color(0xFFEDF0F5),
                    valueColor: AlwaysStoppedAnimation(scoreColor),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${safePercentage.round()}%',
                style: TextStyle(
                  color: scoreColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          Row(
            children: [
              Expanded(
                child: _resultInfo(
                  Icons.stars_rounded,
                  '${_formatNumber(marks)} / ${_formatNumber(maxMarks)}',
                  'Marks',
                ),
              ),
              Expanded(
                child: _resultInfo(
                  Icons.percent_rounded,
                  '${safePercentage.round()}%',
                  'Percentage',
                ),
              ),
              Expanded(child: _resultInfo(Icons.grade_rounded, grade, 'Grade')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _resultInfo(IconData icon, String value, String title) {
    return Row(
      children: [
        Icon(icon, color: textMuted, size: 14),
        const SizedBox(width: 5),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: textDark,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: const TextStyle(
                  color: textMuted,
                  fontSize: 8,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // REMARKS
  // ============================================================

  Widget _remarksCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.10),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: Color(0xFFF59E0B),
                  size: 19,
                ),
              ),
              const SizedBox(width: 11),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Teacher Remarks',
                    style: TextStyle(
                      color: textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Feedback from the school',
                    style: TextStyle(color: textMuted, fontSize: 9),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Text(
              remarks!,
              style: const TextStyle(
                color: textDark,
                fontSize: 11,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REPORT BUTTON
  // ============================================================

  Widget _reportCardButton() {
    return SizedBox(
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Report card download will be available soon.'),
            ),
          );
        },
        icon: const Icon(Icons.download_rounded, size: 19),
        label: const Text(
          'Download Report Card',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
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
          height: MediaQuery.of(context).size.height * .70,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 86,
                    width: 86,
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.assignment_outlined,
                      size: 42,
                      color: primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'No Published Results',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textDark,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Exam results will appear here once '
                    'the school publishes them.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textMuted,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: _loadResults,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Refresh'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primary,
                      side: const BorderSide(color: primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
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
  // SELECTED EXAM EMPTY
  // ============================================================

  Widget _selectedExamEmpty() {
    return Container(
      margin: const EdgeInsets.only(top: 5),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.assignment_late_outlined,
              color: primary,
              size: 34,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'No Results for ${selectedExam ?? 'this exam'}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: textDark,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Published subject results are not available for this examination.',
            textAlign: TextAlign.center,
            style: TextStyle(color: textMuted, fontSize: 11, height: 1.4),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _errorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 82,
              width: 82,
              decoration: BoxDecoration(
                color: const Color(0xFFDC2626).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 42,
                color: Color(0xFFDC2626),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Unable to Load Results',
              style: TextStyle(
                color: textDark,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              errorMessage ??
                  'Something went wrong while loading exam results.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: textMuted,
                fontSize: 11,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadResults,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // LOADING
  // ============================================================

  Widget _loadingView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _skeletonBox(height: 125, radius: 23),
        const SizedBox(height: 15),
        _skeletonBox(height: 130, radius: 19),
        const SizedBox(height: 15),
        _skeletonBox(height: 230, radius: 24),
        const SizedBox(height: 20),
        _skeletonBox(height: 115, radius: 19),
        const SizedBox(height: 11),
        _skeletonBox(height: 115, radius: 19),
      ],
    );
  }

  Widget _skeletonBox({required double height, required double radius}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: border),
      ),
    );
  }
}
