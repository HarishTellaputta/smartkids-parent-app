import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../models/student_timetable.dart';

class TimetableScreen extends StatefulWidget {
  final int studentId;

  const TimetableScreen({super.key, required this.studentId});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  List<StudentTimetable> timetable = [];

  bool isLoading = true;
  String? errorMessage;

  final List<String> days = [
    'MONDAY',
    'TUESDAY',
    'WEDNESDAY',
    'THURSDAY',
    'FRIDAY',
    'SATURDAY',
  ];

  int selectedDayIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadTimetable();
  }

  Future<void> _loadTimetable() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final response = await ApiService.getStudentTimetable(widget.studentId);

      debugPrint('📚 Timetable API status: ${response.statusCode}');

      debugPrint('📚 Timetable API response: ${response.body}');

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = ApiService.decodeResponse(response);

        if (data is List) {
          final result = data
              .map(
                (item) =>
                    StudentTimetable.fromJson(item as Map<String, dynamic>),
              )
              .toList();

          setState(() {
            timetable = result;
            isLoading = false;
          });
        } else {
          setState(() {
            timetable = [];
            isLoading = false;
            errorMessage = 'Invalid timetable response';
          });
        }
      } else {
        setState(() {
          timetable = [];
          isLoading = false;
          errorMessage = 'Unable to load timetable (${response.statusCode})';
        });
      }
    } catch (e) {
      debugPrint('❌ Timetable loading error: $e');

      if (!mounted) return;

      setState(() {
        timetable = [];
        isLoading = false;
        errorMessage = 'Unable to load timetable';
      });
    }
  }

  List<StudentTimetable> get selectedDayPeriods {
    final selectedDay = days[selectedDayIndex];

    final result = timetable
        .where((item) => item.dayOfWeek.toUpperCase() == selectedDay)
        .toList();

    result.sort((a, b) => a.startTime.compareTo(b.startTime));

    return result;
  }

  String _formatDay(String day) {
    return day.substring(0, 1) + day.substring(1).toLowerCase();
  }

  String _formatTime(String time) {
    if (time.isEmpty) return '';

    final parts = time.split(':');

    if (parts.length < 2) return time;

    int hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts[1];

    final period = hour >= 12 ? 'PM' : 'AM';

    hour = hour % 12;

    if (hour == 0) {
      hour = 12;
    }

    return '$hour:$minute $period';
  }

  Color _periodColor(int index) {
    const colors = [
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.teal,
      Colors.red,
      Colors.indigo,
    ];

    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final periods = selectedDayPeriods;

    return Scaffold(
      backgroundColor: const Color(0xffF5F8FC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Timetable",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 50, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(errorMessage!),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: _loadTimetable,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadTimetable,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // =====================================================
                  // DAY SELECTOR
                  // =====================================================

                  SizedBox(
                    height: 48,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: days.length,
                      itemBuilder: (context, index) {
                        final selected = index == selectedDayIndex;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedDayIndex = index;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xff1565C0)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: selected
                                    ? const Color(0xff1565C0)
                                    : Colors.grey.shade300,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _formatDay(days[index]),
                              style: TextStyle(
                                color: selected ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // =====================================================
                  // DAY HEADER
                  // =====================================================
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xff1565C0), Color(0xff42A5F5)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_month,
                          color: Colors.white,
                          size: 30,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatDay(days[selectedDayIndex]),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${periods.length} Periods',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // =====================================================
                  // NO PERIODS
                  // =====================================================
                  if (periods.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.event_busy, size: 50, color: Colors.grey),
                          SizedBox(height: 12),
                          Text(
                            'No timetable available',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // =====================================================
                  // PERIODS
                  // =====================================================
                  ...List.generate(periods.length, (index) {
                    final period = periods[index];
                    final color = _periodColor(index);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 15),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 8,
                              height: 105,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),

                            const SizedBox(width: 16),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    period.subjectName,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.access_time,
                                        size: 18,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${_formatTime(period.startTime)} - '
                                        '${_formatTime(period.endTime)}',
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 8),

                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.person,
                                        size: 18,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(child: Text(period.teacherName)),
                                    ],
                                  ),

                                  if (period.roomNumber != null &&
                                      period.roomNumber!.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.meeting_room,
                                          size: 18,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(period.roomNumber!),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: color.withOpacity(.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "P${index + 1}",
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }
}
