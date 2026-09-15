import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:parent_app/features/fees/fee_details_screen.dart';

import '../student/student_profile_screen.dart';
import '../attendance/attendance_screen.dart';
import '../homework/homework_screen.dart';

import '../timetable/timetable_screen.dart';
import '../results/results_screen.dart';

import '../notices/notices_screen.dart';
import '../notifications/notifications_screen.dart';
import '../calendar/calendar_screen.dart';
import '../transport/transport_screen.dart';
import '../health/health_screen.dart';
import '../certificates/certificates_screen.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_screen.dart';
import '../contact/contact_school_screen.dart';
import '../about/about_school_screen.dart';
import '../achievements/achievements_screen.dart';
import '../chat/chat_screen.dart';
import '../events/events_screen.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../leave/leave_request_screen.dart';
import '../birthday/birthday_wishes_screen.dart';

import '../mcq/daily_test_screen.dart';
import '../../models/mcq_test.dart';
import '../../widgets/mcq/daily_test_card.dart';

class ParentHomeScreen extends StatelessWidget {
  const ParentHomeScreen({super.key});

  static const List<String> schoolImages = [
    "https://images.unsplash.com/photo-1509062522246-3755977927d7",
    "https://images.unsplash.com/photo-1588072432836-e10032774350",
    "https://images.unsplash.com/photo-1513258496099-48168024aec0",
    "https://images.unsplash.com/photo-1503676260728-1c00da094a0b",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F8FC),

      appBar: AppBar(
        elevation: 0,

        backgroundColor: Colors.white,
        centerTitle: true,

        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            child: const CircleAvatar(
              radius: 22,
              backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=12"),
            ),
          ),
        ),

        title: const Text(
          "Smart School",
          style: TextStyle(
            color: Color(0xFF1565C0),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Stack(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.notifications, color: Colors.blue),
                ),

                Positioned(
                  right: 5,
                  top: 8,
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
                        style: TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const SizedBox(height: 20),

            // Fee Reminder
            Container(
              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(18),
              ),

              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),

                    decoration: BoxDecoration(
                      color: Colors.red.shade50,

                      shape: BoxShape.circle,
                    ),

                    child: const Icon(Icons.currency_rupee, color: Colors.red),
                  ),

                  const SizedBox(width: 15),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          "Pending Fee",

                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),

                        SizedBox(height: 5),

                        Text(
                          "₹12,500 due on 10 Aug 2026",

                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,

                        MaterialPageRoute(
                          builder: (_) => const FeeDetailsScreen(),
                        ),
                      );
                    },

                    child: const Text("Pay"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const SizedBox(height: 20),

            //================ TODAY'S BIRTHDAYS ================//
            const Text(
              "🎂 Today's Birthdays",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            SizedBox(
              height: 110,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  birthdayItem(
                    context,
                    "Keerthi",
                    "https://i.pravatar.cc/150?img=45",
                  ),

                  birthdayItem(
                    context,
                    "Rahul",
                    "https://i.pravatar.cc/150?img=12",
                  ),

                  birthdayItem(
                    context,
                    "Ananya",
                    "https://i.pravatar.cc/150?img=32",
                  ),

                  birthdayItem(
                    context,
                    "Arjun",
                    "https://i.pravatar.cc/150?img=60",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            CarouselSlider(
              options: CarouselOptions(
                height: 190,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 3),
                enlargeCenterPage: true,
                viewportFraction: 0.92,
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
              ),
              items: schoolImages.map((image) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(image, fit: BoxFit.cover),

                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Colors.black54, Colors.transparent],
                          ),
                        ),
                      ),

                      const Positioned(
                        left: 15,
                        bottom: 15,
                        child: Text(
                          "Smart School",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // =====================================================
            // DAILY MCQ TEST
            // =====================================================
            const Text(
              "🧠 Daily Test",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            DailyTestCard(
              test: McqTest.dummy(),
              onStartTest: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DailyTestScreen(test: McqTest.dummy()),
                  ),
                );
              },
            ),

            const SizedBox(height: 25),

            const Text(
              "Quick Access",

              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            GridView.count(
              shrinkWrap: true,

              physics: const NeverScrollableScrollPhysics(),

              crossAxisCount: 3,

              crossAxisSpacing: 12,

              mainAxisSpacing: 12,

              children: [
                menuItem(
                  context,
                  Icons.person,
                  "Profile",
                  const StudentProfileScreen(),
                ),

                menuItem(
                  context,
                  Icons.fact_check,
                  "Attendance",
                  const AttendanceScreen(),
                ),

                menuItem(
                  context,
                  Icons.book,
                  "Homework",
                  const HomeworkScreen(),
                ),

                menuItem(
                  context,
                  Icons.schedule,
                  "Timetable",
                  const TimetableScreen(),
                ),

                menuItem(
                  context,
                  Icons.grade,
                  "Results",
                  const ResultsScreen(),
                ),

                menuItem(
                  context,
                  Icons.directions_bus,
                  "Transport",
                  const TransportScreen(),
                ),

                menuItem(context, Icons.chat, "Chat", const ChatScreen()),

                menuItem(
                  context,
                  Icons.event_busy,
                  "Leave",
                  const LeaveRequestScreen(),
                ),
                menuItem(
                  context,
                  Icons.emoji_events,
                  "Achievements",
                  const AchievementsScreen(),
                ),
              ],
            ),

            const SizedBox(height: 25),

            const Text(
              "Latest Notice",

              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            noticeCard(),
          ],
        ),
      ),
    );
  }

  Widget menuItem(
    BuildContext context,

    IconData icon,

    String title,

    Widget page,
  ) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },

      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(18),
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(icon, color: Colors.blue, size: 30),

            const SizedBox(height: 8),

            Text(title, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget noticeCard() {
    return Card(
      elevation: 0,

      child: const ListTile(
        leading: CircleAvatar(child: Icon(Icons.notifications)),

        title: Text("Parent Meeting on Saturday"),

        subtitle: Text("School auditorium at 10:00 AM"),
      ),
    );
  }

  Widget birthdayItem(BuildContext context, String name, String image) {
    return GestureDetector(
      onTap: () {
        // Open Birthday Wishes Screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BirthdayWishesScreen()),
        );
      },
      child: Container(
        width: 90,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.orange, width: 3),
              ),
              child: CircleAvatar(
                radius: 32,
                backgroundImage: NetworkImage(image),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
