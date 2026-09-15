import 'package:flutter/material.dart';

class PerformanceScreen extends StatelessWidget {
  const PerformanceScreen({super.key});

  // ============================================================
  // DUMMY DATA
  // Later this will come from backend API.
  // ============================================================

  final String studentName = "Keerthi";

  final int totalTests = 12;
  final int testsCompleted = 10;
  final int averageScore = 78;
  final int highestScore = 95;

  // Subject-wise performance
  final List<Map<String, dynamic>> subjectPerformance = const [
    {
      "subject": "Mathematics",
      "score": 82,
      "tests": 4,
      "icon": Icons.calculate_rounded,
    },
    {
      "subject": "English",
      "score": 76,
      "tests": 3,
      "icon": Icons.menu_book_rounded,
    },
    {
      "subject": "Science",
      "score": 85,
      "tests": 2,
      "icon": Icons.science_rounded,
    },
    {
      "subject": "General Knowledge",
      "score": 68,
      "tests": 1,
      "icon": Icons.public_rounded,
    },
  ];

  // Recent test history
  final List<Map<String, dynamic>> recentTests = const [
    {
      "title": "Daily Mathematics Test",
      "date": "Today",
      "score": 9,
      "total": 10,
      "percentage": 90,
    },
    {
      "title": "English Grammar",
      "date": "Yesterday",
      "score": 8,
      "total": 10,
      "percentage": 80,
    },
    {
      "title": "Science Basics",
      "date": "05 Aug 2026",
      "score": 7,
      "total": 10,
      "percentage": 70,
    },
    {
      "title": "General Knowledge",
      "date": "04 Aug 2026",
      "score": 6,
      "total": 10,
      "percentage": 60,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F8FC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xff172033),
        elevation: 0,

        title: const Text(
          "My Performance",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        centerTitle: true,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // ==================================================
              // STUDENT HEADER
              // ==================================================
              _studentHeader(),

              const SizedBox(height: 20),

              // ==================================================
              // OVERALL PERFORMANCE CARD
              // ==================================================
              _overallPerformanceCard(),

              const SizedBox(height: 20),

              // ==================================================
              // STATISTICS
              // ==================================================
              const Text(
                "Test Statistics",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff172033),
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      icon: Icons.quiz_rounded,
                      title: "Total Tests",
                      value: "$totalTests",
                      color: const Color(0xff4169E1),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _statCard(
                      icon: Icons.check_circle_rounded,
                      title: "Completed",
                      value: "$testsCompleted",
                      color: Colors.green,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      icon: Icons.analytics_rounded,
                      title: "Average",
                      value: "$averageScore%",
                      color: Colors.orange,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _statCard(
                      icon: Icons.emoji_events_rounded,
                      title: "Best Score",
                      value: "$highestScore%",
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // ==================================================
              // SUBJECT PERFORMANCE
              // ==================================================
              const Text(
                "Subject Performance",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff172033),
                ),
              ),

              const SizedBox(height: 12),

              ...subjectPerformance.map(
                (subject) => _subjectCard(subject: subject),
              ),

              const SizedBox(height: 25),

              // ==================================================
              // RECENT TESTS
              // ==================================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  const Text(
                    "Recent Tests",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff172033),
                    ),
                  ),

                  TextButton(
                    onPressed: () {
                      _showAllTests(context);
                    },
                    child: const Text("View All"),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              ...recentTests.map((test) => _recentTestCard(test: test)),

              const SizedBox(height: 25),

              // ==================================================
              // MOTIVATION CARD
              // ==================================================
              _motivationCard(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // STUDENT HEADER
  // ============================================================

  Widget _studentHeader() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff4169E1), Color(0xff6387F5)],
        ),

        borderRadius: BorderRadius.circular(20),
      ),

      child: Row(
        children: [
          Container(
            height: 58,
            width: 58,

            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),

            child: const Icon(
              Icons.person_rounded,
              size: 32,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  "Student Performance",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),

                const SizedBox(height: 3),

                Text(
                  studentName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 3),

                const Text(
                  "Keep learning, keep growing! 🌟",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // OVERALL PERFORMANCE
  // ============================================================

  Widget _overallPerformanceCard() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      "Overall Performance",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 5),

                    Text(
                      "Based on completed daily tests",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),

                decoration: BoxDecoration(
                  color: const Color(0xffDCFCE7),
                  borderRadius: BorderRadius.circular(20),
                ),

                child: const Text(
                  "Good",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),

          Row(
            children: [
              // Circular percentage
              SizedBox(
                height: 120,
                width: 120,

                child: Stack(
                  alignment: Alignment.center,

                  children: [
                    SizedBox(
                      height: 120,
                      width: 120,

                      child: CircularProgressIndicator(
                        value: averageScore / 100,
                        strokeWidth: 11,

                        backgroundColor: const Color(0xffE8ECF4),

                        valueColor: const AlwaysStoppedAnimation(
                          Color(0xff4169E1),
                        ),
                      ),
                    ),

                    Column(
                      mainAxisSize: MainAxisSize.min,

                      children: [
                        Text(
                          "$averageScore%",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff4169E1),
                          ),
                        ),

                        const Text(
                          "Average",
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 25),

              Expanded(
                child: Column(
                  children: [
                    _performanceLine(
                      "Tests Completed",
                      "$testsCompleted / $totalTests",
                    ),

                    const SizedBox(height: 15),

                    _performanceLine("Highest Score", "$highestScore%"),

                    const SizedBox(height: 15),

                    _performanceLine("Average Score", "$averageScore%"),
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
  // PERFORMANCE LINE
  // ============================================================

  Widget _performanceLine(String title, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ),

        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // ============================================================
  // STAT CARD
  // ============================================================

  Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(17),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Container(
            height: 38,
            width: 38,

            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
            ),

            child: Icon(icon, color: color, size: 21),
          ),

          const SizedBox(height: 12),

          Text(
            value,
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 3),

          Text(
            title,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUBJECT CARD
  // ============================================================

  Widget _subjectCard({required Map<String, dynamic> subject}) {
    final int score = subject["score"];

    final Color scoreColor = score >= 80
        ? Colors.green
        : score >= 60
        ? Colors.orange
        : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(17),
      ),

      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 44,
                width: 44,

                decoration: BoxDecoration(
                  color: const Color(0xffE8F0FF),
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Icon(subject["icon"], color: const Color(0xff4169E1)),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      subject["subject"],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      "${subject["tests"]} tests completed",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                "$score%",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: scoreColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),

            child: LinearProgressIndicator(
              value: score / 100,
              minHeight: 7,

              backgroundColor: const Color(0xffEDF0F5),

              valueColor: AlwaysStoppedAnimation(scoreColor),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RECENT TEST CARD
  // ============================================================

  Widget _recentTestCard({required Map<String, dynamic> test}) {
    final int percentage = test["percentage"];

    final Color scoreColor = percentage >= 80
        ? Colors.green
        : percentage >= 60
        ? Colors.orange
        : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),

      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(16),
      ),

      child: Row(
        children: [
          Container(
            height: 45,
            width: 45,

            decoration: BoxDecoration(
              color: const Color(0xffE8F0FF),
              borderRadius: BorderRadius.circular(12),
            ),

            child: const Icon(Icons.quiz_rounded, color: Color(0xff4169E1)),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  test["title"],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  "${test["date"]} • "
                  "${test["score"]}/${test["total"]}",
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),

            decoration: BoxDecoration(
              color: scoreColor.withOpacity(0.10),

              borderRadius: BorderRadius.circular(10),
            ),

            child: Text(
              "$percentage%",

              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: scoreColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MOTIVATION CARD
  // ============================================================

  Widget _motivationCard() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xffFFF7E6), Color(0xfffff0c7)],
        ),

        borderRadius: BorderRadius.circular(20),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text("🌟", style: TextStyle(fontSize: 32)),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  "Keep Going!",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 6),

                Text(
                  "Every test is a chance to learn "
                  "something new. Keep practicing "
                  "and make your next score even better!",
                  style: TextStyle(fontSize: 12, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // VIEW ALL TESTS
  // ============================================================

  void _showAllTests(BuildContext context) {
    showModalBottomSheet(
      context: context,

      backgroundColor: Colors.white,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),

      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),

            child: Column(
              mainAxisSize: MainAxisSize.min,

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  "All Test History",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 15),

                const Text(
                  "Test history API will be connected here.",
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },

                    child: const Text("Close"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
