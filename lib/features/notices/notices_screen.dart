import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../services/api_service.dart';
import 'package:parent_app/models/school_notice.dart';

class NoticesScreen extends StatefulWidget {
  final int? classId;
  final int? sectionId;

  const NoticesScreen({
    super.key,
    this.classId,
    this.sectionId,
  });

  @override
  State<NoticesScreen> createState() => _NoticesScreenState();
}

class _NoticesScreenState extends State<NoticesScreen> {
  List<SchoolNotice> notices = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadNotices();
  }

  Future<void> loadNotices() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await ApiService.getNotices(
        classId: widget.classId,
        sectionId: widget.sectionId,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          notices = data
              .map(
                (json) => SchoolNotice.fromJson(
                  json as Map<String, dynamic>,
                ),
              )
              .toList();

          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage =
              'Failed to load notices (${response.statusCode})';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Unable to load notices';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F8FC),
      appBar: AppBar(
        title: const Text("School Notices"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: loadNotices,
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : errorMessage != null
                ? _errorView()
                : notices.isEmpty
                    ? _emptyView()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: notices.length,
                        itemBuilder: (context, index) {
                          return noticeCard(notices[index]);
                        },
                      ),
      ),
    );
  }

  Widget noticeCard(SchoolNotice notice) {
    final Color priorityColor = getPriorityColor(
      notice.category,
    );

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor:
                      priorityColor.withOpacity(.15),
                  child: Icon(
                    Icons.campaign,
                    color: priorityColor,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    notice.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                if (notice.category.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: priorityColor.withOpacity(.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      notice.category,
                      style: TextStyle(
                        color: priorityColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 15),

            Text(
              notice.content,
              style: TextStyle(
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: Colors.grey,
                ),
                const SizedBox(width: 6),
                Text(
                  formatDate(
                    notice.publishedAt ?? notice.createdAt,
                  ),
                ),

                const Spacer(),

                if (notice.className.isNotEmpty)
                  Text(
                    "${notice.className}"
                    "${notice.sectionName.isNotEmpty ? " - ${notice.sectionName}" : ""}",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 14),

            if (notice.status.isNotEmpty)
              Row(
                children: [
                  Icon(
                    notice.status.toLowerCase() == 'published'
                        ? Icons.check_circle
                        : Icons.info_outline,
                    size: 17,
                    color:
                        notice.status.toLowerCase() == 'published'
                            ? Colors.green
                            : Colors.grey,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    notice.status,
                    style: TextStyle(
                      color:
                          notice.status.toLowerCase() ==
                                  'published'
                              ? Colors.green
                              : Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _emptyView() {
    return ListView(
      children: const [
        SizedBox(height: 160),
        Center(
          child: Column(
            children: [
              Icon(
                Icons.campaign_outlined,
                size: 60,
                color: Colors.grey,
              ),
              SizedBox(height: 15),
              Text(
                "No notices available",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 5),
              Text(
                "There are no school notices at the moment.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _errorView() {
    return ListView(
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
                onPressed: loadNotices,
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color getPriorityColor(String category) {
    switch (category.toLowerCase()) {
      case 'high':
        return Colors.red;

      case 'medium':
        return Colors.orange;

      case 'normal':
        return Colors.blue;

      case 'info':
        return Colors.green;

      default:
        return Colors.blue;
    }
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