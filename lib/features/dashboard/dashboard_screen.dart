import 'package:flutter/material.dart';

import 'package:parent_app/features/mcq/daily_test_screen.dart';
import 'package:parent_app/models/mcq_test.dart';
import 'package:parent_app/widgets/mcq/daily_test_card.dart';
import 'package:parent_app/models/parent_response.dart';
import 'package:parent_app/models/student_response.dart';
import 'package:parent_app/services/api_service.dart';

import '../attendance/attendance_screen.dart';
import '../../features/results/results_screen.dart';
import '../../features/fees/fee_details_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  ParentResponse? parent;
  StudentResponse? selectedStudent;

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    debugPrint('🏠 DashboardScreen: initState');

    _loadParentProfile();
  }

  // ============================================================
  // LOAD PARENT + CHILDREN
  // ============================================================

  Future<void> _loadParentProfile() async {
    debugPrint('👨‍👩‍👧 Dashboard: Loading parent profile...');

    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      debugPrint('🌐 Dashboard: Calling getMyParentProfile()');

      final response = await ApiService.getMyParentProfile();

      debugPrint(
        '📥 Dashboard: Parent profile status = ${response.statusCode}',
      );

      debugPrint('📦 Dashboard: Parent profile response = ${response.body}');

      if (!mounted) {
        debugPrint('⚠️ Dashboard: Widget is no longer mounted');
        return;
      }

      if (response.statusCode == 200) {
        debugPrint('✅ Dashboard: Parent profile API successful');

        final data = ApiService.decodeResponse(response);

        debugPrint('📦 Dashboard: Decoded parent data = $data');

        final parentData = ParentResponse.fromJson(
          data as Map<String, dynamic>,
        );

        debugPrint(
          '👨‍👩‍👧 Dashboard: Parent loaded = ${_parentDisplayName(parentData)}',
        );

        debugPrint(
          '👨‍👩‍👧 Dashboard: Children count = ${parentData.students.length}',
        );

        for (final student in parentData.students) {
          debugPrint(
            '👨‍🎓 Student -> '
            'ID: ${student.id}, '
            'Name: ${student.name}, '
            'Class: ${student.className}, '
            'Section: ${student.sectionName}, '
            'Admission: ${student.admissionNo}',
          );
        }

        setState(() {
          parent = parentData;

          if (parentData.students.isNotEmpty) {
            selectedStudent = parentData.students.first;

            debugPrint(
              '🎯 Dashboard: Default student selected -> '
              '${selectedStudent!.name} '
              '(ID: ${selectedStudent!.id})',
            );
          } else {
            selectedStudent = null;

            debugPrint('⚠️ Dashboard: No students linked to this parent');
          }

          isLoading = false;
        });

        debugPrint('✅ Dashboard: Parent profile loading completed');
      } else {
        debugPrint(
          '❌ Dashboard: Parent profile API failed '
          'with status ${response.statusCode}',
        );

        setState(() {
          isLoading = false;
          errorMessage =
              'Failed to load parent profile (${response.statusCode})';
        });
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Dashboard: Parent profile exception');
      debugPrint('💥 Error: $e');
      debugPrint('📍 StackTrace: $stackTrace');

      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Something went wrong while loading profile.';
      });
    }
  }

  // ============================================================
  // SELECT CHILD
  // ============================================================

  void _selectStudent(StudentResponse student) {
    debugPrint(
      '👆 Dashboard: Student selected -> '
      '${student.name} (ID: ${student.id})',
    );

    debugPrint(
      '🎯 Dashboard: Previous student -> '
      '${selectedStudent?.name ?? "None"} '
      '(ID: ${selectedStudent?.id ?? "None"})',
    );

    setState(() {
      selectedStudent = student;
    });

    debugPrint(
      '✅ Dashboard: Current selected student -> '
      '${selectedStudent!.name} '
      '(ID: ${selectedStudent!.id})',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      debugPrint('⏳ Dashboard: Showing loading screen');

      return const Scaffold(
        backgroundColor: Color(0xffF5F8FC),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      debugPrint('⚠️ Dashboard: Showing error screen -> $errorMessage');

      return Scaffold(
        backgroundColor: const Color(0xffF5F8FC),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 50, color: Colors.red),

                const SizedBox(height: 15),

                Text(errorMessage!, textAlign: TextAlign.center),

                const SizedBox(height: 15),

                ElevatedButton(
                  onPressed: _loadParentProfile,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (parent == null) {
      debugPrint('⚠️ Dashboard: Parent object is null');

      return const Scaffold(
        body: Center(child: Text('Parent information unavailable')),
      );
    }

    final parentData = parent!;

    return Scaffold(
      backgroundColor: const Color(0xffF5F8FC),

      // ========================================================
      // APP BAR
      // ========================================================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Good Morning 👋",
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),

            Text(
              _parentDisplayName(parentData),
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: () {
                  debugPrint('🔔 Dashboard: Notification icon clicked');
                },
                icon: const Icon(Icons.notifications_none, color: Colors.black),
              ),

              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  height: 18,
                  width: 18,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      "3",
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================
      body: RefreshIndicator(
        onRefresh: () async {
          debugPrint('🔄 Dashboard: Pull-to-refresh triggered');

          await _loadParentProfile();
        },

        child: ListView(
          padding: const EdgeInsets.all(16),

          children: [
            // ==================================================
            // SCHOOL CARD
            // ==================================================

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xff1565C0), Color(0xff42A5F5)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),

              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "School",
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),

                  SizedBox(height: 4),

                  Text(
                    "School information will be connected next",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    "Learning Today, Leading Tomorrow",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // SELECTED CHILD
            // ==================================================
            _selectedStudentCard(),

            const SizedBox(height: 20),

            // ==================================================
            // FEE REMINDER
            // ==================================================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(16),
              ),

              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.orange,
                    child: Icon(Icons.currency_rupee, color: Colors.white),
                  ),

                  const SizedBox(width: 15),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Fee Reminder",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),

                        SizedBox(height: 4),

                        Text("Fee information will be loaded next"),
                      ],
                    ),
                  ),

                  ElevatedButton(
                    onPressed: () {
                      debugPrint('💰 Dashboard: Pay button clicked');

                      if (selectedStudent == null) {
                        debugPrint(
                          '⚠️ Dashboard: Cannot open fees - '
                          'no student selected',
                        );
                        return;
                      }

                      debugPrint(
                        '💰 Dashboard: Opening FeeDetailsScreen '
                        'for student ID ${selectedStudent!.id}',
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
            ),

            const SizedBox(height: 20),

            // ==================================================
            // DAILY MCQ TEST
            // ==================================================
            DailyTestCard(
              test: McqTest.dummy(),

              onStartTest: () {
                debugPrint('📝 Dashboard: Daily MCQ test clicked');

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        DailyTestScreen(test: McqTest.dummy()),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // ==================================================
            // MY CHILDREN
            // ==================================================
            const Text(
              "My Children",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            if (parentData.students.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),

                child: const Center(
                  child: Text("No children linked to this parent."),
                ),
              )
            else
              ...parentData.students.asMap().entries.map((entry) {
                final index = entry.key;
                final student = entry.value;

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == parentData.students.length - 1 ? 0 : 15,
                  ),

                  child: GestureDetector(
                    onTap: () {
                      debugPrint(
                        '👆 Dashboard: My Children card clicked '
                        'for ${student.name} (${student.id})',
                      );

                      _selectStudent(student);
                    },

                    child: _studentCard(student, index),
                  ),
                );
              }),

            const SizedBox(height: 20),

            // ==================================================
            // QUICK ACTIONS
            // ==================================================
            const Text(
              "Quick Actions",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),

              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,

              children: [
                _Quick(
                  Icons.calendar_today,
                  "Attendance",

                  onTap: selectedStudent == null
                      ? null
                      : () {
                          debugPrint(
                            '📅 Dashboard: Attendance clicked '
                            'for student ${selectedStudent!.id}',
                          );

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AttendanceScreen(student: selectedStudent!),
                            ),
                          );
                        },
                ),

                _Quick(
                  Icons.menu_book,
                  "Homework",

                  onTap: () {
                    debugPrint(
                      '📚 Dashboard: Homework clicked '
                      'for student ${selectedStudent?.id}',
                    );
                  },
                ),

                _Quick(
                  Icons.bar_chart,
                  "Results",

                  onTap: selectedStudent == null
                      ? null
                      : () {
                          debugPrint(
                            '📊 Dashboard: Results clicked '
                            'for student ${selectedStudent!.id}',
                          );

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ResultsScreen(student: selectedStudent!),
                            ),
                          );
                        },
                ),

                _Quick(
                  Icons.currency_rupee,
                  "Fees",

                  onTap: selectedStudent == null
                      ? null
                      : () {
                          debugPrint(
                            '💰 Dashboard: Fees clicked '
                            'for student ${selectedStudent!.id}',
                          );

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  FeeDetailsScreen(student: selectedStudent!),
                            ),
                          );
                        },
                ),

                _Quick(
                  Icons.schedule,
                  "Timetable",

                  onTap: () {
                    debugPrint(
                      '🕐 Dashboard: Timetable clicked '
                      'for student ${selectedStudent?.id}',
                    );
                  },
                ),

                _Quick(
                  Icons.event,
                  "Events",

                  onTap: () {
                    debugPrint('📅 Dashboard: Events clicked');
                  },
                ),

                _Quick(
                  Icons.notifications,
                  "Notices",

                  onTap: () {
                    debugPrint('🔔 Dashboard: Notices clicked');
                  },
                ),

                _Quick(
                  Icons.person,
                  "Profile",

                  onTap: () {
                    debugPrint(
                      '👤 Dashboard: Profile clicked '
                      'for student ${selectedStudent?.id}',
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PARENT NAME
  // ============================================================

  String _parentDisplayName(ParentResponse parent) {
    if (parent.fatherName != null && parent.fatherName!.trim().isNotEmpty) {
      return parent.fatherName!;
    }

    if (parent.motherName != null && parent.motherName!.trim().isNotEmpty) {
      return parent.motherName!;
    }

    if (parent.guardianName != null && parent.guardianName!.trim().isNotEmpty) {
      return parent.guardianName!;
    }

    return "Parent";
  }

  // ============================================================
  // SELECTED STUDENT CARD
  // ============================================================

  Widget _selectedStudentCard() {
    final students = parent?.students ?? [];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Select Student",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 8),

          if (students.isEmpty)
            const Text(
              "No students linked to this parent",
              style: TextStyle(
                fontSize: 15,
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            )
          else
            DropdownButtonFormField<StudentResponse>(
              value: selectedStudent,
              isExpanded: true,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.person, color: Color(0xff1565C0)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
              ),
              hint: const Text("Select Student"),
              items: students.map((student) {
                return DropdownMenuItem<StudentResponse>(
                  value: student,
                  child: Text(
                    "${student.name} - ${student.className ?? ''}",
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (student) {
                if (student == null) return;

                print(
                  '🎯 Dashboard student changed: '
                  '${student.id} - ${student.name}',
                );

                _selectStudent(student);
              },
            ),
        ],
      ),
    );
  }

  // ============================================================
  // STUDENT CARD
  // ============================================================

  Widget _studentCard(StudentResponse student, int index) {
    final colors = [Colors.green, Colors.blue, Colors.orange, Colors.purple];

    final color = colors[index % colors.length];

    final isSelected = selectedStudent?.id == student.id;

    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),

        border: isSelected
            ? Border.all(color: const Color(0xff1565C0), width: 1.5)
            : null,
      ),

      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color,

            child: Text(
              student.name.isNotEmpty ? student.name[0].toUpperCase() : "?",

              style: const TextStyle(color: Colors.white, fontSize: 22),
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  student.name,

                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),

                Text(_className(student)),

                const SizedBox(height: 5),

                Text(
                  "Admission No: "
                  "${student.admissionNo ?? '-'}",

                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),

                if (student.status != null)
                  Text(
                    "Status: ${student.status}",

                    style: const TextStyle(fontSize: 12),
                  ),
              ],
            ),
          ),

          Icon(
            isSelected ? Icons.check_circle : Icons.arrow_forward_ios,

            color: isSelected ? const Color(0xff1565C0) : Colors.grey,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CLASS NAME
  // ============================================================

  String _className(StudentResponse student) {
    if (student.sectionName != null && student.sectionName!.trim().isNotEmpty) {
      return student.sectionName!;
    }

    return "Class information unavailable";
  }
}

// ================================================================
// QUICK ACTION
// ================================================================

class _Quick extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const _Quick(this.icon, this.title, {this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),

      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(icon, color: const Color(0xff1565C0)),

            const SizedBox(height: 8),

            Text(
              title,
              textAlign: TextAlign.center,

              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
