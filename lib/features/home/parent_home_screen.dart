import 'package:flutter/material.dart';

import 'package:parent_app/features/fees/fee_details_screen.dart';

import '../student/student_profile_screen.dart';
import '../attendance/attendance_screen.dart';
import '../homework/homework_screen.dart';
import '../timetable/timetable_screen.dart';
import '../results/results_screen.dart';
import '../notifications/notifications_screen.dart';
import '../transport/transport_screen.dart';
import '../achievements/achievements_screen.dart';
import '../chat/chat_screen.dart';
import '../profile/profile_screen.dart';

import '../../models/parent_response.dart';
import '../../models/student_response.dart';
import '../../models/student_fee_response.dart';

import '../../services/api_service.dart';
import '../../services/parent_service.dart';
import '../../services/fee_service.dart';
import '../../services/birthday_chat_service.dart';

import '../../features/mcq/mcq_tests_screen.dart';
import '../../features/birthday/birthday_wishes_screen.dart';
import '../../features/birthday/models/student_birthday_chat.dart';
import '../notices/notices_screen.dart';
import '../performance/performance_screen.dart';
import '../../features/results/exam_schedule_screen.dart';
import '../../features/feedback/parent_feedback_screen.dart';

class ParentHomeScreen extends StatefulWidget {
  const ParentHomeScreen({super.key});

  @override
  State<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {
  // ============================================================
  // THEME
  // ============================================================

  static const Color primary = Color(0xFF3155D9);
  static const Color primaryDark = Color(0xFF2343B8);
  static const Color background = Color(0xFFF6F8FC);
  static const Color textDark = Color(0xFF172033);
  static const Color textMuted = Color(0xFF697386);
  static const Color borderColor = Color(0xFFE5E9F0);

  ParentResponse? parent;
  StudentResponse? selectedStudent;

  List<StudentFeeResponse> pendingFees = [];
  List<StudentBirthdayChat> birthdayStudents = [];

  bool isLoadingStudent = true;
  bool isLoadingFees = false;
  bool isLoadingBirthday = false;

  @override
  void initState() {
    super.initState();
    _loadParentProfile();
  }

  // ============================================================
  // COMMON HELPERS
  // ============================================================

  String get _greeting {
    final hour = DateTime.now().hour;

    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));

    if (parts.isEmpty || parts.first.isEmpty) return '?';

    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String _formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  void _openPage(Widget page, String title) {
    debugPrint('📱 Opening: $title');

    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  // ============================================================
  // LOAD PARENT PROFILE
  // ============================================================

  Future<void> _loadParentProfile() async {
    try {
      final response = await ParentService.getMyParentProfile();

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = ApiService.decodeResponse(response);

        final loadedParent = ParentResponse.fromJson(
          data as Map<String, dynamic>,
        );

        setState(() {
          parent = loadedParent;
          selectedStudent = loadedParent.students.isNotEmpty
              ? loadedParent.students.first
              : null;
          isLoadingStudent = false;
        });

        if (selectedStudent != null) {
          await _loadPendingFees();
        }

        await _loadBirthdayStatus();
      } else {
        setState(() {
          isLoadingStudent = false;
        });

        debugPrint('Parent profile failed: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      debugPrint('Parent profile exception: $e');
      debugPrint('$stackTrace');

      if (!mounted) return;

      setState(() {
        isLoadingStudent = false;
      });
    }
  }

  // ============================================================
  // REFRESH DASHBOARD
  // ============================================================

  Future<void> _refreshDashboard() async {
    await _loadParentProfile();
  }

  // ============================================================
  // SELECT STUDENT
  // ============================================================

  Future<void> _selectStudent(StudentResponse student) async {
    if (selectedStudent?.id == student.id) return;

    setState(() {
      selectedStudent = student;
      pendingFees = [];
      isLoadingFees = true;
    });

    await _loadPendingFees();
  }

  // ============================================================
  // LOAD PENDING FEES
  // ============================================================

  Future<void> _loadPendingFees() async {
    final student = selectedStudent;

    if (student == null) {
      if (!mounted) return;

      setState(() {
        pendingFees = [];
        isLoadingFees = false;
      });

      return;
    }

    if (mounted) {
      setState(() {
        isLoadingFees = true;
      });
    }

    try {
      final response = await FeeService.getStudentFees(
        student.id,
        pending: true,
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = ApiService.decodeResponse(response);

        final fees = (data as List<dynamic>)
            .map(
              (item) =>
                  StudentFeeResponse.fromJson(item as Map<String, dynamic>),
            )
            .toList();

        // Ignore an older request if the selected child changed.
        if (selectedStudent?.id != student.id) return;

        setState(() {
          pendingFees = fees;
          isLoadingFees = false;
        });
      } else {
        setState(() {
          pendingFees = [];
          isLoadingFees = false;
        });

        debugPrint('Fee API failed: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      debugPrint('Pending fees exception: $e');
      debugPrint('$stackTrace');

      if (!mounted) return;

      setState(() {
        pendingFees = [];
        isLoadingFees = false;
      });
    }
  }

  // ============================================================
  // LOAD BIRTHDAYS
  // ============================================================

  Future<void> _loadBirthdayStatus() async {
    if (mounted) {
      setState(() {
        isLoadingBirthday = true;
      });
    }

    try {
      final response = await BirthdayChatService.getBirthdayChat();

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = ApiService.decodeResponse(response);

        final birthdays = data is List
            ? data
                  .map(
                    (item) => StudentBirthdayChat.fromJson(
                      item as Map<String, dynamic>,
                    ),
                  )
                  .where((birthday) => birthday.birthdayToday)
                  .toList()
            : <StudentBirthdayChat>[];

        setState(() {
          birthdayStudents = birthdays;
          isLoadingBirthday = false;
        });
      } else {
        setState(() {
          birthdayStudents = [];
          isLoadingBirthday = false;
        });
      }
    } catch (e) {
      debugPrint('Birthday loading exception: $e');

      if (!mounted) return;

      setState(() {
        birthdayStudents = [];
        isLoadingBirthday = false;
      });
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
      body: RefreshIndicator(
        color: primary,
        onRefresh: _refreshDashboard,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: constraints.maxWidth > 900 ? 900 : constraints.maxWidth,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 22, 18, 32),
                  children: [
                    _buildWelcomeHeader(),

                    const SizedBox(height: 22),

                    if (isLoadingStudent)
                      _buildStudentLoading()
                    else if (selectedStudent != null)
                      _buildSelectedStudentCard()
                    else
                      _buildNoStudentCard(),

                    const SizedBox(height: 20),

                    _buildFeeReminder(),

                    const SizedBox(height: 26),

                    _buildBirthdaySection(),

                    if (!isLoadingBirthday && birthdayStudents.isNotEmpty)
                      const SizedBox(height: 26),

                    _buildSectionHeading(
                      'Quick Access',
                      'Everything your child needs',
                      Icons.grid_view_rounded,
                    ),

                    const SizedBox(height: 15),

                    if (selectedStudent != null)
                      _buildQuickAccessGrid()
                    else
                      _buildNoStudentQuickAccess(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // APP BAR
  // ============================================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 1,
      titleSpacing: 12,
      leadingWidth: 64,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: GestureDetector(
          onTap: () => _openPage(const ProfileScreen(), 'Parent Profile'),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [primary, primaryDark]),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.school_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
        ),
      ),
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Smart School',
            style: TextStyle(
              color: textDark,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
          SizedBox(height: 2),
          Text(
            'Parent Portal',
            style: TextStyle(
              color: textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: IconButton(
            tooltip: 'Notifications',
            onPressed: () =>
                _openPage(const NotificationsScreen(), 'Notifications'),
            icon: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F5FC),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: primary,
                size: 23,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () => _openPage(const ProfileScreen(), 'Parent Profile'),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFFE7EDFF),
              child: Text(
                _initials(parent?.fatherName ?? 'Parent'),
                style: const TextStyle(
                  color: primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // WELCOME HEADER
  // ============================================================

  Widget _buildWelcomeHeader() {
    final parentName = parent?.fatherName?.trim() ?? '';
    final displayName = parentName.isEmpty ? 'Parent' : parentName;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$_greeting 👋',
                style: const TextStyle(
                  color: textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                displayName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: textDark,
                  fontSize: 25,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.7,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Stay connected with your child's school.",
                style: TextStyle(color: textMuted, fontSize: 12, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF0FF),
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Icon(
            Icons.waving_hand_rounded,
            size: 30,
            color: primary,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SECTION HEADING
  // ============================================================

  Widget _buildSectionHeading(String title, String subtitle, IconData icon) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF0FF),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: primary, size: 21),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: textDark,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(color: textMuted, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // LOADING / EMPTY STUDENT
  // ============================================================

  Widget _buildStudentLoading() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: _cardDecoration(),
      child: const Center(child: CircularProgressIndicator(color: primary)),
    );
  }

  Widget _buildNoStudentCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: const Row(
        children: [
          Icon(Icons.person_off_rounded, color: textMuted, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'No students are linked to this parent account.',
              style: TextStyle(color: textDark, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SELECTED STUDENT CARD
  // ============================================================

  Widget _buildSelectedStudentCard() {
    final students = parent?.students ?? [];
    final student = selectedStudent;

    if (student == null) return _buildNoStudentCard();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Top gradient header.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(17, 17, 17, 18),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primary, primaryDark],
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.school_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 9),
                const Expanded(
                  child: Text(
                    'STUDENT OVERVIEW',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                if (students.length > 1)
                  InkWell(
                    onTap: _showStudentSelector,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.25),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.swap_horiz_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Switch',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(17),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 66,
                      height: 66,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF0FF),
                        borderRadius: BorderRadius.circular(21),
                      ),
                      child: Center(
                        child: Text(
                          _initials(student.name),
                          style: const TextStyle(
                            color: primary,
                            fontSize: 21,
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
                            student.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: textDark,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            [
                                  if (student.className != null)
                                    student.className!,
                                  if (student.sectionName != null)
                                    'Section ${student.sectionName!}',
                                ].join(' • ').isEmpty
                                ? 'Student'
                                : [
                                    if (student.className != null)
                                      student.className!,
                                    if (student.sectionName != null)
                                      'Section ${student.sectionName!}',
                                  ].join(' • '),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F7EF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.verified_rounded,
                        color: Color(0xFF209764),
                        size: 20,
                      ),
                    ),
                  ],
                ),

                if (student.admissionNo != null &&
                    student.admissionNo!.trim().isNotEmpty) ...[
                  const SizedBox(height: 17),
                  const Divider(height: 1, color: borderColor),
                  const SizedBox(height: 13),
                  Row(
                    children: [
                      const Icon(
                        Icons.badge_outlined,
                        size: 17,
                        color: textMuted,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Admission Number',
                        style: TextStyle(color: textMuted, fontSize: 12),
                      ),
                      const Spacer(),
                      Flexible(
                        child: Text(
                          student.admissionNo!,
                          textAlign: TextAlign.end,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: textDark,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 16),

                // SizedBox(
                //   width: double.infinity,
                //   height: 46,
                //   child: OutlinedButton.icon(
                //     onPressed: () => _openPage(
                //       const StudentProfileScreen(),
                //       'Student Profile',
                //     ),
                //     icon: const Icon(Icons.person_outline_rounded, size: 19),
                //     label: const Text('View Student Profile'),
                //     style: OutlinedButton.styleFrom(
                //       foregroundColor: primary,
                //       side: const BorderSide(color: Color(0xFFD9E2FF)),
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(14),
                //       ),
                //       textStyle: const TextStyle(
                //         fontWeight: FontWeight.w700,
                //         fontSize: 13,
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STUDENT SELECTOR BOTTOM SHEET
  // ============================================================

  void _showStudentSelector() {
    final students = parent?.students ?? [];

    if (students.length <= 1) return;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.75,
                ),
                decoration: const BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4DAE5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF0FF),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.people_alt_rounded,
                              color: primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 13),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Choose Student',
                                  style: TextStyle(
                                    color: textDark,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Select a child to view their details',
                                  style: TextStyle(
                                    color: textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.close_rounded,
                              color: textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                        itemCount: students.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final student = students[index];
                          final isSelected = selectedStudent?.id == student.id;

                          final classDetails = [
                            if (student.className != null) student.className!,
                            if (student.sectionName != null)
                              'Section ${student.sectionName!}',
                          ].join(' • ');

                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(19),
                              onTap: () async {
                                setSheetState(() {});
                                Navigator.pop(context);
                                await _selectStudent(student);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFFEDF1FF)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(19),
                                  border: Border.all(
                                    color: isSelected ? primary : borderColor,
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 53,
                                      height: 53,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? primary
                                            : const Color(0xFFEAF0FF),
                                        borderRadius: BorderRadius.circular(17),
                                      ),
                                      child: Center(
                                        child: Text(
                                          _initials(student.name),
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.white
                                                : primary,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 17,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 13),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            student.name,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: textDark,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 14,
                                            ),
                                          ),
                                          if (classDetails.isNotEmpty) ...[
                                            const SizedBox(height: 5),
                                            Text(
                                              classDetails,
                                              style: const TextStyle(
                                                color: textMuted,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                          if (student.admissionNo != null &&
                                              student.admissionNo!
                                                  .trim()
                                                  .isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              'Admission: ${student.admissionNo}',
                                              style: const TextStyle(
                                                color: textMuted,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      isSelected
                                          ? Icons.check_circle_rounded
                                          : Icons.circle_outlined,
                                      color: isSelected
                                          ? primary
                                          : const Color(0xFFB6BECC),
                                      size: 23,
                                    ),
                                  ],
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
      },
    );
  }

  // ============================================================
  // PENDING FEE CARD
  // ============================================================

  Widget _buildFeeReminder() {
    final student = selectedStudent;

    if (student == null) return const SizedBox.shrink();

    if (isLoadingFees) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: _cardDecoration(),
        child: const Row(
          children: [
            SizedBox(
              width: 21,
              height: 21,
              child: CircularProgressIndicator(
                strokeWidth: 2.3,
                color: primary,
              ),
            ),
            SizedBox(width: 13),
            Expanded(
              child: Text(
                'Loading fee details...',
                style: TextStyle(color: textMuted, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      );
    }

    if (pendingFees.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(21),
          border: Border.all(color: const Color(0xFFD7F0E2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.025),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F7EF),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const constIconPlaceholder(),
            ),
            const SizedBox(width: 13),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'All Caught Up!',
                    style: TextStyle(
                      color: textDark,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'No pending fees for your child.',
                    style: TextStyle(color: textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF209764),
              size: 23,
            ),
          ],
        ),
      );
    }

    final totalPending = pendingFees.fold<double>(
      0,
      (sum, fee) => sum + fee.pendingAmount,
    );

    final dueDates =
        pendingFees
            .where((fee) => fee.dueDate != null)
            .map((fee) => fee.dueDate!)
            .toList()
          ..sort();

    final nearestDueDate = dueDates.isNotEmpty ? dueDates.first : null;

    final dueDateText = nearestDueDate != null
        ? 'Due on ${_formatDate(nearestDueDate)}'
        : 'Due date not available';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFFE3D6)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEF6C35).withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            height: 4,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFB36B), Color(0xFFEF6C35)],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(17),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 340;

                final icon = Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0E7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: Color(0xFFE76B32),
                    size: 24,
                  ),
                );

                final feeDetails = Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pending Fee',
                        style: TextStyle(
                          color: textDark,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _formatCurrency(totalPending),
                          style: const TextStyle(
                            color: Color(0xFFDE5D28),
                            fontSize: 23,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_month_rounded,
                            size: 14,
                            color: textMuted,
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              dueDateText,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );

                final payButton = SizedBox(
                  height: 45,
                  child: ElevatedButton.icon(
                    onPressed: () => _openPage(
                      FeeDetailsScreen(student: student),
                      'Fee Details',
                    ),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 17),
                    label: const Text('View Fees'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDE5D28),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                );

                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [icon, const SizedBox(width: 12), feeDetails],
                      ),
                      const SizedBox(height: 15),
                      SizedBox(width: double.infinity, child: payButton),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    icon,
                    const SizedBox(width: 13),
                    feeDetails,
                    const SizedBox(width: 10),
                    payButton,
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BIRTHDAY SECTION
  // ============================================================

  Widget _buildBirthdaySection() {
    if (isLoadingBirthday || birthdayStudents.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeading(
          "Today's Birthdays",
          'Send your wishes to the students',
          Icons.cake_rounded,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 142,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: birthdayStudents.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final birthday = birthdayStudents[index];

              return InkWell(
                onTap: () => _openPage(
                  BirthdayWishesScreen(studentId: birthday.studentId),
                  'Birthday Wishes',
                ),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 112,
                  padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor),
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
                      Container(
                        width: 65,
                        height: 65,
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFFFFA94D),
                              Color(0xFFEC4899),
                              Color(0xFF8B5CF6),
                            ],
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child:
                                birthday.photoUrl != null &&
                                    birthday.photoUrl!.trim().isNotEmpty
                                ? Image.network(
                                    birthday.photoUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _birthdayInitial(birthday.studentName),
                                  )
                                : _birthdayInitial(birthday.studentName),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        birthday.studentName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: textDark,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        '🎂 Birthday',
                        style: TextStyle(color: textMuted, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _birthdayInitial(String name) {
    return Container(
      color: const Color(0xFFFFF0F6),
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(
          color: Color(0xFFB83280),
          fontSize: 25,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  // ============================================================
  // QUICK ACCESS GRID
  // ============================================================

  Widget _buildQuickAccessGrid() {
    final student = selectedStudent!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 650
            ? 4
            : constraints.maxWidth < 340
            ? 2
            : 3;

        final items = <_QuickAccessItem>[
          _QuickAccessItem(
            title: 'Notices',
            subtitle: 'School updates',
            icon: Icons.campaign_rounded,
            color: const Color(0xFF3155D9),
            background: const Color(0xFFEAF0FF),
            page: NoticesScreen(
              classId: student.classId!,
              sectionId: student.sectionId!,
            ),
          ),
          _QuickAccessItem(
            title: 'Attendance',
            subtitle: 'Daily attendance',
            icon: Icons.fact_check_rounded,
            color: const Color(0xFF15966B),
            background: const Color(0xFFE7F7EF),
            page: AttendanceScreen(student: student),
          ),
          _QuickAccessItem(
            title: 'Homework',
            subtitle: 'Assignments',
            icon: Icons.menu_book_rounded,
            color: const Color(0xFF7C4DCE),
            background: const Color(0xFFF1EAFE),
            page: HomeworkScreen(
              classId: student.classId!,
              sectionId: student.sectionId!,
            ),
          ),
          _QuickAccessItem(
            title: 'Timetable',
            subtitle: 'Class schedule',
            icon: Icons.calendar_month_rounded,
            color: const Color(0xFFDB8B19),
            background: const Color(0xFFFFF3DF),
            page: TimetableScreen(studentId: student.id),
          ),
          _QuickAccessItem(
            title: 'Results',
            subtitle: 'Exam results',
            icon: Icons.bar_chart_rounded,
            color: const Color(0xFF1686B8),
            background: const Color(0xFFE5F5FC),
            page: ResultsScreen(student: student),
          ),
          _QuickAccessItem(
            title: 'Performance',
            subtitle: 'Test performance',
            icon: Icons.bar_chart_rounded,
            color: const Color(0xFF3155D9),
            background: const Color(0xFFEFF2FF),
            page: PerformanceScreen(student: student),
          ),
          _QuickAccessItem(
            title: 'Complaints\n''&\n''Suggestions',
            subtitle: 'Share your feedback',
            icon: Icons.feedback_outlined,
            color: const Color(0xFF7B61A8),
            background: const Color(0xFFF1EBFA),
            page: ParentFeedbackScreen(student: student),
          ),
          _QuickAccessItem(
            title: 'MCQ Tests',
            subtitle: 'Practice tests',
            icon: Icons.quiz_rounded,
            color: const Color(0xFFCF4D88),
            background: const Color(0xFFFFEAF3),
            page: McqTestsScreen(student: student),
          ),
          _QuickAccessItem(
            title: 'Exam Schedule',
            subtitle: 'Exam dates & timings',
            icon: Icons.event_note_rounded,
            color: const Color(0xFF2789A7),
            background: const Color(0xFFE5F6FA),
            page: ExamScheduleScreen(student: student),
          ),
        ];

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 142,
          ),
          itemBuilder: (context, index) {
            return _buildQuickAccessItem(items[index]);
          },
        );
      },
    );
  }

  Widget _buildQuickAccessItem(_QuickAccessItem item) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () => _openPage(item.page, item.title),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
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
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: item.background,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(item.icon, color: item.color, size: 23),
              ),
              const Spacer(),
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: textDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: textMuted, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoStudentQuickAccess() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: const Text(
        'Quick Access will be available after a student is linked to your account.',
        style: TextStyle(color: textMuted, fontSize: 13, height: 1.5),
      ),
    );
  }

  // ============================================================
  // COMMON CARD DECORATION
  // ============================================================

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(21),
      border: Border.all(color: borderColor),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.025),
          blurRadius: 16,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }
}

// ============================================================
// QUICK ACCESS MODEL
// ============================================================

class _QuickAccessItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color background;
  final Widget page;

  const _QuickAccessItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.background,
    required this.page,
  });
}

// Small icon widget used by the no-pending-fees card.
class constIconPlaceholder extends StatelessWidget {
  const constIconPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.check_circle_rounded,
      color: Color(0xFF209764),
      size: 25,
    );
  }
}
