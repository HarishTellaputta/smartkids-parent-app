import 'package:flutter/material.dart';

class BirthdayWishesScreen extends StatefulWidget {
  const BirthdayWishesScreen({super.key});

  @override
  State<BirthdayWishesScreen> createState() => _BirthdayWishesScreenState();
}

class _BirthdayWishesScreenState extends State<BirthdayWishesScreen> {
  final TextEditingController wishController = TextEditingController();

  bool showPhoto = true;

  final List<Map<String, String>> wishes = [
    {
      "name": "Mrs. Priya (Teacher)",
      "message": "Happy Birthday Keerthi 🎉 God Bless You ❤️",
      "time": "09:10 AM",
    },

    {
      "name": "Rahul's Mom",
      "message": "Have a wonderful birthday dear 🎂",
      "time": "09:25 AM",
    },

    {
      "name": "Principal",
      "message": "Best Wishes for a bright future 🌸",
      "time": "10:00 AM",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F8FC),

      appBar: AppBar(
        centerTitle: true,

        backgroundColor: Colors.white,

        title: const Text(
          "Birthday Wishes",
          style: TextStyle(color: Colors.black),
        ),
      ),

      body: Column(
        children: [
          //------------------------------------
          // TOP 40%
          //------------------------------------
          Container(
            width: double.infinity,

            padding: const EdgeInsets.all(20),

            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff1565C0), Color(0xff42A5F5)],
              ),

              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(35),

                bottomRight: Radius.circular(35),
              ),
            ),

            child: Column(
              children: [
                const SizedBox(height: 15),

                if (showPhoto)
                  const CircleAvatar(
                    radius: 55,

                    backgroundImage: NetworkImage(
                      "https://i.pravatar.cc/300?img=12",
                    ),
                  )
                else
                  CircleAvatar(
                    radius: 55,

                    backgroundColor: Colors.white,

                    child: Text(
                      "K",

                      style: TextStyle(
                        fontSize: 45,

                        color: Colors.blue.shade700,

                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                const SizedBox(height: 18),

                const Text(
                  "🎂 Happy Birthday",

                  style: TextStyle(
                    color: Colors.white,

                    fontSize: 28,

                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Keerthi",

                  style: TextStyle(
                    color: Colors.white,

                    fontSize: 24,

                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  "UKG - A",

                  style: TextStyle(color: Colors.white70, fontSize: 17),
                ),

                const SizedBox(height: 18),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,

                    vertical: 10,
                  ),

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius: BorderRadius.circular(25),
                  ),

                  child: const Row(
                    mainAxisSize: MainAxisSize.min,

                    children: [
                      Icon(Icons.favorite, color: Colors.red),

                      SizedBox(width: 8),

                      Text(
                        "128 Birthday Wishes",

                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),

          const SizedBox(height: 15),

          //-------------------------------
          // Wishes List
          //-------------------------------
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),

              itemCount: wishes.length,

              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),

                  elevation: 1,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),

                  child: Padding(
                    padding: const EdgeInsets.all(14),

                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blue.shade100,

                          child: Text(
                            wishes[index]["name"]![0],

                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Text(
                                wishes[index]["name"]!,

                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,

                                  fontSize: 15,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                wishes[index]["message"]!,

                                style: const TextStyle(fontSize: 15),
                              ),

                              const SizedBox(height: 10),

                              Row(
                                children: [
                                  const Icon(
                                    Icons.favorite_border,
                                    size: 18,
                                    color: Colors.red,
                                  ),

                                  const SizedBox(width: 4),

                                  const Text("Like"),

                                  const Spacer(),

                                  Text(
                                    wishes[index]["time"]!,

                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          //-------------------------------
          // Write Wish
          //-------------------------------
          SafeArea(
            child: Container(
              color: Colors.white,

              padding: const EdgeInsets.all(12),

              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: wishController,

                      decoration: InputDecoration(
                        hintText: "Write your birthday wish...",

                        filled: true,

                        fillColor: Colors.grey.shade100,

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),

                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  CircleAvatar(
                    radius: 28,

                    backgroundColor: Colors.blue,

                    child: IconButton(
                      onPressed: () {
                        if (wishController.text.isEmpty) {
                          return;
                        }

                        setState(() {
                          wishes.insert(0, {
                            "name": "You",

                            "message": wishController.text,

                            "time": "Now",
                          });
                        });

                        wishController.clear();
                      },

                      icon: const Icon(Icons.send, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
