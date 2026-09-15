import 'package:flutter/material.dart';

class BirthdayWishesScreen extends StatefulWidget {
  const BirthdayWishesScreen({super.key});

  @override
  State<BirthdayWishesScreen> createState() => _BirthdayWishesScreenState();
}

class _BirthdayWishesScreenState extends State<BirthdayWishesScreen> {
  final TextEditingController wishController = TextEditingController();
  final ScrollController scrollController = ScrollController();

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
  void dispose() {
    wishController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  // ============================================================
  // SEND WISH
  // ============================================================

  void sendWish() {
    final message = wishController.text.trim();

    if (message.isEmpty) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      wishes.add({"name": "You", "message": message, "time": "Now"});
    });

    wishController.clear();

    // Scroll to latest message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xffF5F8FC),

      // ==========================================================
      // APP BAR
      // ==========================================================
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,

        title: const Text(
          "Birthday Wishes",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),

      body: Column(
        children: [
          // ========================================================
          // BIRTHDAY HEADER
          // ========================================================
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,

            width: double.infinity,

            padding: EdgeInsets.fromLTRB(
              20,
              keyboardOpen ? 10 : 18,
              20,
              keyboardOpen ? 12 : 18,
            ),

            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff1565C0), Color(0xff42A5F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),

              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(35),
                bottomRight: Radius.circular(35),
              ),
            ),

            // ======================================================
            // LEFT CONTENT + RIGHT IMAGE
            // ======================================================
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ==================================================
                // LEFT SIDE
                // ==================================================
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --------------------------------------------
                      // HAPPY BIRTHDAY
                      // --------------------------------------------
                      Text(
                        "🎂 Happy Birthday",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: keyboardOpen ? 20 : 27,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: keyboardOpen ? 3 : 6),

                      // --------------------------------------------
                      // CHILD NAME
                      // --------------------------------------------
                      Text(
                        "Keerthi",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: keyboardOpen ? 20 : 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: keyboardOpen ? 2 : 5),

                      // --------------------------------------------
                      // CLASS
                      // --------------------------------------------
                      Text(
                        "UKG - A",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: keyboardOpen ? 12 : 15,
                        ),
                      ),

                      SizedBox(height: keyboardOpen ? 8 : 14),

                      // --------------------------------------------
                      // WISH COUNT
                      // --------------------------------------------
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: keyboardOpen ? 11 : 15,
                          vertical: keyboardOpen ? 6 : 8,
                        ),

                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                        ),

                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.favorite,
                              color: Colors.red,
                              size: keyboardOpen ? 16 : 19,
                            ),

                            const SizedBox(width: 6),

                            Text(
                              "${128 + (wishes.length - 3)} Wishes",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: keyboardOpen ? 11 : 13,
                                color: const Color(0xff172033),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 15),

                // ==================================================
                // RIGHT SIDE - CHILD IMAGE
                // ==================================================
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),

                  height: keyboardOpen ? 75 : 115,
                  width: keyboardOpen ? 75 : 115,

                  decoration: BoxDecoration(
                    shape: BoxShape.circle,

                    border: Border.all(
                      color: Colors.white,
                      width: keyboardOpen ? 3 : 4,
                    ),

                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 12,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),

                  child: ClipOval(
                    child: showPhoto
                        ? Image.network(
                            "https://i.pravatar.cc/300?img=12",
                            fit: BoxFit.cover,

                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.white,
                                child: Icon(
                                  Icons.person,
                                  size: keyboardOpen ? 38 : 55,
                                  color: const Color(0xff1565C0),
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Colors.white,
                            child: Center(
                              child: Text(
                                "K",
                                style: TextStyle(
                                  fontSize: keyboardOpen ? 30 : 48,
                                  color: const Color(0xff1565C0),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),

          // ========================================================
          // CHAT AREA
          // ========================================================
          Expanded(
            child: ListView.builder(
              controller: scrollController,

              padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),

              itemCount: wishes.length,

              itemBuilder: (context, index) {
                final wish = wishes[index];

                final bool isMe = wish["name"] == "You";

                return _buildMessageBubble(wish: wish, isMe: isMe);
              },
            ),
          ),

          // ========================================================
          // MESSAGE INPUT
          // ========================================================

          // IMPORTANT:
          // Do NOT add viewInsets.bottom here.
          //
          // Scaffold resizeToAvoidBottomInset already handles
          // the keyboard.
          //
          // Adding viewInsets again causes overflow.
          //
          SafeArea(
            top: false,

            child: Container(
              width: double.infinity,

              padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),

              decoration: const BoxDecoration(
                color: Colors.white,

                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, -2),
                  ),
                ],
              ),

              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,

                children: [
                  // ==================================================
                  // TEXT FIELD
                  // ==================================================
                  Expanded(
                    child: TextField(
                      controller: wishController,

                      minLines: 1,
                      maxLines: 4,

                      textInputAction: TextInputAction.newline,

                      decoration: InputDecoration(
                        hintText: "Write your birthday wish...",

                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),

                        filled: true,

                        fillColor: const Color(0xffF1F3F5),

                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),

                          borderSide: BorderSide.none,
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),

                          borderSide: const BorderSide(
                            color: Color(0xff1565C0),
                            width: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // ==================================================
                  // SEND BUTTON
                  // ==================================================
                  Container(
                    height: 52,
                    width: 52,

                    decoration: const BoxDecoration(
                      color: Color(0xff1565C0),
                      shape: BoxShape.circle,
                    ),

                    child: IconButton(
                      onPressed: sendWish,

                      icon: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 23,
                      ),
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

  // ============================================================
  // WHATSAPP STYLE MESSAGE
  // ============================================================

  Widget _buildMessageBubble({
    required Map<String, String> wish,
    required bool isMe,
  }) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,

      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),

        margin: const EdgeInsets.only(bottom: 10),

        padding: const EdgeInsets.fromLTRB(13, 10, 10, 7),

        decoration: BoxDecoration(
          // --------------------------------------------
          // WhatsApp-like bubble colors
          // --------------------------------------------
          color: isMe ? const Color(0xffD9FDD3) : Colors.white,

          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),

            bottomLeft: Radius.circular(isMe ? 16 : 4),

            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),

          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // ======================================================
            // NAME
            // ======================================================
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(bottom: 3),

                child: Text(
                  wish["name"]!,

                  style: const TextStyle(
                    color: Color(0xff1565C0),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            // ======================================================
            // MESSAGE + TIME
            // ======================================================
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,

              children: [
                // MESSAGE
                Flexible(
                  child: Text(
                    wish["message"]!,

                    style: const TextStyle(
                      color: Color(0xff172033),
                      fontSize: 15,
                      height: 1.35,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // TIME
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      wish["time"]!,

                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                    ),

                    // WhatsApp-style double tick
                    if (isMe) ...[
                      const SizedBox(width: 3),

                      const Icon(
                        Icons.done_all,
                        size: 15,
                        color: Color(0xff34B7F1),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
