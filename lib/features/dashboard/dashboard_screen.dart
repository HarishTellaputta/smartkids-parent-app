import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

import 'package:parent_app/features/mcq/daily_test_screen.dart';
import 'package:parent_app/models/mcq_test.dart';
import 'package:parent_app/widgets/mcq/daily_test_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F8FC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Good Morning 👋",
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            Text(
              "Ramesh Kumar",
              style: TextStyle(
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
                onPressed: () {},
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

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          //---------------------------------------
          // School Card
          //---------------------------------------
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
                  "The Conroy School",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
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

          //---------------------------------------
          // Fee Reminder
          //---------------------------------------
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

                      Text("₹8,000 due before 10 Aug 2026"),
                    ],
                  ),
                ),

                ElevatedButton(onPressed: () {}, child: const Text("Pay")),
              ],
            ),
          ),

          const SizedBox(height: 20),

          //---------------------------------------
          // Daily MCQ Test
          //---------------------------------------
          DailyTestCard(
            test: McqTest.dummy(),
            onStartTest: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DailyTestScreen(test: McqTest.dummy()),
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          //---------------------------------------
          // My Children
          //---------------------------------------
          const Text(
            "My Children",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 15),

          _studentCard(
            "Rahul Kumar",
            "Class 6-A",
            "96%",
            "Homework: 2 Pending",
            Colors.green,
          ),

          const SizedBox(height: 15),

          _studentCard(
            "Priya Kumar",
            "Class 3-B",
            "99%",
            "Homework Completed",
            Colors.blue,
          ),

          const SizedBox(height: 20),

          //---------------------------------------
          // Quick Actions
          //---------------------------------------
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
            children: const [
              _Quick(Icons.calendar_today, "Attendance"),
              _Quick(Icons.menu_book, "Homework"),
              _Quick(Icons.bar_chart, "Results"),
              _Quick(Icons.currency_rupee, "Fees"),
              _Quick(Icons.schedule, "Timetable"),
              _Quick(Icons.event, "Events"),
              _Quick(Icons.notifications, "Notices"),
              _Quick(Icons.person, "Profile"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _studentCard(
    String name,
    String cls,
    String attendance,
    String homework,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color,
            child: Text(
              name[0],
              style: const TextStyle(color: Colors.white, fontSize: 22),
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),

                Text(cls),

                const SizedBox(height: 5),

                Text("Attendance : $attendance"),

                Text(homework),
              ],
            ),
          ),

          const Icon(Icons.arrow_forward_ios),
        ],
      ),
    );
  }
}

class _Quick extends StatelessWidget {
  final IconData icon;
  final String title;

  const _Quick(this.icon, this.title);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Color(0xff1565C0)),

          SizedBox(height: 8),

          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
