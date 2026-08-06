import 'package:flutter/material.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final subjects = [
      {
        "subject": "English",
        "marks": 92,
        "max": 100,
        "grade": "A+",
        "color": Colors.blue,
      },
      {
        "subject": "Mathematics",
        "marks": 95,
        "max": 100,
        "grade": "A+",
        "color": Colors.orange,
      },
      {
        "subject": "Science",
        "marks": 89,
        "max": 100,
        "grade": "A",
        "color": Colors.green,
      },
      {
        "subject": "Social",
        "marks": 91,
        "max": 100,
        "grade": "A+",
        "color": Colors.purple,
      },
      {
        "subject": "Telugu",
        "marks": 84,
        "max": 100,
        "grade": "A",
        "color": Colors.red,
      },
      {
        "subject": "Computer",
        "marks": 98,
        "max": 100,
        "grade": "A+",
        "color": Colors.teal,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xffF5F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Exam Results",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // Summary Card

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
            child: const Column(
              children: [

                CircleAvatar(
                  radius: 38,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.workspace_premium,
                    color: Colors.amber,
                    size: 40,
                  ),
                ),

                SizedBox(height: 16),

                Text(
                  "Term - 1 Examination",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [

                    _ResultBox("91.5%", "Percentage"),

                    _ResultBox("A+", "Grade"),

                    _ResultBox("5", "Rank"),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          const Text(
            "Subject Wise Marks",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),

          const SizedBox(height: 15),

          ...subjects.map((subject) {

            final percent =
                (subject["marks"] as int) / (subject["max"] as int);

            return Card(
              margin: const EdgeInsets.only(bottom: 15),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [

                    Row(
                      children: [

                        CircleAvatar(
                          backgroundColor:
                              (subject["color"] as Color).withOpacity(.15),
                          child: Icon(
                            Icons.book,
                            color: subject["color"] as Color,
                          ),
                        ),

                        const SizedBox(width: 15),

                        Expanded(
                          child: Text(
                            subject["subject"].toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            subject["grade"].toString(),
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    LinearProgressIndicator(
                      value: percent,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(10),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [

                        Text(
                          "${subject["marks"]}/${subject["max"]}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Text(
                          "${(percent * 100).toStringAsFixed(0)}%",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 25),

          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Padding(
              padding: EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    "Class Teacher Remarks",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),

                  SizedBox(height: 12),

                  Text(
                    "Rahul has performed exceptionally well this term. Keep encouraging him to participate in extracurricular activities and maintain consistency in Mathematics and Computer Science.",
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 25),

          SizedBox(
            height: 55,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download),
              label: const Text(
                "Download Report Card",
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _ResultBox extends StatelessWidget {
  final String value;
  final String title;

  const _ResultBox(this.value, this.title);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
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