import 'package:flutter/material.dart';

import '../../models/student_response.dart';
import '../../services/api_service.dart';
import '../attendance/models/attendance_report.dart';
import '../attendance/models/attendance_response.dart';

class AttendanceScreen extends StatefulWidget {
  final StudentResponse student;

  const AttendanceScreen({super.key, required this.student});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  AttendanceReport? report;
  List<AttendanceResponse> attendance = [];

  bool isLoading = true;
  String? errorMessage;

  late DateTime startDate;
  late DateTime endDate;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    startDate = DateTime(now.year, now.month, 1);

    endDate = now;

    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    if (widget.student.classId == null) {
      setState(() {
        isLoading = false;
        errorMessage = 'Class information is not available.';
      });

      debugPrint("========== ATTENDANCE DEBUG ==========");
      debugPrint("Student ID : ${widget.student.id}");
      debugPrint("Student    : ${widget.student.name}");
      debugPrint("Class ID   : NULL");
      debugPrint("======================================");

      return;
    }

    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      debugPrint("========== ATTENDANCE DEBUG ==========");
      debugPrint("Student ID : ${widget.student.id}");
      debugPrint("Student    : ${widget.student.name}");
      debugPrint("Class ID   : ${widget.student.classId}");
      debugPrint("Section ID : ${widget.student.sectionId}");
      debugPrint("Start Date : $startDate");
      debugPrint("End Date   : $endDate");
      debugPrint("======================================");

      // ==========================================================
      // ATTENDANCE API
      // ==========================================================

      final attendanceResponse = await ApiService.getStudentAttendance(
        widget.student.id,
        startDate,
        endDate,
      );

      debugPrint("========== ATTENDANCE API ==========");
      debugPrint("Status Code : ${attendanceResponse.statusCode}");
      debugPrint("Response    : ${attendanceResponse.body}");
      debugPrint("====================================");

      // ==========================================================
      // REPORT API
      // ==========================================================

      final reportResponse = await ApiService.getStudentAttendanceReport(
        widget.student.id,
        widget.student.classId!,
        startDate,
        endDate,
      );

      debugPrint("========== ATTENDANCE REPORT API ==========");
      debugPrint("Status Code : ${reportResponse.statusCode}");
      debugPrint("Response    : ${reportResponse.body}");
      debugPrint("===========================================");

      // ==========================================================
      // STATUS CHECK
      // ==========================================================

      if (attendanceResponse.statusCode != 200) {
        throw Exception(
          'Attendance API failed: '
          '${attendanceResponse.statusCode} '
          '${attendanceResponse.body}',
        );
      }

      if (reportResponse.statusCode != 200) {
        throw Exception(
          'Attendance report API failed: '
          '${reportResponse.statusCode} '
          '${reportResponse.body}',
        );
      }

      // ==========================================================
      // DECODE
      // ==========================================================

      final attendanceData = ApiService.decodeResponse(attendanceResponse);

      final reportData = ApiService.decodeResponse(reportResponse);

      debugPrint("========== DECODED DATA ==========");
      debugPrint("Attendance Data: $attendanceData");
      debugPrint("Report Data    : $reportData");
      debugPrint("==================================");

      // ==========================================================
      // PARSE ATTENDANCE
      // ==========================================================

      final loadedAttendance = (attendanceData as List<dynamic>)
          .map(
            (item) => AttendanceResponse.fromJson(item as Map<String, dynamic>),
          )
          .toList();

      // ==========================================================
      // PARSE REPORT
      // ==========================================================

      final loadedReport = AttendanceReport.fromJson(
        reportData as Map<String, dynamic>,
      );

      loadedAttendance.sort(
        (a, b) => b.attendanceDate.compareTo(a.attendanceDate),
      );

      debugPrint("========== FINAL ATTENDANCE ==========");
      debugPrint("Records Count : ${loadedAttendance.length}");
      debugPrint("Report        : $loadedReport");
      debugPrint("======================================");

      if (!mounted) return;

      setState(() {
        attendance = loadedAttendance;
        report = loadedReport;
        isLoading = false;
      });
    } catch (e, stackTrace) {
      debugPrint("========== ATTENDANCE ERROR ==========");
      debugPrint("Error : $e");
      debugPrint("Stack : $stackTrace");
      debugPrint("======================================");

      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Unable to load attendance.\n$e';
      });
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} '
        '${months[date.month - 1]} '
        '${date.year}';
  }

  String _dayName(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return days[date.weekday - 1];
  }

  bool _isPresent(AttendanceResponse item) {
    return item.status?.toUpperCase() == 'PRESENT';
  }

  bool _isAbsent(AttendanceResponse item) {
    return item.status?.toUpperCase() == 'ABSENT';
  }

  Color _statusColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'PRESENT':
        return Colors.green;

      case 'ABSENT':
        return Colors.red;

      case 'LEAVE':
        return Colors.orange;

      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String? status) {
    switch (status?.toUpperCase()) {
      case 'PRESENT':
        return Icons.check_circle;

      case 'ABSENT':
        return Icons.cancel;

      case 'LEAVE':
        return Icons.event_busy;

      default:
        return Icons.help_outline;
    }
  }

  Future<void> _selectDateRange() async {
    final selected = await showDateRangePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: startDate, end: endDate),
    );

    if (selected == null) {
      return;
    }

    setState(() {
      startDate = selected.start;
      endDate = selected.end;
    });

    await _loadAttendance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F8FC),

      appBar: AppBar(
        title: const Text("Attendance"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? _errorView()
          : RefreshIndicator(
              onRefresh: _loadAttendance,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _studentCard(),

                  const SizedBox(height: 20),

                  _dateRangeCard(),

                  const SizedBox(height: 20),

                  //---------------------------------------
                  // Summary
                  //---------------------------------------
                  if (report != null)
                    Row(
                      children: [
                        Expanded(
                          child: summaryCard(
                            "Present",
                            report!.presentDays.toString(),
                            Colors.green,
                            Icons.check_circle,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: summaryCard(
                            "Absent",
                            report!.absentDays.toString(),
                            Colors.red,
                            Icons.cancel,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: summaryCard(
                            "%",
                            '${report!.attendancePercentage.toStringAsFixed(0)}%',
                            Colors.blue,
                            Icons.bar_chart,
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 25),

                  const Text(
                    "This Month",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),

                  const SizedBox(height: 15),

                  //---------------------------------------
                  // Calendar
                  //---------------------------------------
                  if (attendance.isEmpty)
                    _emptyAttendance()
                  else
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: attendance.map((item) {
                        final color = _statusColor(item.status);

                        return Container(
                          width: 65,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Text(
                                _dayName(item.attendanceDate),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),

                              const SizedBox(height: 5),

                              Text(
                                item.attendanceDate.day.toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Icon(_statusIcon(item.status), color: color),
                            ],
                          ),
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: 30),

                  const Text(
                    "Attendance History",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),

                  const SizedBox(height: 15),

                  //---------------------------------------
                  // History
                  //---------------------------------------
                  if (attendance.isEmpty)
                    _emptyHistory()
                  else
                    ...attendance.map((item) => historyTile(item)),
                ],
              ),
            ),
    );
  }

  //---------------------------------------
  // Student Card
  //---------------------------------------

  Widget _studentCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff1565C0), Color(0xff42A5F5)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white,
            child: Text(
              widget.student.name.isNotEmpty
                  ? widget.student.name[0].toUpperCase()
                  : "?",
              style: const TextStyle(
                color: Color(0xff1565C0),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.student.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  widget.student.sectionName ?? "Class information unavailable",
                  style: const TextStyle(color: Colors.white70),
                ),

                if (widget.student.admissionNo != null)
                  Text(
                    "Admission No: "
                    "${widget.student.admissionNo}",
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //---------------------------------------
  // Date Range
  //---------------------------------------

  Widget _dateRangeCard() {
    return InkWell(
      onTap: _selectDateRange,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            const Icon(Icons.date_range, color: Color(0xff1565C0)),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Attendance Period",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    "${_formatDate(startDate)} - "
                    "${_formatDate(endDate)}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  //---------------------------------------
  // Summary Card
  //---------------------------------------

  Widget summaryCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),

          const SizedBox(height: 10),

          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 5),

          Text(title),
        ],
      ),
    );
  }

  //---------------------------------------
  // History Tile
  //---------------------------------------

  Widget historyTile(AttendanceResponse item) {
    final color = _statusColor(item.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(_statusIcon(item.status), color: color),
        ),

        title: Text(_formatDate(item.attendanceDate)),

        subtitle: Text(item.status ?? "Unknown"),

        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey.shade500,
        ),
      ),
    );
  }

  //---------------------------------------
  // Empty
  //---------------------------------------

  Widget _emptyAttendance() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Center(
        child: Text(
          "No attendance records found.",
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _emptyHistory() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Center(
        child: Text(
          "No attendance history found.",
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  //---------------------------------------
  // Error
  //---------------------------------------

  Widget _errorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 50, color: Colors.red),

            const SizedBox(height: 12),

            Text(errorMessage!, textAlign: TextAlign.center),

            const SizedBox(height: 15),

            ElevatedButton(
              onPressed: _loadAttendance,
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }
}
