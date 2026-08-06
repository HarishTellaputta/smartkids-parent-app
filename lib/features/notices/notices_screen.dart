import 'package:flutter/material.dart';

class NoticesScreen extends StatelessWidget {
  const NoticesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notices = [
      {
        "title": "Independence Day Celebration",
        "date": "10 Aug 2026",
        "priority": "High",
        "color": Colors.red,
        "description":
            "Students should attend in white uniform. Program starts at 8:30 AM."
      },
      {
        "title": "Parent Teacher Meeting",
        "date": "14 Aug 2026",
        "priority": "Medium",
        "color": Colors.orange,
        "description":
            "Parents are requested to attend the PTM between 10 AM and 1 PM."
      },
      {
        "title": "Science Exhibition",
        "date": "20 Aug 2026",
        "priority": "Normal",
        "color": Colors.blue,
        "description":
            "Students from Classes 6-10 should prepare science projects."
      },
      {
        "title": "Holiday Notice",
        "date": "22 Aug 2026",
        "priority": "Info",
        "color": Colors.green,
        "description":
            "School will remain closed on account of local festival."
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xffF5F8FC),
      appBar: AppBar(
        title: const Text("School Notices"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notices.length,
        itemBuilder: (context, index) {
          final notice = notices[index];

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

                      CircleAvatar(
                        backgroundColor:
                            (notice["color"] as Color).withOpacity(.15),
                        child: Icon(
                          Icons.campaign,
                          color: notice["color"] as Color,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Text(
                          notice["title"].toString(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color:
                              (notice["color"] as Color).withOpacity(.15),
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                        child: Text(
                          notice["priority"].toString(),
                          style: TextStyle(
                            color: notice["color"] as Color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  Text(
                    notice["description"].toString(),
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Row(
                    children: [

                      const Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: Colors.grey,
                      ),

                      const SizedBox(width: 6),

                      Text(notice["date"].toString()),

                      const Spacer(),

                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.visibility),
                        label: const Text("View"),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}