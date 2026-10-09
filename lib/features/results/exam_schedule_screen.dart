
import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../models/student_response.dart';
import '../../../services/exam_service.dart';

class ExamScheduleScreen extends StatefulWidget {
  final StudentResponse student;

  const ExamScheduleScreen({
    super.key,
    required this.student,
  });

  @override
  State<ExamScheduleScreen> createState() =>
      _ExamScheduleScreenState();
}

class _ExamScheduleScreenState extends State<ExamScheduleScreen> {
  bool _isLoading = true;
  String? _error;

  List<Map<String, dynamic>> _schedules = [];

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final student = widget.student;

      if (student.classId == null) {
        throw Exception('Student class is not available');
      }

      final response = await ExamService.getExamSchedules(
        classId: student.classId,
        sectionId: student.sectionId,
      );

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw Exception(
          'Failed to load exam schedules: ${response.statusCode}',
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! List) {
        throw Exception('Invalid exam schedule response');
      }

      final schedules = decoded
          .whereType<Map<String, dynamic>>()
          .toList()
        ..sort((a, b) {
          final dateA = DateTime.tryParse(
            a['examDate']?.toString() ?? '',
          );

          final dateB = DateTime.tryParse(
            b['examDate']?.toString() ?? '',
          );

          if (dateA == null && dateB == null) return 0;
          if (dateA == null) return 1;
          if (dateB == null) return -1;

          final comparison = dateA.compareTo(dateB);

          if (comparison != 0) return comparison;

          final timeA = a['startTime']?.toString() ?? '';
          final timeB = b['startTime']?.toString() ?? '';

          return timeA.compareTo(timeB);
        });

      if (!mounted) return;

      setState(() {
        _schedules = schedules;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = widget.student.classId == null
            ? 'Class information is unavailable for this student.'
            : 'Unable to load exam schedule. Please try again.';
        _isLoading = false;
      });
    }
  }

  String _formatDate(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? '');

    if (date == null) return 'Date not available';

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    return '${date.day.toString().padLeft(2, '0')} '
        '${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return 'Time not announced';
    }

    final parts = value.toString().split(':');

    if (parts.length < 2) return value.toString();

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) {
      return value.toString();
    }

    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;

    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  String _shortDay(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? '');

    return date == null
        ? '--'
        : date.day.toString().padLeft(2, '0');
  }

  String _shortMonth(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? '');

    if (date == null) return '---';

    const months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
    ];

    return months[date.month - 1];
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF2864C5);

    final student = widget.student;

    final classLabel = student.className?.trim().isNotEmpty == true
        ? student.className!.trim()
        : 'Class';

    final sectionLabel = student.sectionName?.trim() ?? '';

    final studentClassLabel = sectionLabel.isNotEmpty
        ? '$classLabel • Section $sectionLabel'
        : classLabel;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          'Exam Schedule',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1D2939),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _error != null
              ? _buildMessage(
                  icon: Icons.cloud_off_outlined,
                  message: _error!,
                  action: 'Retry',
                  onPressed: _loadSchedules,
                )
              : _schedules.isEmpty
                  ? RefreshIndicator(
                      onRefresh: _loadSchedules,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          const SizedBox(height: 150),
                          _buildMessage(
                            icon: Icons.event_available_outlined,
                            message:
                                'No exam schedule available for '
                                '$studentClassLabel yet.',
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadSchedules,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        children: [
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF2864C5),
                                  Color(0xFF5389E8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              children: [
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Be exam-ready!',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        'Check your subjects, dates and timings.',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.event_note_rounded,
                                  color: Colors.white,
                                  size: 42,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 18),

                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFE8EDF5),
                              ),
                            ),
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  backgroundColor: Color(0xFFEAF1FF),
                                  child: Icon(
                                    Icons.school_outlined,
                                    color: primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        student.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Color(0xFF1D2939),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        studentClassLabel,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF667085),
                                        ),
                                      ),
                                      if (student.academicYearName
                                              ?.trim()
                                              .isNotEmpty ==
                                          true) ...[
                                        const SizedBox(height: 3),
                                        Text(
                                          student.academicYearName!,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF667085),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 22),

                          Text(
                            'All Exams (${_schedules.length})',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1D2939),
                            ),
                          ),

                          const SizedBox(height: 12),

                          ..._schedules.map((exam) {
                            final subject =
                                exam['subjectName']?.toString() ??
                                    'Subject not available';

                            final examName =
                                exam['examinationName']?.toString() ?? '';

                            final date = exam['examDate'];
                            final time = exam['startTime'];

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFE8EDF5),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 54,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEAF1FF),
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          _shortDay(date),
                                          style: const TextStyle(
                                            color: primary,
                                            fontSize: 21,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          _shortMonth(date),
                                          style: const TextStyle(
                                            color: primary,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 14),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          subject,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1D2939),
                                          ),
                                        ),

                                        if (examName.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            examName,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF667085),
                                            ),
                                          ),
                                        ],

                                        const SizedBox(height: 10),

                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.calendar_today_outlined,
                                              size: 15,
                                              color: primary,
                                            ),
                                            const SizedBox(width: 6),
                                            Flexible(
                                              child: Text(
                                                _formatDate(date),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF475467),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 6),

                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.access_time_rounded,
                                              size: 16,
                                              color: primary,
                                            ),
                                            const SizedBox(width: 6),
                                            Flexible(
                                              child: Text(
                                                _formatTime(time),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF475467),
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
                            );
                          }),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildMessage({
    required IconData icon,
    required String message,
    String? action,
    VoidCallback? onPressed,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 54,
              color: Colors.blueGrey,
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF475467),
              ),
            ),
            if (action != null && onPressed != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onPressed,
                child: Text(action),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
