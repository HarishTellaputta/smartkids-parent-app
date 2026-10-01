import 'package:flutter/material.dart';

import '../../../services/api_service.dart';
import '../../../services/homework_service.dart';
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
  static const Color primary = Color(0xFF3155D9);
  static const Color primaryDark = Color(0xFF2343B8);
  static const Color background = Color(0xFFF6F8FC);
  static const Color textDark = Color(0xFF172033);
  static const Color textMuted = Color(0xFF697386);
  static const Color border = Color(0xFFE5E9F0);

  List<Homework> homeworkList = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadHomework();
  }

  // ============================================================
  // LOAD HOMEWORK
  // ============================================================

  Future<void> loadHomework() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      debugPrint(
        '📚 Loading homework '
        'classId=${widget.classId}, '
        'sectionId=${widget.sectionId}',
      );

      final response = await HomeworkService.getStudentHomework(
        widget.classId,
        widget.sectionId,
      );

      debugPrint(
        '📚 Homework API status: ${response.statusCode}',
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = ApiService.decodeResponse(response);

        debugPrint('📦 Homework response: $data');

        if (data is List) {
          final homework = data
              .whereType<Map>()
              .map(
                (json) => Homework.fromJson(
                  Map<String, dynamic>.from(json),
                ),
              )
              .toList();

          setState(() {
            homeworkList = homework;
            isLoading = false;
          });
        } else {
          setState(() {
            homeworkList = [];
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage =
              'Failed to load homework (${response.statusCode})';
          isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Homework error: $e');
      debugPrint('📍 $stackTrace');

      if (!mounted) return;

      setState(() {
        errorMessage = 'Unable to load homework';
        isLoading = false;
      });
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final total = homeworkList.length;

    final pending = homeworkList.where((hw) {
      return hw.status.toLowerCase() == 'pending';
    }).length;

    final done = homeworkList.where((hw) {
      final status = hw.status.toLowerCase();

      return status == 'submitted' ||
          status == 'completed' ||
          status == 'done';
    }).length;

    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: textDark,
        elevation: 0,
        centerTitle: false,

        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Homework',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: textDark,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Track assignments and submissions',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: textMuted,
              ),
            ),
          ],
        ),

        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: isLoading ? null : loadHomework,
            icon: const Icon(
              Icons.refresh_rounded,
              color: primary,
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),

      body: RefreshIndicator(
        color: primary,
        onRefresh: loadHomework,

        child: isLoading
            ? _loadingView()
            : errorMessage != null
                ? _errorView()
                : ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      16,
                      16,
                      32,
                    ),
                    children: [
                      _headerCard(),

                      const SizedBox(height: 16),

                      _summarySection(
                        total: total,
                        pending: pending,
                        done: done,
                      ),

                      const SizedBox(height: 26),

                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Homework List',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: textDark,
                              ),
                            ),
                          ),
                          if (total > 0)
                            _countBadge('$total Tasks'),
                        ],
                      ),

                      const SizedBox(height: 14),

                      if (homeworkList.isEmpty)
                        _emptyHomework()
                      else
                        ...homeworkList.map(
                          (hw) => _homeworkCard(hw),
                        ),
                    ],
                  ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _headerCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryDark,
            primary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.20),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.14),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.20),
              ),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stay on top of homework',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'View assignments, due dates and submission status.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.35,
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
  // SUMMARY
  // ============================================================

  Widget _summarySection({
    required int total,
    required int pending,
    required int done,
  }) {
    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            title: 'Total',
            value: '$total',
            icon: Icons.assignment_rounded,
            color: primary,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _summaryCard(
            title: 'Pending',
            value: '$pending',
            icon: Icons.pending_actions_rounded,
            color: const Color(0xFFF59E0B),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _summaryCard(
            title: 'Done',
            value: '$done',
            icon: Icons.check_circle_rounded,
            color: const Color(0xFF16A34A),
          ),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 21,
            ),
          ),

          const SizedBox(height: 9),

          Text(
            value,
            style: const TextStyle(
              color: textDark,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            title,
            style: const TextStyle(
              color: textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HOMEWORK CARD
  // ============================================================

  Widget _homeworkCard(Homework hw) {
    final status = hw.status.toLowerCase();

    final bool isDone =
        status == 'submitted' ||
        status == 'completed' ||
        status == 'done';

    final bool isPending = status == 'pending';

    final Color statusColor = isDone
        ? const Color(0xFF16A34A)
        : isPending
            ? const Color(0xFFF59E0B)
            : const Color(0xFF64748B);

    final IconData statusIcon = isDone
        ? Icons.check_circle_rounded
        : isPending
            ? Icons.schedule_rounded
            : Icons.info_outline_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ======================================================
          // SUBJECT + STATUS
          // ======================================================

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.book_rounded,
                        size: 15,
                        color: primary,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          hw.subjectName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      statusIcon,
                      size: 14,
                      color: statusColor,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      hw.status.isEmpty
                          ? 'Unknown'
                          : hw.status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ======================================================
          // TITLE
          // ======================================================

          Text(
            hw.title,
            style: const TextStyle(
              color: textDark,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),

          const SizedBox(height: 8),

          // ======================================================
          // DESCRIPTION
          // ======================================================

          Text(
            hw.description,
            style: const TextStyle(
              color: textMuted,
              fontSize: 13,
              height: 1.45,
            ),
          ),

          const SizedBox(height: 16),

          Container(
            height: 1,
            color: border,
          ),

          const SizedBox(height: 14),

          // ======================================================
          // TEACHER
          // ======================================================

          _infoRow(
            icon: Icons.person_outline_rounded,
            label: 'Assigned by',
            value: hw.assignedByTeacherName,
          ),

          const SizedBox(height: 11),

          // ======================================================
          // DUE DATE
          // ======================================================

          _infoRow(
            icon: Icons.calendar_today_rounded,
            label: 'Due date',
            value: formatDate(hw.dueDate),
            valueColor: _isDueDateNear(hw.dueDate)
                ? const Color(0xFFDC2626)
                : textDark,
          ),

          // ======================================================
          // PRIORITY
          // ======================================================

          if (hw.priority.trim().isNotEmpty) ...[
            const SizedBox(height: 11),

            _infoRow(
              icon: Icons.flag_outlined,
              label: 'Priority',
              value: hw.priority,
            ),
          ],

          // ======================================================
          // ATTACHMENT
          // ======================================================

          if (hw.attachmentUrl != null &&
              hw.attachmentUrl!.trim().isNotEmpty) ...[
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // Attachment opening will be added next.
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: primary,
                  side: BorderSide(
                    color: primary.withOpacity(0.25),
                  ),
                  backgroundColor: primary.withOpacity(0.03),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(
                  Icons.attach_file_rounded,
                  size: 19,
                ),
                label: const Text(
                  'View Attachment',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 17,
            color: textMuted,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                value.isEmpty ? '-' : value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: valueColor ?? textDark,
                  fontSize: 13,
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
  // DUE DATE CHECK
  // ============================================================

  bool _isDueDateNear(String date) {
    if (date.isEmpty) return false;

    try {
      final dueDate = DateTime.parse(date);
      final today = DateTime.now();

      final due = DateTime(
        dueDate.year,
        dueDate.month,
        dueDate.day,
      );

      final current = DateTime(
        today.year,
        today.month,
        today.day,
      );

      final difference = due.difference(current).inDays;

      return difference <= 2 && difference >= 0;
    } catch (_) {
      return false;
    }
  }

  // ============================================================
  // COUNT BADGE
  // ============================================================

  Widget _countBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: primary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _emptyHomework() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 42,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.menu_book_outlined,
              size: 38,
              color: primary,
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'No homework available',
            style: TextStyle(
              color: textDark,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 7),

          const Text(
            'There is no homework assigned for this student.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textMuted,
              fontSize: 13,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 20),

          OutlinedButton.icon(
            onPressed: loadHomework,
            style: OutlinedButton.styleFrom(
              foregroundColor: primary,
              side: BorderSide(
                color: primary.withOpacity(0.25),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text(
              'Refresh',
              style: TextStyle(
                fontWeight: FontWeight.w700,
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

  Widget _loadingView() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        _loadingBox(
          height: 110,
          radius: 22,
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _loadingBox(
                height: 125,
                radius: 18,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _loadingBox(
                height: 125,
                radius: 18,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _loadingBox(
                height: 125,
                radius: 18,
              ),
            ),
          ],
        ),

        const SizedBox(height: 26),

        _loadingBox(
          height: 260,
          radius: 20,
        ),

        const SizedBox(height: 14),

        _loadingBox(
          height: 230,
          radius: 20,
        ),
      ],
    );
  }

  Widget _loadingBox({
    required double height,
    required double radius,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: border),
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.2,
            color: primary,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _errorView() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        const SizedBox(height: 120),

        Container(
          width: 82,
          height: 82,
          decoration: BoxDecoration(
            color: const Color(0xFFFEECEC),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.error_outline_rounded,
            size: 42,
            color: Color(0xFFDC2626),
          ),
        ),

        const SizedBox(height: 20),

        const Text(
          'Unable to load homework',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textDark,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          errorMessage ?? 'Something went wrong. Please try again.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: textMuted,
            fontSize: 13,
            height: 1.4,
          ),
        ),

        const SizedBox(height: 22),

        Center(
          child: ElevatedButton.icon(
            onPressed: loadHomework,
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(
              Icons.refresh_rounded,
              size: 19,
            ),
            label: const Text(
              'Try Again',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DATE
  // ============================================================

  String formatDate(String date) {
    if (date.isEmpty) return '-';

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

    if (month < 1 || month > 12) {
      return '';
    }

    return months[month];
  }
}