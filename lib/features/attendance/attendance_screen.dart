import 'package:flutter/material.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final attendance = [
      {"day": "Mon", "date": "01", "status": true},
      {"day": "Tue", "date": "02", "status": true},
      {"day": "Wed", "date": "03", "status": false},
      {"day": "Thu", "date": "04", "status": true},
      {"day": "Fri", "date": "05", "status": true},
      {"day": "Sat", "date": "06", "status": false},
      {"day": "Mon", "date": "08", "status": true},
      {"day": "Tue", "date": "09", "status": true},
      {"day": "Wed", "date": "10", "status": true},
      {"day": "Thu", "date": "11", "status": true},
    ];

    return Scaffold(
      backgroundColor: const Color(0xffF5F8FC),

      appBar: AppBar(
        title: const Text("Attendance"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          //---------------------------------------
          // Student Card
          //---------------------------------------

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xff1565C0),
                  Color(0xff42A5F5),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [

                const CircleAvatar(
                  radius: 32,
                  backgroundImage:
                      NetworkImage("https://i.pravatar.cc/300?img=12"),
                ),

                const SizedBox(width: 15),

                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        "Rahul Kumar",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 4),

                      Text(
                        "Class 6-A",
                        style: TextStyle(color: Colors.white70),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          //---------------------------------------
          // Summary
          //---------------------------------------

          Row(
            children: [

              Expanded(child: summaryCard(
                "Present",
                "22",
                Colors.green,
                Icons.check_circle,
              )),

              const SizedBox(width: 12),

              Expanded(child: summaryCard(
                "Absent",
                "2",
                Colors.red,
                Icons.cancel,
              )),

              const SizedBox(width: 12),

              Expanded(child: summaryCard(
                "%",
                "92%",
                Colors.blue,
                Icons.bar_chart,
              )),
            ],
          ),

          const SizedBox(height: 25),

          const Text(
            "This Month",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),

          const SizedBox(height: 15),

          //---------------------------------------
          // Calendar
          //---------------------------------------

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: attendance.map((day) {
              final present = day["status"] as bool;

              return Container(
                width: 65,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: present
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [

                    Text(
                      day["day"].toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      day["date"].toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Icon(
                      present
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: present
                          ? Colors.green
                          : Colors.red,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 30),

          const Text(
            "Attendance History",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),

          const SizedBox(height: 15),

          historyTile(
            "10 Aug 2026",
            true,
          ),

          historyTile(
            "09 Aug 2026",
            true,
          ),

          historyTile(
            "08 Aug 2026",
            false,
          ),

          historyTile(
            "07 Aug 2026",
            true,
          ),
        ],
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
      padding: const EdgeInsets.all(18),
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

  Widget historyTile(String date, bool present) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: present
              ? Colors.green.shade100
              : Colors.red.shade100,
          child: Icon(
            present
                ? Icons.check
                : Icons.close,
            color: present
                ? Colors.green
                : Colors.red,
          ),
        ),
        title: Text(date),
        subtitle: Text(
          present ? "Present" : "Absent",
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey.shade500,
        ),
      ),
    );
  }
}