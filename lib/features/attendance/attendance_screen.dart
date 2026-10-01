import 'package:flutter/material.dart';

import '../../models/student_response.dart';
import '../../services/api_service.dart';
import '../../services/attendance_service.dart';
import '../attendance/models/attendance_report.dart';
import '../attendance/models/attendance_response.dart';


class AttendanceScreen extends StatefulWidget {
  final StudentResponse student;

  const AttendanceScreen({super.key, required this.student});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {

  // ---------------------------------------------------------------------------
  // THEME
  // ---------------------------------------------------------------------------

  static const Color primary = Color(0xFF3155D9);
  static const Color primaryDark = Color(0xFF2343B8);
  static const Color background = Color(0xFFF6F8FC);
  static const Color textDark = Color(0xFF172033);
  static const Color textMuted = Color(0xFF697386);
  static const Color border = Color(0xFFE5E9F0);

  // ---------------------------------------------------------------------------
  // DATA
  // ---------------------------------------------------------------------------

  AttendanceReport? report;
  List<AttendanceResponse> attendance = [];

  bool isLoading = true;
  String? errorMessage;

  late DateTime startDate;
  late DateTime endDate;

  // ---------------------------------------------------------------------------
  // INIT
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    startDate = DateTime(now.year, now.month, 1);

    endDate = DateTime(now.year, now.month, now.day);

    _loadAttendance();
  }

  // ---------------------------------------------------------------------------
  // API
  // ---------------------------------------------------------------------------

  Future<void> _loadAttendance() async {
    if (widget.student.classId == null) {
      setState(() {
        isLoading = false;
        errorMessage = 'Class information is not available.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      debugPrint('==========================================');
      debugPrint('ATTENDANCE LOAD');
      debugPrint('Student ID: ${widget.student.id}');
      debugPrint('Student Name: ${widget.student.name}');
      debugPrint('Class ID: ${widget.student.classId}');
      debugPrint('Start Date: $startDate');
      debugPrint('End Date: $endDate');
      debugPrint('==========================================');

      final attendanceResponse = await AttendanceService.getStudentAttendance(
        widget.student.id,
        startDate,
        endDate,
      );

      final reportResponse = await AttendanceService.getStudentAttendanceReport(
        widget.student.id,
        widget.student.classId!,
        startDate,
        endDate,
      );

      if (attendanceResponse.statusCode != 200) {
        throw Exception(
          'Attendance API failed: ${attendanceResponse.statusCode}',
        );
      }

      if (reportResponse.statusCode != 200) {
        throw Exception(
          'Attendance report API failed: ${reportResponse.statusCode}',
        );
      }

      final attendanceData = ApiService.decodeResponse(attendanceResponse);

      final reportData = ApiService.decodeResponse(reportResponse);

      final loadedAttendance = (attendanceData as List<dynamic>)
          .map(
            (item) => AttendanceResponse.fromJson(item as Map<String, dynamic>),
          )
          .toList();

      final loadedReport = AttendanceReport.fromJson(
        reportData as Map<String, dynamic>,
      );

      loadedAttendance.sort(
        (a, b) => b.attendanceDate.compareTo(a.attendanceDate),
      );

      if (!mounted) return;

      setState(() {
        attendance = loadedAttendance;
        report = loadedReport;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Attendance load failed: $e');

      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Unable to load attendance.\n$e';
      });
    }
  }

  // ---------------------------------------------------------------------------
  // DATE HELPERS
  // ---------------------------------------------------------------------------

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

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatMonth(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return months[date.month - 1];
  }

  String _formatShortMonth(DateTime date) {
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

    return months[date.month - 1];
  }

  String _periodTitle() {
    if (startDate.year == endDate.year && startDate.month == endDate.month) {
      return '${_formatMonth(startDate)} ${startDate.year}';
    }

    return '${_formatDate(startDate)} – ${_formatDate(endDate)}';
  }

  String _dayName(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return days[date.weekday - 1];
  }

  // ---------------------------------------------------------------------------
  // STATUS HELPERS
  // ---------------------------------------------------------------------------

  bool _isPresent(AttendanceResponse item) {
    return (item.status ?? '').toUpperCase() == 'PRESENT';
  }

  bool _isAbsent(AttendanceResponse item) {
    return (item.status ?? '').toUpperCase() == 'ABSENT';
  }

  bool _isLeave(AttendanceResponse item) {
    return (item.status ?? '').toUpperCase() == 'LEAVE';
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PRESENT':
        return const Color(0xFF16A34A);

      case 'ABSENT':
        return const Color(0xFFDC2626);

      case 'LEAVE':
        return const Color(0xFFF59E0B);

      default:
        return const Color(0xFF64748B);
    }
  }

  Color _statusBackground(String? status) {
    switch ((status ?? '').toUpperCase()) {
      case 'PRESENT':
        return const Color(0xFFEAF8EF);

      case 'ABSENT':
        return const Color(0xFFFFEEEE);

      case 'LEAVE':
        return const Color(0xFFFFF7E5);

      default:
        return const Color(0xFFF1F5F9);
    }
  }

  IconData _statusIcon(String? status) {
    switch ((status ?? '').toUpperCase()) {
      case 'PRESENT':
        return Icons.check_circle_rounded;

      case 'ABSENT':
        return Icons.cancel_rounded;

      case 'LEAVE':
        return Icons.event_busy_rounded;

      default:
        return Icons.help_rounded;
    }
  }

  String _statusLabel(String? status) {
    switch ((status ?? '').toUpperCase()) {
      case 'PRESENT':
        return 'Present';

      case 'ABSENT':
        return 'Absent';

      case 'LEAVE':
        return 'Leave';

      default:
        return status?.isNotEmpty == true ? status! : 'Unknown';
    }
  }

  // ---------------------------------------------------------------------------
  // DATE RANGE
  // ---------------------------------------------------------------------------

  Future<void> _selectCustomDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(
        DateTime.now().year - 1,
        DateTime.now().month,
        DateTime.now().day,
      ),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: startDate, end: endDate),
      helpText: 'SELECT ATTENDANCE PERIOD',
      saveText: 'APPLY',
      cancelText: 'CANCEL',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: textDark,
            ),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: Colors.white,
              headerBackgroundColor: primary,
              headerForegroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              rangeSelectionBackgroundColor: Color(0x263155D9),
              rangeSelectionOverlayColor: WidgetStateProperty.all(
                const Color(0x123155D9),
              ),
              todayBackgroundColor: WidgetStateProperty.all(
                const Color(0x143155D9),
              ),
              todayForegroundColor: WidgetStateProperty.all(primary),
              dayShape: WidgetStateProperty.all(const CircleBorder()),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;

    setState(() {
      startDate = DateTime(
        picked.start.year,
        picked.start.month,
        picked.start.day,
      );

      endDate = DateTime(picked.end.year, picked.end.month, picked.end.day);
    });

    await _loadAttendance();
  }

  // ---------------------------------------------------------------------------
  // PREMIUM FILTER SHEET
  // ---------------------------------------------------------------------------

  Future<void> _openPeriodFilter() async {
    int selectedMonth = startDate.month;
    int selectedYear = startDate.year;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD7DCE5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF3FF),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.tune_rounded, color: primary),
                        ),

                        const SizedBox(width: 12),

                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Attendance Period',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: textDark,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Select month and year',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),

                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    Row(
                      children: [
                        Expanded(
                          child: _selectorBox(
                            label: 'MONTH',
                            value: _formatMonth(
                              DateTime(selectedYear, selectedMonth),
                            ),
                            icon: Icons.calendar_month_rounded,
                            onTap: () async {
                              final month = await _showMonthSelector(
                                selectedMonth,
                                selectedYear,
                              );

                              if (month != null) {
                                setSheetState(() {
                                  selectedMonth = month;
                                });
                              }
                            },
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: _selectorBox(
                            label: 'YEAR',
                            value: '$selectedYear',
                            icon: Icons.event_rounded,
                            onTap: () async {
                              final year = await _showYearSelector(
                                selectedYear,
                              );

                              if (year != null) {
                                setSheetState(() {
                                  selectedYear = year;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Quick Select',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: textDark,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _quickFilterChip(
                          'This Month',
                          Icons.calendar_today_rounded,
                          () {
                            final now = DateTime.now();

                            setSheetState(() {
                              selectedMonth = now.month;
                              selectedYear = now.year;
                            });
                          },
                        ),
                        _quickFilterChip(
                          'Last Month',
                          Icons.history_rounded,
                          () {
                            final now = DateTime.now();

                            final previous = DateTime(now.year, now.month - 1);

                            setSheetState(() {
                              selectedMonth = previous.month;
                              selectedYear = previous.year;
                            });
                          },
                        ),
                        _quickFilterChip(
                          'This Year',
                          Icons.date_range_rounded,
                          () {
                            final now = DateTime.now();

                            setSheetState(() {
                              selectedMonth = now.month;
                              selectedYear = now.year;
                            });
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.pop(context);
                        _selectCustomDateRange();
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF3FF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.date_range_rounded,
                                color: primary,
                                size: 21,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Custom Date Range',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: textDark,
                                    ),
                                  ),
                                  SizedBox(height: 3),
                                  Text(
                                    'Choose specific dates',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: textMuted,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          final now = DateTime.now();

                          DateTime newStart;
                          DateTime newEnd;

                          if (selectedMonth == now.month &&
                              selectedYear == now.year) {
                            newStart = DateTime(selectedYear, selectedMonth, 1);

                            newEnd = DateTime(now.year, now.month, now.day);
                          } else {
                            newStart = DateTime(selectedYear, selectedMonth, 1);

                            newEnd = DateTime(
                              selectedYear,
                              selectedMonth + 1,
                              0,
                            );
                          }

                          setState(() {
                            startDate = newStart;
                            endDate = newEnd;
                          });

                          Navigator.pop(context);

                          _loadAttendance();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Apply Filter',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // MONTH SELECTOR
  // ---------------------------------------------------------------------------

  Future<int?> _showMonthSelector(int selectedMonth, int selectedYear) async {
    return showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _sheetHandle(),
                const SizedBox(height: 16),
                const Text(
                  'Select Month',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 14),
                Flexible(
                  child: GridView.builder(
                    shrinkWrap: true,
                    itemCount: 12,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 2.3,
                        ),
                    itemBuilder: (context, index) {
                      final month = index + 1;
                      final selected = month == selectedMonth;

                      return InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          Navigator.pop(context, month);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selected ? primary : const Color(0xFFF7F8FB),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: selected ? primary : border,
                            ),
                          ),
                          child: Text(
                            _formatShortMonth(DateTime(selectedYear, month)),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: selected ? Colors.white : textDark,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // YEAR SELECTOR
  // ---------------------------------------------------------------------------

  Future<int?> _showYearSelector(int selectedYear) async {
    final currentYear = DateTime.now().year;

    return showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _sheetHandle(),
                const SizedBox(height: 16),
                const Text(
                  'Select Year',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 260,
                  child: GridView.builder(
                    itemCount: 7,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 2.3,
                        ),
                    itemBuilder: (context, index) {
                      final year = currentYear - 5 + index;

                      final selected = year == selectedYear;

                      return InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          Navigator.pop(context, year);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selected ? primary : const Color(0xFFF7F8FB),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: selected ? primary : border,
                            ),
                          ),
                          child: Text(
                            '$year',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: selected ? Colors.white : textDark,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: false,
        title: const Text(
          'Attendance',
          style: TextStyle(
            color: textDark,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Attendance period',
            onPressed: isLoading ? null : _openPeriodFilter,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF3FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.tune_rounded, color: primary, size: 20),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(),
    );
  }

  // ---------------------------------------------------------------------------
  // BODY
  // ---------------------------------------------------------------------------

  Widget _buildBody() {
    if (isLoading) {
      return _loadingView();
    }

    if (errorMessage != null) {
      return _errorView();
    }

    return RefreshIndicator(
      color: primary,
      onRefresh: _loadAttendance,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
        children: [
          _studentCard(),

          const SizedBox(height: 14),

          _periodCard(),

          const SizedBox(height: 18),

          if (report != null) ...[
            _summarySection(),

            const SizedBox(height: 20),
          ],

          _attendanceSection(),

          const SizedBox(height: 22),

          _historySection(),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STUDENT CARD
  // ---------------------------------------------------------------------------

  Widget _studentCard() {
    final name = widget.student.name.trim();

    final initial = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'S';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primary, primaryDark],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(.18),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.16),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(.30),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? 'Student' : name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    const Icon(
                      Icons.school_rounded,
                      size: 15,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        'Class ${widget.student.sectionName ?? '-'}',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                if (widget.student.admissionNo != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Admission No: ${widget.student.admissionNo}',
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.verified_user_rounded,
              color: Colors.white,
              size: 21,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PERIOD CARD
  // ---------------------------------------------------------------------------

  Widget _periodCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF3FF),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: primary,
                  size: 21,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Attendance Period',
                      style: TextStyle(
                        color: textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _periodTitle(),
                      style: const TextStyle(color: textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),

              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _openPeriodFilter,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF3FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.tune_rounded, size: 16, color: primary),
                      SizedBox(width: 5),
                      Text(
                        'Filter',
                        style: TextStyle(
                          color: primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: border),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.date_range_rounded,
                  size: 18,
                  color: textMuted,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_formatDate(startDate)}  →  ${_formatDate(endDate)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: textDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SUMMARY
  // ---------------------------------------------------------------------------

  Widget _summarySection() {
    final percentage = report!.attendancePercentage.toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(title: 'Attendance Overview', subtitle: _periodTitle()),

        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(18),
          decoration: _cardDecoration(),
          child: Row(
            children: [
              _percentageCircle(percentage),

              const SizedBox(width: 18),

              Expanded(
                child: Column(
                  children: [
                    _summaryMetric(
                      icon: Icons.check_circle_rounded,
                      color: const Color(0xFF16A34A),
                      label: 'Present',
                      value: '${report!.presentDays}',
                    ),

                    const SizedBox(height: 10),

                    _summaryMetric(
                      icon: Icons.cancel_rounded,
                      color: const Color(0xFFDC2626),
                      label: 'Absent',
                      value: '${report!.absentDays}',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _percentageCircle(double percentage) {
    final safePercentage = percentage.clamp(0, 100);

    return SizedBox(
      width: 112,
      height: 112,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 104,
            height: 104,
            child: CircularProgressIndicator(
              value: safePercentage / 100,
              strokeWidth: 9,
              backgroundColor: const Color(0xFFE9EDF4),
              color: primary,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${safePercentage.toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: textDark,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Text(
                'Attendance',
                style: TextStyle(
                  color: textMuted,
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

  Widget _summaryMetric({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withOpacity(.10),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: color, size: 19),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        Text(
          value,
          style: const TextStyle(
            color: textDark,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // ATTENDANCE DAYS
  // ---------------------------------------------------------------------------

  Widget _attendanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(title: 'Attendance Calendar', subtitle: _periodTitle()),

        const SizedBox(height: 12),

        if (attendance.isEmpty) _emptyAttendance() else _calendarCard(),
      ],
    );
  }

  Widget _calendarCard() {
    final records = <String, AttendanceResponse>{};

    for (final item in attendance) {
      final key =
          '${item.attendanceDate.year}-'
          '${item.attendanceDate.month}-'
          '${item.attendanceDate.day}';

      records[key] = item;
    }

    final days = <DateTime>[];

    DateTime cursor = DateTime(startDate.year, startDate.month, startDate.day);

    final last = DateTime(endDate.year, endDate.month, endDate.day);

    while (!cursor.isAfter(last)) {
      days.add(cursor);
      cursor = cursor.add(const Duration(days: 1));
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 15, 12, 15),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Row(
            children: const [
              _DayHeader(text: 'M'),
              _DayHeader(text: 'T'),
              _DayHeader(text: 'W'),
              _DayHeader(text: 'T'),
              _DayHeader(text: 'F'),
              _DayHeader(text: 'S'),
              _DayHeader(text: 'S'),
            ],
          ),

          const SizedBox(height: 8),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: days.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 5,
              mainAxisSpacing: 7,
              childAspectRatio: 0.9,
            ),
            itemBuilder: (context, index) {
              final date = days[index];

              final key = '${date.year}-${date.month}-${date.day}';

              final record = records[key];

              return _calendarDay(date, record);
            },
          ),

          const SizedBox(height: 14),

          Wrap(
            spacing: 14,
            runSpacing: 8,
            children: [
              _legend('Present', const Color(0xFF16A34A)),
              _legend('Absent', const Color(0xFFDC2626)),
              _legend('Leave', const Color(0xFFF59E0B)),
              _legend('No Record', const Color(0xFFCBD5E1)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _calendarDay(DateTime date, AttendanceResponse? record) {
    final hasRecord = record != null;

    final color = hasRecord
        ? _statusColor(record!.status??'')
        : const Color(0xFFCBD5E1);

    final background = hasRecord
        ? _statusBackground(record!.status??'')
        : const Color(0xFFF8FAFC);

    return Container(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(.28)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${date.day}',
            style: TextStyle(
              color: hasRecord ? textDark : textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 4),

          if (hasRecord)
            Icon(_statusIcon(record.status ?? ''), color: color, size: 15)
          else
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
        ],
      ),
    );
  }

  Widget _legend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            color: textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // HISTORY
  // ---------------------------------------------------------------------------

  Widget _historySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          title: 'Attendance History',
          subtitle: '${attendance.length} records',
        ),

        const SizedBox(height: 12),

        if (attendance.isEmpty)
          _emptyHistory()
        else
          ...attendance.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _historyTile(item),
            ),
          ),
      ],
    );
  }

  Widget _historyTile(AttendanceResponse item) {
    final color = _statusColor(item.status ?? '');

    final bg = _statusBackground(item.status ?? '');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_statusIcon(item.status ?? ''), color: color, size: 23),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(item.attendanceDate),
                  style: const TextStyle(
                    color: textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  _dayName(item.attendanceDate),
                  style: const TextStyle(
                    color: textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _statusLabel(item.status),
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // LOADING
  // ---------------------------------------------------------------------------

  Widget _loadingView() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        _skeleton(height: 130, radius: 22),
        const SizedBox(height: 14),
        _skeleton(height: 110, radius: 20),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(child: _skeleton(height: 150, radius: 20)),
            const SizedBox(width: 12),
            Expanded(child: _skeleton(height: 150, radius: 20)),
          ],
        ),
        const SizedBox(height: 18),
        _skeleton(height: 300, radius: 20),
      ],
    );
  }

  Widget _skeleton({required double height, required double radius}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFEDEFF4),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ERROR
  // ---------------------------------------------------------------------------

  Widget _errorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: _cardDecoration(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEEEE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cloud_off_rounded,
                  color: Color(0xFFDC2626),
                  size: 32,
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Unable to load attendance',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textDark,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                errorMessage ?? 'Something went wrong.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: textMuted, fontSize: 12),
              ),

              const SizedBox(height: 20),

              SizedBox(
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: _loadAttendance,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text(
                    'Try Again',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // EMPTY
  // ---------------------------------------------------------------------------

  Widget _emptyAttendance() {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF3FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_available_rounded,
              color: primary,
              size: 30,
            ),
          ),

          const SizedBox(height: 14),

          const Text(
            'No attendance records',
            style: TextStyle(
              color: textDark,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'No attendance data found for $_periodTitle().',
            textAlign: TextAlign.center,
            style: const TextStyle(color: textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _emptyHistory() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _cardDecoration(),
      child: const Center(
        child: Text(
          'No history available',
          style: TextStyle(
            color: textMuted,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // COMMON UI
  // ---------------------------------------------------------------------------

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
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _selectorBox({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FC),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 19, color: primary),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: textMuted,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: textDark,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 19,
              color: textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickFilterChip(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: primary),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                color: textDark,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sheetHandle() {
    return Container(
      width: 42,
      height: 5,
      decoration: BoxDecoration(
        color: const Color(0xFFD7DCE5),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: border),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(.035),
          blurRadius: 18,
          offset: const Offset(0, 7),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// CALENDAR DAY HEADER
// -----------------------------------------------------------------------------

class _DayHeader extends StatelessWidget {
  final String text;

  const _DayHeader({required this.text});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFF8A93A3),
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
