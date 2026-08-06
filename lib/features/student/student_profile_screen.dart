import 'package:flutter/material.dart';

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Student Profile",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // Student Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xff1565C0),
                    Color(0xff42A5F5),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [

                  const CircleAvatar(
                    radius: 45,
                    backgroundImage: NetworkImage(
                      "https://i.pravatar.cc/300?img=12",
                    ),
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    "Rahul Kumar",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    "Class 6-A",
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [

                      _TopItem("Roll No", "23"),

                      _TopItem("Attendance", "96%"),

                      _TopItem("Rank", "5"),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            _sectionTitle("Student Information"),

            _infoCard(),

            const SizedBox(height: 20),

            _sectionTitle("Academic Performance"),

            _performanceCard(),

            const SizedBox(height: 20),

            _sectionTitle("Quick Actions"),

            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: const [

                _QuickAction(Icons.calendar_today, "Attendance"),

                _QuickAction(Icons.menu_book, "Homework"),

                _QuickAction(Icons.schedule, "Timetable"),

                _QuickAction(Icons.bar_chart, "Results"),

                _QuickAction(Icons.currency_rupee, "Fees"),

                _QuickAction(Icons.event_note, "Leave"),
              ],
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _infoCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        children: [

          _InfoRow("Admission No", "SKP20260045"),

          Divider(),

          _InfoRow("Date of Birth", "15 Aug 2016"),

          Divider(),

          _InfoRow("Blood Group", "O+"),

          Divider(),

          _InfoRow("Gender", "Male"),

          Divider(),

          _InfoRow("Father", "Ramesh Kumar"),

          Divider(),

          _InfoRow("Mother", "Sita Kumari"),

          Divider(),

          _InfoRow("Mobile", "9876543210"),

          Divider(),

          _InfoRow("Address", "Khammam, Telangana"),
        ],
      ),
    );
  }

  Widget _performanceCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [

          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              Text("Overall Progress"),

              Text(
                "89%",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),

          const SizedBox(height: 10),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: const LinearProgressIndicator(
              value: .89,
              minHeight: 10,
            ),
          ),

          const SizedBox(height: 20),

          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              Text("Homework Completed"),

              Text("42 / 45"),
            ],
          ),

          const SizedBox(height: 10),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: const LinearProgressIndicator(
              value: .93,
              minHeight: 10,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopItem extends StatelessWidget {
  final String title;
  final String value;

  const _TopItem(this.title, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String title;
  final String value;

  const _InfoRow(this.title, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [

          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String title;

  const _QuickAction(this.icon, this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            CircleAvatar(
              backgroundColor: const Color(0xff1565C0).withOpacity(.1),
              child: Icon(
                icon,
                color: const Color(0xff1565C0),
              ),
            ),

            const SizedBox(height: 10),

            Text(
              title,
              style: const TextStyle(fontSize: 13),
            )
          ],
        ),
      ),
    );
  }
}