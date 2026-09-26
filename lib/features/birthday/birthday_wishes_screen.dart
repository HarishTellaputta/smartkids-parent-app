import 'package:flutter/material.dart';

import '../../features/birthday/models/birthday_chat_message.dart';
import '../../features/birthday/models/student_birthday_chat.dart';
import '../../services/api_service.dart';
import '../../storage/local_storage.dart';

class BirthdayWishesScreen extends StatefulWidget {
  /// Optional.
  ///
  /// If studentId is provided, that particular student's
  /// birthday chat will be opened.
  ///
  /// If null, the first birthday returned by backend will be used.
  final int? studentId;

  const BirthdayWishesScreen({super.key, this.studentId});

  @override
  State<BirthdayWishesScreen> createState() => _BirthdayWishesScreenState();
}

class _BirthdayWishesScreenState extends State<BirthdayWishesScreen> {
  final TextEditingController wishController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  StudentBirthdayChat? birthdayData;

  List<BirthdayChatMessage> wishes = [];

  int? loggedInUserId;

  bool isLoading = true;
  bool isSending = false;
  bool showPhoto = true;

  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBirthdayData();
  }

  @override
  void dispose() {
    wishController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD BIRTHDAY DATA
  // ============================================================

  Future<void> _loadBirthdayData() async {
    print('');
    print('════════════════════════════════════════════════════');
    print('🎂 BIRTHDAY SCREEN: _loadBirthdayData START');
    print('🎂 Widget studentId = ${widget.studentId}');
    print('════════════════════════════════════════════════════');

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // ------------------------------------------------------------
      // LOGGED IN USER
      // ------------------------------------------------------------
      loggedInUserId = await LocalStorage.getUserId();

      print('👤 Logged-in userId = $loggedInUserId');

      // ------------------------------------------------------------
      // GET BIRTHDAY CHAT
      // ------------------------------------------------------------
      print('📡 Calling ApiService.getBirthdayChat()...');

      final response = await ApiService.getBirthdayChat();

      print('🎂 Birthday API status = ${response.statusCode}');
      print('🎂 Birthday API raw response = ${response.body}');

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Unable to load birthday information (${response.statusCode})',
        );
      }

      // ------------------------------------------------------------
      // DECODE RESPONSE
      // ------------------------------------------------------------
      final decoded = ApiService.decodeResponse(response);

      print('🎂 Birthday decoded type = ${decoded.runtimeType}');
      print('🎂 Birthday decoded data = $decoded');

      if (decoded is! List) {
        throw Exception('Invalid birthday response');
      }

      print('🎂 Birthday list count = ${decoded.length}');

      // ------------------------------------------------------------
      // PARSE BIRTHDAY LIST
      // ------------------------------------------------------------
      final birthdayList = decoded.map((item) {
        print('🎂 Parsing birthday item = $item');

        final parsed = StudentBirthdayChat.fromJson(
          item as Map<String, dynamic>,
        );

        print(
          '✅ Parsed birthday: '
          'studentId=${parsed.studentId}, '
          'studentName=${parsed.studentName}, '
          'admissionNo=${parsed.admissionNo}, '
          'photoUrl=${parsed.photoUrl}',
        );

        return parsed;
      }).toList();

      print('🎂 Parsed birthdayList count = ${birthdayList.length}');

      if (birthdayList.isEmpty) {
        throw Exception('No birthday information available');
      }

      // ------------------------------------------------------------
      // SELECT STUDENT
      // ------------------------------------------------------------
      StudentBirthdayChat selectedBirthday;

      if (widget.studentId != null) {
        print('🎯 Looking for birthday studentId = ${widget.studentId}');

        final matchingStudent = birthdayList.where(
          (item) => item.studentId == widget.studentId,
        );

        print('🎯 Matching birthday students = ${matchingStudent.length}');

        if (matchingStudent.isEmpty) {
          print('❌ No matching birthday found');
          throw Exception('Birthday information not found');
        }

        selectedBirthday = matchingStudent.first;
      } else {
        print('🎯 No studentId provided. Using first birthday.');

        selectedBirthday = birthdayList.first;
      }

      print(
        '🎂 SELECTED BIRTHDAY -> '
        'studentId=${selectedBirthday.studentId}, '
        'studentName=${selectedBirthday.studentName}',
      );

      birthdayData = selectedBirthday;

      // ------------------------------------------------------------
      // LOAD CHAT MESSAGES
      // ------------------------------------------------------------
      print(
        '💬 Loading birthday messages for '
        'studentId=${selectedBirthday.studentId}',
      );

      await _loadMessages(selectedBirthday.studentId);

      print('💬 Birthday messages loaded = ${wishes.length}');

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      print('✅ BIRTHDAY SCREEN LOAD SUCCESS');

      _scrollToBottom();
    } catch (e, stackTrace) {
      print('');
      print('════════════════════════════════════════════════════');
      print('❌ BIRTHDAY SCREEN LOAD ERROR');
      print('❌ Error = $e');
      print('❌ StackTrace = $stackTrace');
      print('════════════════════════════════════════════════════');

      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  // ============================================================
  // LOAD MESSAGES
  // ============================================================

  Future<void> _loadMessages(int studentId) async {
    final response = await ApiService.getBirthdayMessages(studentId);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Unable to load birthday wishes (${response.statusCode})',
      );
    }

    final decoded = ApiService.decodeResponse(response);

    if (decoded is! List) {
      throw Exception('Invalid birthday messages response');
    }

    wishes = decoded
        .map(
          (item) => BirthdayChatMessage.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  // ============================================================
  // SEND WISH
  // ============================================================

  Future<void> sendWish() async {
    final message = wishController.text.trim();

    if (message.isEmpty) {
      return;
    }

    final student = birthdayData;

    if (student == null) {
      return;
    }

    if (isSending) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      isSending = true;
    });

    try {
      final response = await ApiService.sendBirthdayMessage(
        student.studentId,
        message,
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception(
          'Unable to send birthday wish (${response.statusCode})',
        );
      }

      wishController.clear();

      // Refresh chat from backend
      await _loadMessages(student.studentId);

      if (!mounted) return;

      setState(() {
        isSending = false;
      });

      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSending = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _toggleReaction(
    BirthdayChatMessage wish,
    String reaction,
  ) async {
    try {
      final existingReaction = wish.reactions.where(
        (item) => item.reaction == reaction,
      );

      final alreadyReacted =
          existingReaction.isNotEmpty &&
          existingReaction.first.reactedByCurrentUser;

      final response = alreadyReacted
          ? await ApiService.removeBirthdayReaction(wish.id, reaction)
          : await ApiService.addBirthdayReaction(wish.id, reaction);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Unable to update reaction (${response.statusCode})');
      }

      // Backend response contains the updated message
      final decoded = ApiService.decodeResponse(response);

      if (decoded is Map<String, dynamic>) {
        final updatedMessage = BirthdayChatMessage.fromJson(decoded);

        final index = wishes.indexWhere((item) => item.id == wish.id);

        if (index != -1 && mounted) {
          setState(() {
            wishes[index] = updatedMessage;
          });
        }
      } else {
        // DELETE returns 204, so refresh chat
        final student = birthdayData;

        if (student != null) {
          await _loadMessages(student.studentId);

          if (mounted) {
            setState(() {});
          }
        }
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }
  // ============================================================
  // SCROLL TO LATEST MESSAGE
  // ============================================================

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ============================================================
  // FORMAT TIME
  // ============================================================

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;

    final displayHour = hour == 0
        ? 12
        : hour > 12
        ? hour - 12
        : hour;

    final period = hour >= 12 ? 'PM' : 'AM';

    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xffF5F8FC),

      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Birthday Wishes",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xff1565C0)),
            )
          : errorMessage != null
          ? _buildErrorState()
          : _buildBirthdayContent(keyboardOpen),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cake_outlined, size: 60, color: Color(0xff1565C0)),

            const SizedBox(height: 15),

            Text(
              errorMessage ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _loadBirthdayData,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BIRTHDAY CONTENT
  // ============================================================

  Widget _buildBirthdayContent(bool keyboardOpen) {
    final student = birthdayData!;

    return Column(
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
                    Text(
                      "🎂 Happy Birthday",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: keyboardOpen ? 20 : 27,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: keyboardOpen ? 3 : 6),

                    Text(
                      student.studentName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: keyboardOpen ? 20 : 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: keyboardOpen ? 2 : 5),

                    Text(
                      "Admission No: ${student.admissionNo}",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: keyboardOpen ? 12 : 15,
                      ),
                    ),

                    SizedBox(height: keyboardOpen ? 8 : 14),

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
                            "${wishes.length} Wishes",
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
                  child: _buildStudentPhoto(student, keyboardOpen),
                ),
              ),
            ],
          ),
        ),

        // ========================================================
        // CHAT AREA
        // ========================================================
        Expanded(
          child: wishes.isEmpty
              ? _buildEmptyChat()
              : ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
                  itemCount: wishes.length,
                  itemBuilder: (context, index) {
                    final wish = wishes[index];

                    final bool isMe =
                        loggedInUserId != null &&
                        wish.senderId == loggedInUserId;

                    return _buildMessageBubble(wish);
                  },
                ),
        ),

        // ========================================================
        // MESSAGE INPUT
        // ========================================================
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

                    enabled: !isSending,

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

                  child: isSending
                      ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : IconButton(
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
    );
  }

  // ============================================================
  // STUDENT PHOTO
  // ============================================================

  Widget _buildStudentPhoto(StudentBirthdayChat student, bool keyboardOpen) {
    final photoUrl = student.photoUrl;

    if (!showPhoto || photoUrl == null || photoUrl.trim().isEmpty) {
      return Container(
        color: Colors.white,
        child: Center(
          child: Text(
            student.studentName.isNotEmpty
                ? student.studentName[0].toUpperCase()
                : "?",
            style: TextStyle(
              fontSize: keyboardOpen ? 30 : 48,
              color: const Color(0xff1565C0),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    return Image.network(
      photoUrl,
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
    );
  }

  // ============================================================
  // EMPTY CHAT
  // ============================================================

  Widget _buildEmptyChat() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.chat_bubble_outline, size: 55, color: Colors.grey),

            SizedBox(height: 12),

            Text(
              "No birthday wishes yet",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),

            SizedBox(height: 5),

            Text(
              "Be the first one to send a wish 🎂",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MESSAGE BUBBLE
  // ============================================================

  Widget _buildMessageBubble(BirthdayChatMessage wish) {
    final isMine = wish.senderId == loggedInUserId;

    return GestureDetector(
      onLongPress: () => _showReactionPicker(wish),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMine ? Colors.blue.shade100 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: isMine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (!isMine)
              Text(
                wish.senderName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),

            const SizedBox(height: 4),

            Text(wish.message),

            const SizedBox(height: 4),

            Text(
              _formatTime(wish.createdAt),
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),

            // reactions ikkada
            if (wish.reactions.isNotEmpty)
              Wrap(
                spacing: 4,
                children: wish.reactions.map((reaction) {
                  return GestureDetector(
                    onTap: () => _toggleReaction(wish, reaction.reaction),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: reaction.reactedByCurrentUser
                            ? Colors.blue.shade100
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${reaction.reaction} ${reaction.count}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  void _showReactionPicker(BirthdayChatMessage wish) {
    const reactions = ['❤️', '👍', '😂', '😮', '😢', '👏', '🎉', '🎂'];

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              children: reactions.map((reaction) {
                return InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    _toggleReaction(wish, reaction);
                  },
                  child: Text(reaction, style: const TextStyle(fontSize: 30)),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
