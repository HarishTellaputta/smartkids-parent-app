import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {
        "title": "Homework Assigned",
        "message": "English Essay homework has been assigned.",
        "time": "5 mins ago",
        "icon": Icons.menu_book,
        "color": Colors.blue,
        "read": false,
      },
      {
        "title": "Attendance Marked",
        "message": "Rahul is marked Present today.",
        "time": "1 hour ago",
        "icon": Icons.check_circle,
        "color": Colors.green,
        "read": false,
      },
      {
        "title": "Fee Reminder",
        "message": "Term 2 fee is due on 15 Aug.",
        "time": "Yesterday",
        "icon": Icons.currency_rupee,
        "color": Colors.orange,
        "read": true,
      },
      {
        "title": "Exam Result Published",
        "message": "Term 1 Results are now available.",
        "time": "2 days ago",
        "icon": Icons.bar_chart,
        "color": Colors.purple,
        "read": true,
      },
      {
        "title": "Holiday Notice",
        "message": "School will remain closed on Friday.",
        "time": "3 days ago",
        "icon": Icons.event,
        "color": Colors.red,
        "read": true,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xffF5F8FC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text("Read All"),
          )
        ],
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final item = notifications[index];

          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 14),
            color: item["read"] as bool
                ? Colors.white
                : Colors.blue.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),

              leading: CircleAvatar(
                radius: 26,
                backgroundColor:
                    (item["color"] as Color).withOpacity(.15),
                child: Icon(
                  item["icon"] as IconData,
                  color: item["color"] as Color,
                ),
              ),

              title: Text(
                item["title"].toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  item["message"].toString(),
                ),
              ),

              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Text(
                    item["time"].toString(),
                    style: const TextStyle(
                      fontSize: 11,
                    ),
                  ),

                  const SizedBox(height: 8),

                  if (!(item["read"] as bool))
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),

              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}