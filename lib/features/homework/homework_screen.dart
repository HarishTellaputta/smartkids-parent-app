import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import 'package:parent_app/models/homework.dart';

class HomeworkScreen extends StatefulWidget {
  final int classId;
  final int sectionId;

  const HomeworkScreen({
    super.key,
    required this.classId,
    required this.sectionId,
  });

  @override
  State<HomeworkScreen> createState() => _HomeworkScreenState();
}

class _HomeworkScreenState extends State<HomeworkScreen> {
  List<Homework> homeworkList = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadHomework();
  }

  Future<void> loadHomework() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await ApiService.getStudentHomework(
        widget.classId,
        widget.sectionId,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.body.isNotEmpty
            ? jsonDecode(response.body)
            : [];

        setState(() {
          homeworkList = data
              .map(
                (json) => Homework.fromJson(
                  json as Map<String, dynamic>,
                ),
              )
              .toList();

          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage =
              'Failed to load homework (${response.statusCode})';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Unable to load homework';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = homeworkList.length;

    final pending = homeworkList.where((hw) {
      final status = hw.status.toLowerCase();
      return status == 'pending';
    }).length;

    final done = homeworkList.where((hw) {
      final status = hw.status.toLowerCase();

      return status == 'submitted' ||
          status == 'completed' ||
          status == 'done';
    }).length;

    return Scaffold(
      backgroundColor: const Color(0xffF5F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text("Homework"),
      ),
      body: RefreshIndicator(
        onRefresh: loadHomework,
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : errorMessage != null
                ? ListView(
                    children: [
                      const SizedBox(height: 150),
                      Center(
                        child: Column(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 50,
                              color: Colors.redAccent,
                            ),
                            const SizedBox(height: 12),
                            Text(errorMessage!),
                            const SizedBox(height: 15),
                            ElevatedButton(
                              onPressed: loadHomework,
                              child: const Text("Retry"),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: summaryCard(
                              "Total",
                              "$total",
                              Colors.blue,
                              Icons.book,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: summaryCard(
                              "Pending",
                              "$pending",
                              Colors.orange,
                              Icons.pending_actions,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: summaryCard(
                              "Done",
                              "$done",
                              Colors.green,
                              Icons.check_circle,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      const Text(
                        "Homework List",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),

                      const SizedBox(height: 15),

                      if (homeworkList.isEmpty)
                        emptyHomework(),

                      ...homeworkList.map(
                        (hw) => homeworkCard(hw),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
      ),
    );
  }

  Widget summaryCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
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
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(title),
        ],
      ),
    );
  }

  Widget homeworkCard(Homework hw) {
    final status = hw.status.toLowerCase();

    final bool isDone =
        status == 'submitted' ||
        status == 'completed' ||
        status == 'done';

    final statusColor =
        isDone ? Colors.green : Colors.orange;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Chip(
                  label: Text(hw.subjectName),
                  backgroundColor: Colors.blue.shade50,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(.15),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    hw.status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Text(
              hw.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              hw.description,
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                const Icon(
                  Icons.person,
                  size: 18,
                  color: Colors.grey,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    hw.assignedByTeacherName,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: Colors.grey,
                ),
                const SizedBox(width: 5),
                Text(formatDate(hw.dueDate)),
              ],
            ),

            if (hw.priority.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.flag,
                    size: 18,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 5),
                  Text("Priority: ${hw.priority}"),
                ],
              ),
            ],

            if (hw.attachmentUrl != null &&
                hw.attachmentUrl!.isNotEmpty) ...[
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Attachment opening will be added next.
                  },
                  icon: const Icon(Icons.attach_file),
                  label: const Text("View Attachment"),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget emptyHomework() {
    return Container(
      margin: const EdgeInsets.only(top: 40),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.menu_book_outlined,
            size: 55,
            color: Colors.grey,
          ),
          SizedBox(height: 15),
          Text(
            "No homework available",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 5),
          Text(
            "There is no homework for this student.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  String formatDate(String date) {
    if (date.isEmpty) return '';

    try {
      final parsed = DateTime.parse(date);

      return "${parsed.day.toString().padLeft(2, '0')} "
          "${monthName(parsed.month)} "
          "${parsed.year}";
    } catch (_) {
      return date;
    }
  }

  String monthName(int month) {
    const months = [
      '',
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

    return months[month];
  }
}