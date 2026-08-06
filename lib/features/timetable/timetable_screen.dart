import 'package:flutter/material.dart';

class TimetableScreen extends StatelessWidget {
  const TimetableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final periods = [
      {
        "time": "09:00 - 09:45",
        "subject": "English",
        "teacher": "Mrs. Priya",
        "room": "Room 201",
        "color": Colors.blue,
      },
      {
        "time": "09:45 - 10:30",
        "subject": "Mathematics",
        "teacher": "Mr. Ramesh",
        "room": "Room 201",
        "color": Colors.orange,
      },
      {
        "time": "10:45 - 11:30",
        "subject": "Science",
        "teacher": "Mrs. Kavitha",
        "room": "Science Lab",
        "color": Colors.green,
      },
      {
        "time": "11:30 - 12:15",
        "subject": "Social",
        "teacher": "Mr. Suresh",
        "room": "Room 201",
        "color": Colors.purple,
      },
      {
        "time": "01:00 - 01:45",
        "subject": "Computer",
        "teacher": "Mrs. Anitha",
        "room": "Computer Lab",
        "color": Colors.teal,
      },
      {
        "time": "01:45 - 02:30",
        "subject": "Telugu",
        "teacher": "Mrs. Lakshmi",
        "room": "Room 201",
        "color": Colors.red,
      },
      {
        "time": "02:30 - 03:15",
        "subject": "Games",
        "teacher": "Mr. Arun",
        "room": "Play Ground",
        "color": Colors.indigo,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xffF5F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Today's Timetable",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Monday",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "11 August 2026",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          ...List.generate(periods.length, (index) {
            final period = periods[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 15),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 90,
                      decoration: BoxDecoration(
                        color: period["color"] as Color,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            period["subject"].toString(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Row(
                            children: [
                              const Icon(Icons.access_time,
                                  size: 18, color: Colors.grey),
                              const SizedBox(width: 6),
                              Text(period["time"].toString()),
                            ],
                          ),

                          const SizedBox(height: 8),

                          Row(
                            children: [
                              const Icon(Icons.person,
                                  size: 18, color: Colors.grey),
                              const SizedBox(width: 6),
                              Text(period["teacher"].toString()),
                            ],
                          ),

                          const SizedBox(height: 8),

                          Row(
                            children: [
                              const Icon(Icons.meeting_room,
                                  size: 18, color: Colors.grey),
                              const SizedBox(width: 6),
                              Text(period["room"].toString()),
                            ],
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
                        color: (period["color"] as Color).withOpacity(.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "P${index + 1}",
                        style: TextStyle(
                          color: period["color"] as Color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}