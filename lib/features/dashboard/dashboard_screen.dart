import 'package:flutter/material.dart';

import 'package:parent_app/features/mcq/daily_test_screen.dart';
import 'package:parent_app/models/mcq_test.dart';
import 'package:parent_app/widgets/mcq/daily_test_card.dart';
import 'package:parent_app/models/parent_response.dart';
import 'package:parent_app/models/student_response.dart';
import 'package:parent_app/services/api_service.dart';
import 'package:parent_app/services/parent_service.dart';

import '../attendance/attendance_screen.dart';
import '../../features/results/results_screen.dart';
import '../../features/fees/fee_details_screen.dart';
import '../../features/notices/notices_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // ===========================================================================
  // COLORS
  // ===========================================================================

  static const Color primary = Color(0xFF3155D9);
  static const Color primaryDark = Color(0xFF2343B8);
  static const Color background = Color(0xFFF5F7FB);

  static const Color textDark = Color(0xFF172033);
  static const Color textMuted = Color(0xFF697386);
  static const Color border = Color(0xFFE5E9F0);

  // ===========================================================================
  // DATA
  // ===========================================================================

  ParentResponse? parent;
  StudentResponse? selectedStudent;

  bool isLoading = true;
  String? errorMessage;

  // ===========================================================================
  // INIT
  // ===========================================================================

  @override
  void initState() {
    super.initState();

    debugPrint('🏠 DashboardScreen: initState');

    _loadParentProfile();
  }

  // ===========================================================================
  // LOAD PARENT
  // ===========================================================================

  Future<void> _loadParentProfile() async {
    debugPrint('👨‍👩‍👧 Dashboard: Loading parent profile...');

    try {
      if (mounted) {
        setState(() {
          isLoading = true;
          errorMessage = null;
        });
      }

      final response = await ParentService.getMyParentProfile();

      debugPrint(
        '📥 Dashboard: Parent profile status = ${response.statusCode}',
      );

      if (!mounted) {
        return;
      }

      if (response.statusCode == 200) {
        final data = ApiService.decodeResponse(response);

        final parentData = ParentResponse.fromJson(
          data as Map<String, dynamic>,
        );

        debugPrint(
          '👨‍👩‍👧 Parent loaded = ${_parentDisplayName(parentData)}',
        );

        debugPrint(
          '👨‍👩‍👧 Children count = ${parentData.students.length}',
        );

        setState(() {
          parent = parentData;

          if (parentData.students.isNotEmpty) {
            if (selectedStudent != null) {
              final existing = parentData.students.where(
                (student) => student.id == selectedStudent!.id,
              );

              selectedStudent = existing.isNotEmpty
                  ? existing.first
                  : parentData.students.first;
            } else {
              selectedStudent = parentData.students.first;
            }
          } else {
            selectedStudent = null;
          }

          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage =
              'Failed to load parent profile (${response.statusCode})';
        });
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Dashboard exception: $e');
      debugPrint('📍 StackTrace: $stackTrace');

      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Something went wrong while loading profile.';
      });
    }
  }

  // ===========================================================================
  // SELECT STUDENT
  // ===========================================================================

  void _selectStudent(StudentResponse student) {
    debugPrint(
      '👆 Dashboard: Student selected -> '
      '${student.name} (ID: ${student.id})',
    );

    setState(() {
      selectedStudent = student;
    });
  }

  // ===========================================================================
  // STUDENT SELECTOR
  // ===========================================================================

  Future<void> _openStudentSelector() async {
    final students = parent?.students ?? [];

    if (students.isEmpty) {
      return;
    }

    final selected = await showModalBottomSheet<StudentResponse>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _PremiumStudentSelectorSheet(
          students: students,
          selectedStudent: selectedStudent,
        );
      },
    );

    if (selected != null && mounted) {
      _selectStudent(selected);
    }
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _loadingScreen();
    }

    if (errorMessage != null) {
      return _errorScreen();
    }

    if (parent == null) {
      return const Scaffold(
        backgroundColor: background,
        body: Center(
          child: Text(
            'Parent information unavailable',
            style: TextStyle(
              color: textDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    final parentData = parent!;

    return Scaffold(
      backgroundColor: background,
      appBar: _buildAppBar(parentData),
      body: RefreshIndicator(
        color: primary,
        backgroundColor: Colors.white,
        onRefresh: _loadParentProfile,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 36),
          children: [
            _welcomeHeader(parentData),

            const SizedBox(height: 18),

            _schoolBanner(),

            const SizedBox(height: 18),

            _selectedStudentCard(),

            const SizedBox(height: 18),

            _feeReminderCard(),

            const SizedBox(height: 22),

            _dailyTestSection(),

            const SizedBox(height: 25),

            _sectionHeader(
              title: 'My Children',
              subtitle: 'Switch between children anytime',
              icon: Icons.people_alt_rounded,
            ),

            const SizedBox(height: 12),

            if (parentData.students.isEmpty)
              _emptyChildren()
            else
              ...parentData.students.asMap().entries.map((entry) {
                final index = entry.key;
                final student = entry.value;

                return Padding(
                  padding: EdgeInsets.only(
                    bottom:
                        index == parentData.students.length - 1 ? 0 : 10,
                  ),
                  child: GestureDetector(
                    onTap: () => _selectStudent(student),
                    child: _studentCard(student, index),
                  ),
                );
              }),

            const SizedBox(height: 26),

            _sectionHeader(
              title: 'Quick Access',
              subtitle: 'Everything you need in one place',
              icon: Icons.grid_view_rounded,
            ),

            const SizedBox(height: 13),

            _quickActionsGrid(),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // APP BAR
  // ===========================================================================

  PreferredSizeWidget _buildAppBar(ParentResponse parentData) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: background,
      surfaceTintColor: background,
      automaticallyImplyLeading: false,
      titleSpacing: 16,
      title: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primary,
                  primaryDark,
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: primary.withOpacity(.18),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.school_rounded,
              color: Colors.white,
              size: 23,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Smart School',
                  style: TextStyle(
                    color: textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _parentDisplayName(parentData),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 14),
          child: Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.035),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  onPressed: () {
                    debugPrint(
                      '🔔 Dashboard: Notification clicked',
                    );
                  },
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: textDark,
                    size: 22,
                  ),
                ),

                Positioned(
                  right: 6,
                  top: 5,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // WELCOME
  // ===========================================================================

  Widget _welcomeHeader(ParentResponse parentData) {
    final firstName = _parentDisplayName(parentData)
        .trim()
        .split(' ')
        .first;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good Morning, $firstName 👋',
                style: const TextStyle(
                  color: textDark,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.4,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Stay connected with your child\'s school journey.',
                style: TextStyle(
                  color: textMuted,
                  fontSize: 11.5,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // SCHOOL BANNER
  // ===========================================================================

  Widget _schoolBanner() {
    return Container(
      height: 164,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primary,
            primaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(.20),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned(
              right: -25,
              top: -55,
              child: Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.07),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Positioned(
              right: 45,
              bottom: -75,
              child: Container(
                width: 145,
                height: 145,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.045),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Positioned(
              left: 20,
              bottom: -20,
              child: Icon(
                Icons.auto_stories_rounded,
                size: 100,
                color: Colors.white.withOpacity(.055),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(19),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.13),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withOpacity(.15),
                          ),
                        ),
                        child: const Icon(
                          Icons.school_rounded,
                          color: Colors.white,
                          size: 23,
                        ),
                      ),

                      const SizedBox(width: 11),

                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SCHOOL PORTAL',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 8.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Smart School',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'PARENT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            letterSpacing: .8,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  const Text(
                    'Learning Today, Leading Tomorrow',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    'Everything about your child, in one place.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // SELECTED STUDENT
  // ===========================================================================

  Widget _selectedStudentCard() {
    final students = parent?.students ?? [];
    final student = selectedStudent;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _premiumCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected Child',
                      style: TextStyle(
                        color: textDark,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Currently viewing this student',
                      style: TextStyle(
                        color: textMuted,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),

              if (students.length > 1)
                InkWell(
                  onTap: _openStudentSelector,
                  borderRadius: BorderRadius.circular(11),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF3FF),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.swap_horiz_rounded,
                          color: primary,
                          size: 15,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Switch',
                          style: TextStyle(
                            color: primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 13),

          if (student == null)
            _noSelectedStudent()
          else
            InkWell(
              onTap: students.length > 1
                  ? _openStudentSelector
                  : null,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xFFF6F8FF),
                      Color(0xFFFBFCFF),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFDDE4FA),
                  ),
                ),
                child: Row(
                  children: [
                    _premiumStudentAvatar(
                      student,
                      radius: 27,
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: textDark,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            _studentSubtitle(student),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: textMuted,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 7),

                          Row(
                            children: [
                              _studentTag(
                                Icons.badge_outlined,
                                student.admissionNo ?? '-',
                              ),
                              if (student.status != null) ...[
                                const SizedBox(width: 6),
                                _studentTag(
                                  Icons.verified_rounded,
                                  student.status!,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    if (students.length > 1)
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(color: border),
                        ),
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: textDark,
                          size: 21,
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

  Widget _noSelectedStudent() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFECACA),
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.person_off_rounded,
            color: Color(0xFFDC2626),
            size: 21,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'No student is linked to this parent account.',
              style: TextStyle(
                color: Color(0xFFB91C1C),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // FEE REMINDER
  // ===========================================================================

  Widget _feeReminderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: const Color(0xFFF1E1BF),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.035),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4DC),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: Color(0xFFEA8A00),
              size: 24,
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fee Status',
                  style: TextStyle(
                    color: textDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Check your child\'s pending school fees',
                  maxLines: 2,
                  style: TextStyle(
                    color: textMuted,
                    fontSize: 10.5,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Flexible(
            flex: 0,
            child: Container(
              constraints: const BoxConstraints(
                minWidth: 74,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8EA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFF7D99A),
                ),
              ),
              child: const Column(
                children: [
                  Text(
                    'PENDING',
                    style: TextStyle(
                      color: Color(0xFFB76A00),
                      fontSize: 7.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .6,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'View',
                    style: TextStyle(
                      color: Color(0xFFEA8A00),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          SizedBox(
            height: 42,
            child: ElevatedButton(
              onPressed: selectedStudent == null
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FeeDetailsScreen(
                            student: selectedStudent!,
                          ),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEA8A00),
                disabledBackgroundColor: const Color(0xFFE8E8E8),
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.grey,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              child: const Text(
                'View Fees',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // DAILY TEST
  // ===========================================================================

  Widget _dailyTestSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          title: 'Today\'s Learning',
          subtitle: 'Keep your child engaged with daily practice',
          icon: Icons.auto_awesome_rounded,
        ),

        const SizedBox(height: 12),

        DailyTestCard(
          test: McqTest.dummy(),
          onStartTest: () {
            debugPrint(
              '📝 Dashboard: Daily MCQ test clicked',
            );

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DailyTestScreen(
                  test: McqTest.dummy(),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ===========================================================================
  // MY CHILDREN
  // ===========================================================================

  Widget _studentCard(
    StudentResponse student,
    int index,
  ) {
    final isSelected = selectedStudent?.id == student.id;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: isSelected ? primary : border,
          width: isSelected ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? primary.withOpacity(.08)
                : Colors.black.withOpacity(.025),
            blurRadius: isSelected ? 18 : 13,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          _premiumStudentAvatar(
            student,
            radius: 26,
            index: index,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: textDark,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  _studentSubtitle(student),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: textMuted,
                    fontSize: 10.5,
                  ),
                ),

                const SizedBox(height: 7),

                _studentTag(
                  Icons.badge_outlined,
                  student.admissionNo ?? '-',
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isSelected
                  ? primary
                  : const Color(0xFFF5F6F9),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              isSelected
                  ? Icons.check_rounded
                  : Icons.chevron_right_rounded,
              color: isSelected ? Colors.white : textMuted,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // QUICK ACTIONS
  // ===========================================================================

  Widget _quickActionsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: .86,
      children: [
        _Quick(
          Icons.calendar_month_rounded,
          'Attendance',
          color: const Color(0xFF3155D9),
          onTap: selectedStudent == null
              ? null
              : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AttendanceScreen(
                        student: selectedStudent!,
                      ),
                    ),
                  );
                },
        ),

        _Quick(
          Icons.menu_book_rounded,
          'Homework',
          color: const Color(0xFF7C3AED),
          onTap: () {
            debugPrint('📚 Dashboard: Homework clicked');
          },
        ),

        _Quick(
          Icons.bar_chart_rounded,
          'Results',
          color: const Color(0xFF059669),
          onTap: selectedStudent == null
              ? null
              : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ResultsScreen(
                        student: selectedStudent!,
                      ),
                    ),
                  );
                },
        ),

        _Quick(
          Icons.currency_rupee_rounded,
          'Fees',
          color: const Color(0xFFEA8A00),
          onTap: selectedStudent == null
              ? null
              : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FeeDetailsScreen(
                        student: selectedStudent!,
                      ),
                    ),
                  );
                },
        ),

        _Quick(
          Icons.schedule_rounded,
          'Timetable',
          color: const Color(0xFF0891B2),
          onTap: () {
            debugPrint(
              '🕐 Dashboard: Timetable clicked',
            );
          },
        ),

        _Quick(
          Icons.event_rounded,
          'Events',
          color: const Color(0xFFDB2777),
          onTap: () {
            debugPrint(
              '📅 Dashboard: Events clicked',
            );
          },
        ),

        _Quick(
          Icons.notifications_rounded,
          'Notices',
          color: const Color(0xFFDC2626),
          onTap: selectedStudent == null
              ? null
              : () {
                  debugPrint(
                    '🔔 Dashboard: Notices clicked '
                    '(Class: ${selectedStudent!.classId}, '
                    'Section: ${selectedStudent!.sectionId})',
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NoticesScreen(
                        classId: selectedStudent!.classId,
                        sectionId: selectedStudent!.sectionId,
                      ),
                    ),
                  );
                },
        ),

        _Quick(
          Icons.person_rounded,
          'Profile',
          color: const Color(0xFF475569),
          onTap: () {
            debugPrint(
              '👤 Dashboard: Profile clicked',
            );
          },
        ),
      ],
    );
  }

  // ===========================================================================
  // HELPERS
  // ===========================================================================

  String _parentDisplayName(ParentResponse parent) {
    if (parent.fatherName != null &&
        parent.fatherName!.trim().isNotEmpty) {
      return parent.fatherName!;
    }

    if (parent.motherName != null &&
        parent.motherName!.trim().isNotEmpty) {
      return parent.motherName!;
    }

    if (parent.guardianName != null &&
        parent.guardianName!.trim().isNotEmpty) {
      return parent.guardianName!;
    }

    return 'Parent';
  }

  String _studentSubtitle(StudentResponse student) {
    final className = student.className?.trim() ?? '';
    final section = student.sectionName?.trim() ?? '';

    if (className.isNotEmpty && section.isNotEmpty) {
      return '$className • Section $section';
    }

    if (className.isNotEmpty) {
      return className;
    }

    if (section.isNotEmpty) {
      return 'Section $section';
    }

    return 'Class information unavailable';
  }

  Widget _premiumStudentAvatar(
    StudentResponse? student, {
    double radius = 25,
    int index = 0,
  }) {
    const colors = [
      Color(0xFF3155D9),
      Color(0xFF7C3AED),
      Color(0xFF059669),
      Color(0xFFEA8A00),
    ];

    final color = colors[index % colors.length];

    final name = student?.name.trim() ?? '';

    final initial = name.isNotEmpty
        ? name.substring(0, 1).toUpperCase()
        : '?';

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(.16),
            color.withOpacity(.07),
          ],
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withOpacity(.18),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: color,
            fontSize: radius * .70,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _studentTag(
    IconData icon,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F9),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 10,
            color: textMuted,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: textMuted,
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF3FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: primary,
            size: 19,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: textMuted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _emptyChildren() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _premiumCardDecoration(),
      child: const Column(
        children: [
          Icon(
            Icons.people_outline_rounded,
            color: textMuted,
            size: 35,
          ),
          SizedBox(height: 10),
          Text(
            'No children linked to this parent.',
            style: TextStyle(
              color: textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _premiumCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(21),
      border: Border.all(
        color: border,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(.035),
          blurRadius: 18,
          offset: const Offset(0, 7),
        ),
      ],
    );
  }

  Widget _loadingScreen() {
    return Scaffold(
      backgroundColor: background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    primary,
                    primaryDark,
                  ],
                ),
                borderRadius: BorderRadius.circular(21),
                boxShadow: [
                  BoxShadow(
                    color: primary.withOpacity(.18),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.school_rounded,
                color: Colors.white,
                size: 33,
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'Loading Dashboard',
              style: TextStyle(
                color: textDark,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 11),

            const SizedBox(
              width: 110,
              child: LinearProgressIndicator(
                minHeight: 3,
                color: primary,
                backgroundColor: Color(0xFFE5E9F0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorScreen() {
    return Scaffold(
      backgroundColor: background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: _premiumCardDecoration(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFEEEE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.cloud_off_rounded,
                    color: Color(0xFFDC2626),
                    size: 31,
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'Unable to load dashboard',
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
                  style: const TextStyle(
                    color: textMuted,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 18),

                ElevatedButton.icon(
                  onPressed: _loadParentProfile,
                  icon: const Icon(
                    Icons.refresh_rounded,
                    size: 18,
                  ),
                  label: const Text(
                    'Try Again',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
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
    );
  }
}

// ==============================================================================
// PREMIUM STUDENT SELECTOR
// ==============================================================================

class _PremiumStudentSelectorSheet extends StatelessWidget {
  final List<StudentResponse> students;
  final StudentResponse? selectedStudent;

  const _PremiumStudentSelectorSheet({
    required this.students,
    required this.selectedStudent,
  });

  static const Color primary = Color(0xFF3155D9);
  static const Color primaryDark = Color(0xFF2343B8);

  static const Color textDark = Color(0xFF172033);
  static const Color textMuted = Color(0xFF697386);
  static const Color border = Color(0xFFE5E9F0);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        constraints: const BoxConstraints(
          maxHeight: 680,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFFF7F9FC),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),

            Container(
              width: 42,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFD4D9E2),
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                20,
                16,
                16,
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          primary,
                          primaryDark,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.people_alt_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),

                  const SizedBox(width: 12),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Choose Student',
                          style: TextStyle(
                            color: textDark,
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Select the child you want to view',
                          style: TextStyle(
                            color: textMuted,
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                    ),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: textMuted,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  2,
                  16,
                  22,
                ),
                itemCount: students.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final student = students[index];

                  final isSelected =
                      selectedStudent?.id == student.id;

                  return _selectorStudentCard(
                    context,
                    student,
                    index,
                    isSelected,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _selectorStudentCard(
    BuildContext context,
    StudentResponse student,
    int index,
    bool isSelected,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(21),
      onTap: () {
        Navigator.pop(context, student);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFF0F4FF)
              : Colors.white,
          borderRadius: BorderRadius.circular(21),
          border: Border.all(
            color: isSelected ? primary : border,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? primary.withOpacity(.08)
                  : Colors.black.withOpacity(.025),
              blurRadius: isSelected ? 18 : 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            _avatar(student, index),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          student.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: textDark,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),

                      if (isSelected) ...[
                        const SizedBox(width: 7),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: primary,
                            borderRadius:
                                BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'SELECTED',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 7,
                              fontWeight: FontWeight.w900,
                              letterSpacing: .5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 5),

                  Text(
                    _subtitle(student),
                    style: const TextStyle(
                      color: textMuted,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 9),

                  Row(
                    children: [
                      _smallInfo(
                        Icons.badge_outlined,
                        student.admissionNo ?? '-',
                      ),

                      if (student.status != null) ...[
                        const SizedBox(width: 6),
                        _smallInfo(
                          Icons.verified_rounded,
                          student.status!,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isSelected
                    ? primary
                    : const Color(0xFFF5F6F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isSelected
                    ? Icons.check_rounded
                    : Icons.arrow_forward_ios_rounded,
                color:
                    isSelected ? Colors.white : textMuted,
                size: isSelected ? 20 : 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _subtitle(StudentResponse student) {
    final className = student.className?.trim() ?? '';
    final section = student.sectionName?.trim() ?? '';

    if (className.isNotEmpty && section.isNotEmpty) {
      return '$className • Section $section';
    }

    if (className.isNotEmpty) {
      return className;
    }

    if (section.isNotEmpty) {
      return 'Section $section';
    }

    return 'Class information unavailable';
  }

  static Widget _avatar(
    StudentResponse student,
    int index,
  ) {
    const colors = [
      Color(0xFF3155D9),
      Color(0xFF7C3AED),
      Color(0xFF059669),
      Color(0xFFEA8A00),
    ];

    final color = colors[index % colors.length];

    final name = student.name.trim();

    final initial = name.isNotEmpty
        ? name.substring(0, 1).toUpperCase()
        : '?';

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(.16),
            color.withOpacity(.07),
          ],
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withOpacity(.16),
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  static Widget _smallInfo(
    IconData icon,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F9),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 10,
            color: textMuted,
          ),
          const SizedBox(width: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: textMuted,
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ==============================================================================
// QUICK ACTION
// ==============================================================================

class _Quick extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback? onTap;

  const _Quick(
    this.icon,
    this.title, {
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: enabled ? 1 : .42,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 5,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFE5E9F0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.025),
                blurRadius: 13,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 41,
                height: 41,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withOpacity(.15),
                      color.withOpacity(.07),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 21,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF172033),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}