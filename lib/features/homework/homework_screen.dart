import 'package:flutter/material.dart';

class HomeworkScreen extends StatelessWidget {
  const HomeworkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeworkList = [
      {
        "subject": "English",
        "title": "Essay Writing",
        "description": "Write an essay on 'My School' in 250 words.",
        "dueDate": "12 Aug 2026",
        "status": "Pending",
        "teacher": "Mrs. Priya",
        "color": Colors.orange,
      },
      {
        "subject": "Mathematics",
        "title": "Exercise 5.2",
        "description": "Complete Questions 1 - 10 from textbook.",
        "dueDate": "13 Aug 2026",
        "status": "Submitted",
        "teacher": "Mr. Ramesh",
        "color": Colors.green,
      },
      {
        "subject": "Science",
        "title": "Solar System Chart",
        "description": "Prepare a chart explaining the Solar System.",
        "dueDate": "15 Aug 2026",
        "status": "Pending",
        "teacher": "Mrs. Kavitha",
        "color": Colors.orange,
      },
      {
        "subject": "Social",
        "title": "Indian Freedom Fighters",
        "description": "Write short notes on any 5 freedom fighters.",
        "dueDate": "18 Aug 2026",
        "status": "Submitted",
        "teacher": "Mr. Suresh",
        "color": Colors.green,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xffF5F8FC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text("Homework"),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          //-----------------------------------------
          // Summary
          //-----------------------------------------

          Row(
            children: [

              Expanded(
                child: summaryCard(
                  "Total",
                  "12",
                  Colors.blue,
                  Icons.book,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: summaryCard(
                  "Pending",
                  "3",
                  Colors.orange,
                  Icons.pending_actions,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: summaryCard(
                  "Done",
                  "9",
                  Colors.green,
                  Icons.check_circle,
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),

          const Text(
            "Homework List",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),

          const SizedBox(height: 15),

          ...homeworkList.map((hw) {
            return homeworkCard(hw);
          }),

          const SizedBox(height: 30),
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
      padding: const EdgeInsets.all(16),
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

  Widget homeworkCard(Map hw) {
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
              children: [

                Chip(
                  label: Text(hw["subject"]),
                  backgroundColor: Colors.blue.shade50,
                ),

                const Spacer(),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: (hw["color"] as Color).withOpacity(.15),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    hw["status"],
                    style: TextStyle(
                      color: hw["color"],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),

            const SizedBox(height: 15),

            Text(
              hw["title"],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              hw["description"],
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 15),

            Row(
              children: [

                const Icon(
                  Icons.person,
                  size: 18,
                  color: Colors.grey,
                ),

                const SizedBox(width: 5),

                Text(hw["teacher"]),

                const Spacer(),

                const Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: Colors.grey,
                ),

                const SizedBox(width: 5),

                Text(hw["dueDate"]),
              ],
            ),

            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.visibility),
                label: const Text("View Details"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}