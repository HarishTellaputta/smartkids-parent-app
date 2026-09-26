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
import '../../features/mcq/daily_test_screen.dart';

import '../../models/parent_response.dart';
import '../../models/student_response.dart';
import '../../models/student_fee_response.dart';
import '../../services/api_service.dart';
import '../../features/mcq/mcq_tests_screen.dart';

class ParentHomeScreen extends StatefulWidget {
  const ParentHomeScreen({super.key});

  @override
  State<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {
  ParentResponse? parent;

  StudentResponse? selectedStudent;

  List<StudentFeeResponse> pendingFees = [];

  bool isLoadingStudent = true;
  bool isLoadingFees = false;

  List<dynamic> birthdayStudents = [];
  bool isLoadingBirthday = false;

  @override
  void initState() {
    super.initState();

    print('🏠 ParentHomeScreen: initState');

    _loadParentProfile();
  }

  // ============================================================
  // LOAD PARENT PROFILE
  // ============================================================

  Future<void> _loadParentProfile() async {
    print('👨‍👩‍👧 ParentHomeScreen: Loading parent profile...');

    try {
      final response = await ApiService.getMyParentProfile();

      print('👨‍👩‍👧 Parent profile response status: ${response.statusCode}');

      if (!mounted) {
        print('⚠️ ParentHomeScreen is no longer mounted');
        return;
      }

      if (response.statusCode == 200) {
        final data = ApiService.decodeResponse(response);

        print('📦 Parent profile response decoded');
        print('📦 Parent profile data: $data');

        final loadedParent = ParentResponse.fromJson(
          data as Map<String, dynamic>,
        );

        print(
          '👨‍👩‍👧 Parent loaded successfully: ${loadedParent.fatherName}',
        );

        print(
          '👨‍👩‍👧 Linked students count: ${loadedParent.students.length}',
        );

        for (final student in loadedParent.students) {
          print(
            '👨‍🎓 Student: '
            'id=${student.id}, '
            'name=${student.name}, '
            'class=${student.className}, '
            'section=${student.sectionName}',
          );
        }

        setState(() {
          parent = loadedParent;

          // Default ga first linked student
          selectedStudent = loadedParent.students.isNotEmpty
              ? loadedParent.students.first
              : null;

          isLoadingStudent = false;
        });

        if (selectedStudent != null) {
          print(
            '🎯 Default selected student: '
            '${selectedStudent!.name} '
            '(ID: ${selectedStudent!.id})',
          );
        } else {
          print('⚠️ No students linked to this parent');
        }

        // Default selected student ki fees load
        await _loadPendingFees();
        await _loadBirthdayStatus();
      } else {
        print(
          '❌ Parent profile failed. '
          'Status: ${response.statusCode}',
        );

        print('📦 Response body: ${response.body}');

        setState(() {
          isLoadingStudent = false;
        });
      }
    } catch (e, stackTrace) {
      print('❌ Parent profile exception: $e');
      print('📍 StackTrace: $stackTrace');

      if (!mounted) return;

      setState(() {
        isLoadingStudent = false;
      });
    }
  }

  // ============================================================
  // SELECT STUDENT
  // ============================================================

  Future<void> _selectStudent(StudentResponse student) async {
    print(
      '🔄 Student selection requested: '
      '${student.name} (ID: ${student.id})',
    );

    if (selectedStudent?.id == student.id) {
      print('ℹ️ Same student already selected');
      return;
    }

    setState(() {
      selectedStudent = student;
      pendingFees = [];
    });

    print(
      '🎯 Selected student changed to: '
      '${student.name} (ID: ${student.id})',
    );

    await _loadPendingFees();
  }

  // ============================================================
  // LOAD SELECTED STUDENT PENDING FEES
  // ============================================================

  Future<void> _loadPendingFees() async {
    if (selectedStudent == null) {
      print('⚠️ Cannot load fees: selectedStudent is null');

      if (!mounted) return;

      setState(() {
        pendingFees = [];
        isLoadingFees = false;
      });

      return;
    }

    print(
      '💰 Loading pending fees for student: '
      '${selectedStudent!.name} '
      '(ID: ${selectedStudent!.id})',
    );

    setState(() {
      isLoadingFees = true;
    });

    try {
      final response = await ApiService.getStudentFees(
        selectedStudent!.id,
        pending: true,
      );

      print(
        '💰 Fee API status for student ${selectedStudent!.id}: '
        '${response.statusCode}',
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = ApiService.decodeResponse(response);

        print('📦 Fee response data: $data');

        final fees = (data as List<dynamic>)
            .map(
              (item) =>
                  StudentFeeResponse.fromJson(item as Map<String, dynamic>),
            )
            .toList();

        print('💰 Pending fees loaded: ${fees.length}');

        setState(() {
          pendingFees = fees;
          isLoadingFees = false;
        });
      } else {
        print(
          '❌ Fee API failed. '
          'Status: ${response.statusCode}',
        );

        print('📦 Fee response body: ${response.body}');

        setState(() {
          pendingFees = [];
          isLoadingFees = false;
        });
      }
    } catch (e, stackTrace) {
      print('❌ Pending fee loading exception: $e');

      print('📍 StackTrace: $stackTrace');

      if (!mounted) return;

      setState(() {
        pendingFees = [];
        isLoadingFees = false;
      });
    }
  }

  // ============================================================
  // LOAD BIRTHDAY STATUS
  // ============================================================

  Future<void> _loadBirthdayStatus() async {
    if (selectedStudent == null) {
      print('🎂 Cannot load birthday status: selectedStudent is null');

      if (!mounted) return;

      setState(() {
        birthdayStudents = [];
        isLoadingBirthday = false;
      });

      return;
    }

    print(
      '🎂 Loading birthday status for student: '
      '${selectedStudent!.name} '
      '(ID: ${selectedStudent!.id})',
    );

    if (mounted) {
      setState(() {
        isLoadingBirthday = true;
      });
    }

    try {
      final response = await ApiService.getBirthdayChat();

      print('🎂 Birthday API status: ${response.statusCode}');

      print('🎂 Birthday API response: ${response.body}');

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = ApiService.decodeResponse(response);

        print('🎂 Birthday decoded data: $data');
        print('🎂 Birthday decoded type: ${data.runtimeType}');

        if (data is List) {
          print('🎂 Birthday students count: ${data.length}');

          setState(() {
            birthdayStudents = data;
            isLoadingBirthday = false;
          });
        } else {
          print('⚠️ Birthday response is not a List');

          setState(() {
            birthdayStudents = [];
            isLoadingBirthday = false;
          });
        }
      } else {
        print('❌ Birthday API failed: ${response.statusCode}');

        setState(() {
          birthdayStudents = [];
          isLoadingBirthday = false;
        });
      }
    } catch (e, stackTrace) {
      print('❌ Birthday loading exception: $e');
      print('📍 StackTrace: $stackTrace');

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
      backgroundColor: const Color(0xffF5F8FC),

      // ========================================================
      // APP BAR
      // ========================================================
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        leadingWidth: 70,

        leading: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: GestureDetector(
            onTap: () {
              print('👤 Opening parent profile');

              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            child: const CircleAvatar(radius: 22, child: Icon(Icons.person)),
          ),
        ),

        title: const Text(
          "Smart School",
          style: TextStyle(
            color: Color(0xFF1565C0),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: IconButton(
              onPressed: () {
                print('🔔 Opening notifications');

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationsScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.notifications, color: Colors.blue),
            ),
          ),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // ==================================================
            // SELECTED STUDENT
            // ==================================================
            if (isLoadingStudent)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (selectedStudent != null)
              _buildSelectedStudentCard(),

            const SizedBox(height: 20),

            // ==================================================
            // PENDING FEE
            // ==================================================
            _buildFeeReminder(),

            const SizedBox(height: 25),

            // ==================================================
            // QUICK ACCESS
            // ==================================================
            const Text(
              "Quick Access",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),

              crossAxisCount: 3,

              crossAxisSpacing: 12,
              mainAxisSpacing: 12,

              children: [
                menuItem(
                  context,
                  Icons.person,
                  "Profile",
                  const StudentProfileScreen(),
                ),

                menuItem(
                  context,
                  Icons.fact_check,
                  "Attendance",
                  selectedStudent == null
                      ? null
                      : AttendanceScreen(student: selectedStudent!),
                ),

                menuItem(
                  context,
                  Icons.book,
                  "Homework",
                  const HomeworkScreen(),
                ),

                menuItem(
                  context,
                  Icons.schedule,
                  "Timetable",
                  const TimetableScreen(),
                ),

                menuItem(
                  context,
                  Icons.grade,
                  "Results",
                  selectedStudent == null
                      ? null
                      : ResultsScreen(student: selectedStudent!),
                ),

                menuItem(
                  context,
                  Icons.directions_bus,
                  "Transport",
                  const TransportScreen(),
                ),

                menuItem(context, Icons.chat, "Chat", const ChatScreen()),

                menuItem(
                  context,
                  Icons.quiz,
                  "MCQ",
                  selectedStudent == null
                      ? null
                      : McqTestsScreen(student: selectedStudent!),
                ),

                menuItem(
                  context,
                  Icons.emoji_events,
                  "Achievements",
                  const AchievementsScreen(),
                ),
              ],
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SELECTED STUDENT CARD
  // ============================================================

  Widget _buildSelectedStudentCard() {
    final students = parent?.students ?? [];

    if (students.isEmpty) {
      print('⚠️ Selected student card: no students');

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),

        child: const Text(
          "No students linked to this parent.",
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            "Select Student",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 10),

          DropdownButtonFormField<int>(
            value: selectedStudent?.id,

            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.person, color: Colors.blue),

              filled: true,
              fillColor: Colors.blue.shade50,

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),

              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
            ),

            items: students.map((student) {
              return DropdownMenuItem<int>(
                value: student.id,

                child: Text(
                  "${student.name}"
                  "${student.className != null ? " • ${student.className}" : ""}"
                  "${student.sectionName != null ? " - ${student.sectionName}" : ""}",

                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),

            onChanged: (studentId) async {
              if (studentId == null) return;

              final student = students.firstWhere(
                (student) => student.id == studentId,
              );

              await _selectStudent(student);
            },
          ),

          const SizedBox(height: 15),

          // Selected student details
          Row(
            children: [
              const CircleAvatar(
                radius: 27,
                child: Icon(Icons.person, size: 30),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      selectedStudent!.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    if (selectedStudent!.className != null)
                      Text(
                        "${selectedStudent!.className}"
                        "${selectedStudent!.sectionName != null ? " - ${selectedStudent!.sectionName}" : ""}",

                        style: const TextStyle(color: Colors.grey),
                      ),

                    if (selectedStudent!.admissionNo != null)
                      Text(
                        "Admission No: ${selectedStudent!.admissionNo}",

                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
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
  // FEE REMINDER
  // ============================================================

  Widget _buildFeeReminder() {
    if (isLoadingFees) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),

        child: const Row(
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),

            SizedBox(width: 12),

            Text(
              "Loading fee details...",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (selectedStudent == null) {
      return const SizedBox.shrink();
    }

    // ----------------------------------------------------------
    // NO PENDING FEES
    // ----------------------------------------------------------

    if (pendingFees.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),

        child: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),

            SizedBox(width: 12),

            Expanded(
              child: Text(
                "No pending fees",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    }

    // ----------------------------------------------------------
    // CALCULATE TOTAL PENDING
    // ----------------------------------------------------------

    final totalPending = pendingFees.fold<double>(
      0,
      (sum, fee) => sum + fee.pendingAmount,
    );

    // ----------------------------------------------------------
    // FIND NEAREST DUE DATE
    // ----------------------------------------------------------

    final dueDates = pendingFees
        .where((fee) => fee.dueDate != null)
        .map((fee) => fee.dueDate!)
        .toList();

    DateTime? nearestDueDate;

    if (dueDates.isNotEmpty) {
      dueDates.sort();
      nearestDueDate = dueDates.first;
    }

    final formattedDueDate = nearestDueDate != null
        ? "${nearestDueDate.day.toString().padLeft(2, '0')}/"
              "${nearestDueDate.month.toString().padLeft(2, '0')}/"
              "${nearestDueDate.year}"
        : "Due date not available";

    // ----------------------------------------------------------
    // FEE CARD
    // ----------------------------------------------------------

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),

            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),

            child: const Icon(Icons.currency_rupee, color: Colors.red),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  "Pending Fee",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 5),

                Text(
                  "₹${totalPending.toStringAsFixed(2)}",

                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  "Due on $formattedDueDate",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          ElevatedButton(
            onPressed: selectedStudent == null
                ? null
                : () {
                    print(
                      '💳 Opening fee details for '
                      '${selectedStudent!.name} '
                      '(ID: ${selectedStudent!.id})',
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            FeeDetailsScreen(student: selectedStudent!),
                      ),
                    );
                  },

            child: const Text("Pay"),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // QUICK ACCESS ITEM
  // ============================================================

  Widget menuItem(
    BuildContext context,
    IconData icon,
    String title,
    Widget? page,
  ) {
    return InkWell(
      onTap: page == null
          ? null
          : () {
              print('📱 Opening Quick Access: $title');

              Navigator.push(context, MaterialPageRoute(builder: (_) => page));
            },

      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(
              icon,
              color: page == null ? Colors.grey : Colors.blue,
              size: 30,
            ),

            const SizedBox(height: 8),

            Text(
              title,
              textAlign: TextAlign.center,

              style: TextStyle(
                color: page == null ? Colors.grey : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
