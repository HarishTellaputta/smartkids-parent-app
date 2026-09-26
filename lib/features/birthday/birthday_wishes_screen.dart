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

  final FocusNode wishFocusNode = FocusNode();

  BirthdayChatMessage? replyingTo;
  BirthdayChatMessage? editingMessage;

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
    wishFocusNode.dispose();
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
      final birthdayList = decoded
          .map((item) {
            print('🎂 Parsing birthday item = $item');

            final parsed = StudentBirthdayChat.fromJson(
              item as Map<String, dynamic>,
            );

            print(
              '✅ Parsed birthday: '
              'studentId=${parsed.studentId}, '
              'studentName=${parsed.studentName}, '
              'birthdayToday=${parsed.birthdayToday}, '
              'photoUrl=${parsed.photoUrl}',
            );

            return parsed;
          })
          .where((item) => item.birthdayToday)
          .toList();

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

    if (message.isEmpty || isSending) {
      return;
    }

    final student = birthdayData;

    if (student == null) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      isSending = true;
    });

    try {
      // ==========================================================
      // EDIT MESSAGE
      // ==========================================================

      if (editingMessage != null) {
        final messageToEdit = editingMessage!;

        final response = await ApiService.editBirthdayMessage(
          messageToEdit.id,
          message,
        );

        if (response.statusCode < 200 || response.statusCode >= 300) {
          throw Exception(
            'Unable to edit birthday wish (${response.statusCode})',
          );
        }

        wishController.clear();

        editingMessage = null;

        await _loadMessages(student.studentId);

        if (!mounted) return;

        setState(() {
          isSending = false;
        });

        _scrollToBottom();
        return;
      }

      // ==========================================================
      // REPLY MESSAGE
      // ==========================================================

      if (replyingTo != null) {
        final messageToReply = replyingTo!;

        final response = await ApiService.replyToBirthdayMessage(
          messageToReply.id,
          message,
        );

        if (response.statusCode < 200 || response.statusCode >= 300) {
          throw Exception('Unable to send reply (${response.statusCode})');
        }

        wishController.clear();

        replyingTo = null;

        await _loadMessages(student.studentId);

        if (!mounted) return;

        setState(() {
          isSending = false;
        });

        _scrollToBottom();
        return;
      }

      // ==========================================================
      // NORMAL NEW MESSAGE
      // ==========================================================

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

  Future<void> _deleteMessage(BirthdayChatMessage wish) async {
    if (wish.deleted || wish.senderId != loggedInUserId) {
      return;
    }

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete message?'),
          content: const Text('This birthday wish will be deleted.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    try {
      final response = await ApiService.deleteBirthdayMessage(wish.id);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Unable to delete message (${response.statusCode})');
      }

      final student = birthdayData;

      if (student != null) {
        await _loadMessages(student.studentId);
      }

      if (!mounted) return;

      setState(() {});
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  void _showMessageActions(BirthdayChatMessage wish) {
    final isMine = wish.senderId == loggedInUserId;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 18),

                // REPLY
                ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.reply)),
                  title: const Text('Reply'),
                  onTap: () {
                    Navigator.pop(context);
                    _startReply(wish);
                  },
                ),

                // REACTION
                ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.emoji_emotions_outlined),
                  ),
                  title: const Text('React'),
                  onTap: () {
                    Navigator.pop(context);

                    Future.delayed(const Duration(milliseconds: 200), () {
                      if (mounted) {
                        _showReactionPicker(wish);
                      }
                    });
                  },
                ),

                // EDIT
                if (isMine && !wish.deleted)
                  ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.edit)),
                    title: const Text('Edit'),
                    onTap: () {
                      Navigator.pop(context);
                      _startEdit(wish);
                    },
                  ),

                // DELETE
                if (isMine && !wish.deleted)
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.red.shade50,
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                    ),
                    title: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _deleteMessage(wish);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _startEdit(BirthdayChatMessage wish) async {
    if (wish.deleted) return;

    setState(() {
      editingMessage = wish;
      replyingTo = null;
      wishController.text = wish.message;
    });

    wishFocusNode.requestFocus();

    await Future.delayed(const Duration(milliseconds: 100));
    _scrollToBottom();
  }

  void _startReply(BirthdayChatMessage wish) {
    if (wish.deleted) return;

    setState(() {
      replyingTo = wish;
      editingMessage = null;
    });

    wishFocusNode.requestFocus();

    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollToBottom();
    });
  }

  void _cancelMessageAction() {
    setState(() {
      replyingTo = null;
      editingMessage = null;
      wishController.clear();
    });
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

  void _scrollToBottom({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !scrollController.hasClients) {
        return;
      }

      final maxScroll = scrollController.position.maxScrollExtent;

      if (animated) {
        scrollController.animateTo(
          maxScroll,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        scrollController.jumpTo(maxScroll);
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
                    focusNode: wishFocusNode,

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
    final isMine = loggedInUserId != null && wish.senderId == loggedInUserId;

    // ==========================================================
    // DELETED MESSAGE
    // ==========================================================

    if (wish.deleted) {
      return Align(
        alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.block, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Text(
                'This message was deleted',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: () => _showMessageActions(wish),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78,
          ),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: const EdgeInsets.fromLTRB(12, 9, 12, 7),
          decoration: BoxDecoration(
            color: isMine ? const Color(0xffDCF8C6) : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isMine ? 16 : 4),
              bottomRight: Radius.circular(isMine ? 4 : 16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================================================
              // SENDER NAME
              // ==================================================

              if (!isMine)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    wish.senderName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff1565C0),
                    ),
                  ),
                ),

              // ==================================================
              // REPLIED MESSAGE
              // ==================================================
              if (wish.replyToMessageId != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 7),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: isMine
                        ? Colors.white.withOpacity(0.65)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: const Border(
                      left: BorderSide(color: Color(0xff1565C0), width: 3),
                    ),
                  ),
                  child: Text(
                    wish.replyToMessage?.isNotEmpty == true
                        ? wish.replyToMessage!
                        : 'Replied message',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ),

              // ==================================================
              // MESSAGE + TIME
              // ==================================================
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      wish.message,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xff172033),
                        height: 1.3,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  Text(
                    _formatTime(wish.createdAt),
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                  ),

                  if (wish.edited)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        'edited',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.grey.shade500,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),

                  if (isMine)
                    const Padding(
                      padding: EdgeInsets.only(left: 3),
                      child: Icon(
                        Icons.done_all,
                        size: 15,
                        color: Color(0xff2196F3),
                      ),
                    ),
                ],
              ),

              // ==================================================
              // REACTIONS
              // ==================================================
              if (wish.reactions.isNotEmpty) ...[
                const SizedBox(height: 5),

                Wrap(
                  spacing: 4,
                  runSpacing: 3,
                  children: wish.reactions.map((reaction) {
                    return GestureDetector(
                      onTap: () => _toggleReaction(wish, reaction.reaction),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: reaction.reactedByCurrentUser
                              ? const Color(0xffE3F2FD)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: reaction.reactedByCurrentUser
                                ? const Color(0xff90CAF9)
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          '${reaction.reaction} ${reaction.count}',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputActionPreview() {
    final bool isEditing = editingMessage != null;
    final message = isEditing ? editingMessage! : replyingTo!;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(left: 4, right: 4, bottom: 8),
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      decoration: BoxDecoration(
        color: const Color(0xffF1F3F5),
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(color: Color(0xff1565C0), width: 4),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing
                      ? 'Editing message'
                      : 'Replying to ${message.senderName}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff1565C0),
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  message.message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: _cancelMessageAction,
            icon: const Icon(Icons.close, size: 20),
          ),
        ],
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
