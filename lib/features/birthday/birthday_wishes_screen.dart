import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import '../../features/birthday/models/birthday_chat_message.dart';
import '../../features/birthday/models/student_birthday_chat.dart';
import '../../services/api_service.dart';
import '../../services/birthday_chat_service.dart';
import '../../storage/local_storage.dart';

class BirthdayWishesScreen extends StatefulWidget {
  /// If provided, opens that student's birthday chat.
  /// If null, opens the first birthday returned by backend.
  final int? studentId;

  const BirthdayWishesScreen({super.key, this.studentId});

  @override
  State<BirthdayWishesScreen> createState() => _BirthdayWishesScreenState();
}

class _BirthdayWishesScreenState extends State<BirthdayWishesScreen>
    with TickerProviderStateMixin {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color primary = Color(0xFF1565C0);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color background = Color(0xFFF5F7FA);
  static const Color textDark = Color(0xFF172033);
  static const Color textMuted = Color(0xFF697386);
  static const Color myBubble = Color(0xFFE5F5D0);

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController wishController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final FocusNode wishFocusNode = FocusNode();

  // ============================================================
  // DATA
  // ============================================================

  StudentBirthdayChat? birthdayData;

  List<BirthdayChatMessage> wishes = [];

  int? loggedInUserId;

  BirthdayChatMessage? replyingTo;
  BirthdayChatMessage? editingMessage;
  Timer? _refreshTimer;
  bool _isSilentRefreshing = false;

  // ============================================================
  // STATE
  // ============================================================

  bool isLoading = true;
  bool isSending = false;

  String? errorMessage;

  // ============================================================
  // ANIMATION
  // ============================================================

  late final AnimationController _headerAnimationController;

  @override
  void initState() {
    super.initState();

    _headerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    wishFocusNode.addListener(() {
      if (wishFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            _scrollToBottom();
          }
        });
      }
    });

    _loadBirthdayData();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();

    wishController.dispose();
    scrollController.dispose();
    wishFocusNode.dispose();

    _headerAnimationController.dispose();

    super.dispose();
  }

  // ============================================================
  // LOAD BIRTHDAY DATA
  // ============================================================

  Future<void> _loadBirthdayData() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      loggedInUserId = await LocalStorage.getUserId();

      final response = await BirthdayChatService.getBirthdayChat();

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Unable to load birthday information (${response.statusCode})',
        );
      }

      final decoded = ApiService.decodeResponse(response);

      if (decoded is! List) {
        throw Exception('Invalid birthday response');
      }

      final birthdayList = decoded
          .map(
            (item) =>
                StudentBirthdayChat.fromJson(item as Map<String, dynamic>),
          )
          .where((item) => item.birthdayToday)
          .toList();

      if (birthdayList.isEmpty) {
        throw Exception('No birthday information available');
      }

      StudentBirthdayChat selectedBirthday;

      if (widget.studentId != null) {
        final matchingStudent = birthdayList.where(
          (item) => item.studentId == widget.studentId,
        );

        if (matchingStudent.isEmpty) {
          throw Exception('Birthday information not found');
        }

        selectedBirthday = matchingStudent.first;
      } else {
        selectedBirthday = birthdayList.first;
      }

      birthdayData = selectedBirthday;

      await _loadMessages(selectedBirthday.studentId);

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
      _startAutoRefresh();
      _headerAnimationController.forward();

      _scrollToBottom(animated: false);
    } catch (e) {
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
    final response = await BirthdayChatService.getBirthdayMessages(studentId);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Unable to load birthday messages (${response.statusCode})',
      );
    }

    final dynamic decoded = ApiService.decodeResponse(response);

    if (decoded is! List) {
      throw Exception('Invalid birthday messages response');
    }

    final loadedMessages = decoded
        .whereType<Map>()
        .map(
          (item) =>
              BirthdayChatMessage.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();

    if (!mounted) return;

    setState(() {
      wishes = loadedMessages;
    });
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();

    _refreshTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      final studentId = birthdayData?.studentId;

      if (studentId != null) {
        _silentRefresh(studentId);
      }
    });
  }

  Future<void> _silentRefresh(int studentId) async {
    if (!mounted || _isSilentRefreshing) return;

    _isSilentRefreshing = true;

    try {
      final response = await BirthdayChatService.getBirthdayMessages(studentId);

      if (!mounted || response.statusCode != 200) return;

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! List) return;

      final updatedMessages = decoded
          .whereType<Map>()
          .map(
            (item) =>
                BirthdayChatMessage.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();

      if (!mounted) return;

      if (!_areMessagesEqual(wishes, updatedMessages)) {
        setState(() {
          wishes = updatedMessages;
        });
      }
    } catch (e) {
      debugPrint('Birthday chat background refresh failed: $e');
    } finally {
      _isSilentRefreshing = false;
    }
  }

  bool _areMessagesEqual(
    List<BirthdayChatMessage> oldMessages,
    List<BirthdayChatMessage> newMessages,
  ) {
    if (oldMessages.length != newMessages.length) return false;

    for (var i = 0; i < oldMessages.length; i++) {
      final a = oldMessages[i];
      final b = newMessages[i];

      if (a.id != b.id ||
          a.studentId != b.studentId ||
          a.senderId != b.senderId ||
          a.senderName != b.senderName ||
          a.message != b.message ||
          a.edited != b.edited ||
          a.deleted != b.deleted ||
          a.createdAt != b.createdAt ||
          a.updatedAt != b.updatedAt ||
          a.replyToMessageId != b.replyToMessageId ||
          a.replyToMessage != b.replyToMessage ||
          a.reactions.length != b.reactions.length) {
        return false;
      }

      for (var j = 0; j < a.reactions.length; j++) {
        final oldReaction = a.reactions[j];
        final newReaction = b.reactions[j];

        if (oldReaction.reaction != newReaction.reaction ||
            oldReaction.count != newReaction.count ||
            oldReaction.reactedByCurrentUser !=
                newReaction.reactedByCurrentUser) {
          return false;
        }
      }
    }

    return true;
  }

  // ============================================================
  // SEND / EDIT / REPLY
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
      // ----------------------------------------------------------
      // EDIT
      // ----------------------------------------------------------

      if (editingMessage != null) {
        final messageToEdit = editingMessage!;

        final response = await BirthdayChatService.editBirthdayMessage(
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

      // ----------------------------------------------------------
      // REPLY
      // ----------------------------------------------------------

      if (replyingTo != null) {
        final messageToReply = replyingTo!;

        final response = await BirthdayChatService.replyToBirthdayMessage(
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

      // ----------------------------------------------------------
      // NEW MESSAGE
      // ----------------------------------------------------------

      final response = await BirthdayChatService.sendBirthdayMessage(
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

      _showSnackBar(
        e.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    }
  }

  // ============================================================
  // DELETE MESSAGE
  // ============================================================

  Future<void> _deleteMessage(BirthdayChatMessage wish) async {
    if (wish.deleted || wish.senderId != loggedInUserId) {
      return;
    }

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 26, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Delete message?',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This birthday wish will be deleted.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext, false);
                        },
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext, true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Delete'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    try {
      final response = await BirthdayChatService.deleteBirthdayMessage(wish.id);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Unable to delete message (${response.statusCode})');
      }

      final student = birthdayData;

      if (student != null) {
        await _loadMessages(student.studentId);
      }

      if (!mounted) return;

      setState(() {});

      _showSnackBar('Message deleted');
    } catch (e) {
      if (!mounted) return;

      _showSnackBar(
        e.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    }
  }

  // ============================================================
  // MESSAGE ACTIONS
  // ============================================================

  void _showMessageActions(BirthdayChatMessage wish) {
    final isMine = wish.senderId == loggedInUserId;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),

                // Message preview
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    wish.message,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: textDark,
                      height: 1.4,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                _actionTile(
                  icon: Icons.reply_rounded,
                  title: 'Reply',
                  onTap: () {
                    Navigator.pop(context);
                    _startReply(wish);
                  },
                ),

                _actionTile(
                  icon: Icons.emoji_emotions_outlined,
                  title: 'React',
                  onTap: () {
                    Navigator.pop(context);

                    Future.delayed(const Duration(milliseconds: 180), () {
                      if (mounted) {
                        _showReactionPicker(wish);
                      }
                    });
                  },
                ),

                if (isMine && !wish.deleted)
                  _actionTile(
                    icon: Icons.edit_outlined,
                    title: 'Edit',
                    onTap: () {
                      Navigator.pop(context);
                      _startEdit(wish);
                    },
                  ),

                if (isMine && !wish.deleted)
                  _actionTile(
                    icon: Icons.delete_outline_rounded,
                    title: 'Delete',
                    iconColor: Colors.red,
                    textColor: Colors.red,
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

  Widget _actionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: (iconColor ?? primary).withOpacity(.09),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor ?? primary, size: 21),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: textColor ?? textDark,
        ),
      ),
      onTap: onTap,
    );
  }

  // ============================================================
  // EDIT
  // ============================================================

  Future<void> _startEdit(BirthdayChatMessage wish) async {
    if (wish.deleted) return;

    setState(() {
      editingMessage = wish;
      replyingTo = null;
      wishController.text = wish.message;
      wishController.selection = TextSelection.fromPosition(
        TextPosition(offset: wishController.text.length),
      );
    });

    wishFocusNode.requestFocus();

    await Future.delayed(const Duration(milliseconds: 100));

    _scrollToBottom();
  }

  // ============================================================
  // REPLY
  // ============================================================

  void _startReply(BirthdayChatMessage wish) {
    if (wish.deleted) return;

    setState(() {
      replyingTo = wish;
      editingMessage = null;
    });

    wishFocusNode.requestFocus();

    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  // ============================================================
  // CANCEL EDIT / REPLY
  // ============================================================

  void _cancelMessageAction() {
    setState(() {
      replyingTo = null;
      editingMessage = null;
      wishController.clear();
    });
  }

  // ============================================================
  // REACTIONS
  // ============================================================

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
          ? await BirthdayChatService.removeBirthdayReaction(wish.id, reaction)
          : await BirthdayChatService.addBirthdayReaction(wish.id, reaction);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Unable to update reaction (${response.statusCode})');
      }

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

      _showSnackBar(
        e.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    }
  }

  // ============================================================
  // REACTION PICKER
  // ============================================================

  void _showReactionPicker(BirthdayChatMessage wish) {
    const reactions = ['❤️', '👍', '😂', '😮', '😢', '👏', '🎉', '🎂'];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.12),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: reactions.map((reaction) {
                return InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    Navigator.pop(context);
                    _toggleReaction(wish, reaction);
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: background,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(reaction, style: const TextStyle(fontSize: 26)),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // SCROLL
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
  // TIME FORMAT
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
  // SNACKBAR
  // ============================================================

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: isError
            ? const Color(0xFFB3261E)
            : const Color(0xFF263238),
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      resizeToAvoidBottomInset: true,

      appBar: _buildAppBar(),

      body: isLoading
          ? _buildLoadingState()
          : errorMessage != null
          ? _buildErrorState()
          : _buildBirthdayContent(),
    );
  }

  // ============================================================
  // APP BAR — WHATSAPP STYLE
  // ============================================================

  PreferredSizeWidget _buildAppBar() {
    final student = birthdayData;

    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 1,
      leadingWidth: 44,

      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 20,
          color: textDark,
        ),
      ),

      titleSpacing: 0,

      title: student == null
          ? const Text(
              'Birthday Wishes',
              style: TextStyle(
                color: textDark,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            )
          : Row(
              children: [
                // ------------------------------------------------
                // DP
                // ------------------------------------------------

                Hero(
                  tag: 'birthday_dp_${student.studentId}',
                  child: _buildHeaderAvatar(student),
                ),

                const SizedBox(width: 10),

                // ------------------------------------------------
                // NAME + STATUS
                // ------------------------------------------------
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        student.studentName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: textDark,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF43A047),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            'Birthday Today',
                            style: TextStyle(
                              color: textMuted,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

      actions: [
        IconButton(
          tooltip: 'Refresh',
          onPressed: isLoading
              ? null
              : () async {
                  await _loadBirthdayData();
                },
          icon: const Icon(Icons.refresh_rounded, color: textDark, size: 22),
        ),

        const SizedBox(width: 4),
      ],
    );
  }

  // ============================================================
  // HEADER AVATAR
  // ============================================================

  Widget _buildHeaderAvatar(StudentBirthdayChat student) {
    final photoUrl = student.photoUrl;

    return Container(
      width: 42,
      height: 42,
      padding: const EdgeInsets.all(1.5),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF64B5F6)],
        ),
      ),
      child: ClipOval(
        child: photoUrl != null && photoUrl.trim().isNotEmpty
            ? Image.network(
                photoUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return _buildInitialAvatar(student);
                },
              )
            : _buildInitialAvatar(student),
      ),
    );
  }

  Widget _buildInitialAvatar(StudentBirthdayChat student) {
    final initial = student.studentName.trim().isNotEmpty
        ? student.studentName.trim()[0].toUpperCase()
        : '?';

    return Container(
      color: const Color(0xFFE3F2FD),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          color: primary,
          fontSize: 17,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  // ============================================================
  // LOADING
  // ============================================================

  Widget _buildLoadingState() {
    return Column(
      children: [
        Container(
          height: 66,
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            children: [
              _skeletonCircle(42),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _skeletonBox(130, 12),
                  const SizedBox(height: 8),
                  _skeletonBox(80, 8),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: _messageSkeleton(width: 220),
              ),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerRight,
                child: _messageSkeleton(width: 190),
              ),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerLeft,
                child: _messageSkeleton(width: 250),
              ),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerRight,
                child: _messageSkeleton(width: 170),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _skeletonCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _skeletonBox(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _messageSkeleton({required double width}) {
    return Container(
      width: width,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(18),
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cake_outlined, color: primary, size: 38),
            ),

            const SizedBox(height: 20),

            const Text(
              'Birthday wishes unavailable',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: textDark,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              errorMessage ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: textMuted,
              ),
            ),

            const SizedBox(height: 22),

            ElevatedButton.icon(
              onPressed: _loadBirthdayData,
              icon: const Icon(Icons.refresh_rounded, size: 19),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MAIN CONTENT
  // ============================================================

  Widget _buildBirthdayContent() {
    final student = birthdayData!;

    return Column(
      children: [
        // --------------------------------------------------------
        // SMALL CELEBRATION STRIP
        // --------------------------------------------------------

        _buildCelebrationStrip(student),

        // --------------------------------------------------------
        // CHAT
        // --------------------------------------------------------
        Expanded(
          child: wishes.isEmpty
              ? _buildEmptyChat()
              : ListView.builder(
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(12, 14, 12, 18),
                  itemCount: wishes.length,
                  itemBuilder: (context, index) {
                    return _buildMessageBubble(wishes[index]);
                  },
                ),
        ),

        // --------------------------------------------------------
        // COMPOSER
        // --------------------------------------------------------
        _buildComposer(),
      ],
    );
  }

  // ============================================================
  // CELEBRATION STRIP
  // ============================================================

  Widget _buildCelebrationStrip(StudentBirthdayChat student) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF4F9FF), Color(0xFFEAF4FF)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD7E9FA)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🎂', style: TextStyle(fontSize: 19)),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 13, color: textDark),
                    children: [
                      const TextSpan(text: 'Make '),
                      TextSpan(
                        text: student.studentName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: primary,
                        ),
                      ),
                      const TextSpan(text: '\'s day special!'),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Send a birthday wish 🎉',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${wishes.length}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY CHAT
  // ============================================================

  Widget _buildEmptyChat() {
    final student = birthdayData;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: const BoxDecoration(
                color: Color(0xFFEAF4FF),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🎂', style: TextStyle(fontSize: 38)),
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'Start the celebration',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textDark,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              student == null
                  ? 'Be the first to send a birthday wish!'
                  : 'Be the first to wish ${student.studentName}!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: textMuted,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () {
                wishFocusNode.requestFocus();
              },
              icon: const Icon(Icons.cake_outlined, size: 18),
              label: const Text('Send a Wish'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // COMPOSER
  // ============================================================

  Widget _buildComposer() {
    final hasAction = editingMessage != null || replyingTo != null;

    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(10, 7, 10, 8),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.06),
              blurRadius: 14,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Column(
          children: [
            if (hasAction) _buildInputActionPreview(),

            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F3F5),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: wishFocusNode.hasFocus
                            ? const Color(0xFF90CAF9)
                            : Colors.transparent,
                      ),
                    ),
                    child: TextField(
                      controller: wishController,
                      focusNode: wishFocusNode,
                      enabled: !isSending,
                      minLines: 1,
                      maxLines: 5,
                      textInputAction: TextInputAction.newline,
                      style: const TextStyle(fontSize: 14.5, color: textDark),
                      decoration: InputDecoration(
                        hintText: editingMessage != null
                            ? 'Edit your wish...'
                            : 'Write a birthday wish...',
                        hintStyle: const TextStyle(
                          color: Color(0xFF8A919B),
                          fontSize: 14,
                        ),
                        prefixIcon: IconButton(
                          onPressed: isSending
                              ? null
                              : _showComposerEmojiPicker,
                          tooltip: 'Emojis',
                          icon: const Icon(
                            Icons.emoji_emotions_outlined,
                            size: 22,
                            color: Color(0xFF7A828D),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 11,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // SEND
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primary, Color(0xFF42A5F5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
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
                          tooltip: editingMessage != null ? 'Update' : 'Send',
                          icon: Icon(
                            editingMessage != null
                                ? Icons.check_rounded
                                : Icons.send_rounded,
                            color: Colors.white,
                            size: 21,
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // INPUT ACTION PREVIEW
  // ============================================================

  Widget _buildInputActionPreview() {
    final bool isEditing = editingMessage != null;
    final message = isEditing ? editingMessage! : replyingTo!;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(left: 4, right: 4, bottom: 8),
      padding: const EdgeInsets.fromLTRB(12, 8, 6, 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(13),
        border: const Border(left: BorderSide(color: primary, width: 3.5)),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: primary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  message.message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: textMuted),
                ),
              ],
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: _cancelMessageAction,
            icon: const Icon(Icons.close_rounded, size: 19, color: textMuted),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MESSAGE BUBBLE
  // ============================================================

  Widget _buildMessageBubble(BirthdayChatMessage wish) {
    final isMine = loggedInUserId != null && wish.senderId == loggedInUserId;

    if (wish.deleted) {
      return Align(
        alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.block_rounded, size: 15, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Text(
                'This message was deleted',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                  fontSize: 12.5,
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
            maxWidth: MediaQuery.of(context).size.width * .80,
          ),
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          padding: const EdgeInsets.fromLTRB(12, 9, 10, 7),
          decoration: BoxDecoration(
            color: isMine ? myBubble : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(17),
              topRight: const Radius.circular(17),
              bottomLeft: Radius.circular(isMine ? 17 : 4),
              bottomRight: Radius.circular(isMine ? 4 : 17),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.035),
                blurRadius: 5,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --------------------------------------------------
              // SENDER
              // --------------------------------------------------

              if (!isMine)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    wish.senderName,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: primary,
                    ),
                  ),
                ),

              // --------------------------------------------------
              // REPLY PREVIEW
              // --------------------------------------------------
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
                        ? Colors.white.withOpacity(.62)
                        : const Color(0xFFF3F5F7),
                    borderRadius: BorderRadius.circular(9),
                    border: const Border(
                      left: BorderSide(color: primary, width: 3),
                    ),
                  ),
                  child: Text(
                    wish.replyToMessage?.isNotEmpty == true
                        ? wish.replyToMessage!
                        : 'Replied message',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: textMuted,
                      height: 1.3,
                    ),
                  ),
                ),

              // --------------------------------------------------
              // MESSAGE + TIME
              // --------------------------------------------------
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      wish.message,
                      style: const TextStyle(
                        fontSize: 14.5,
                        color: textDark,
                        height: 1.35,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  Text(
                    _formatTime(wish.createdAt),
                    style: TextStyle(
                      fontSize: 9.5,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  if (wish.edited)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        'edited',
                        style: TextStyle(
                          fontSize: 8.5,
                          color: Colors.grey.shade500,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),

                  if (isMine)
                    const Padding(
                      padding: EdgeInsets.only(left: 3),
                      child: Icon(
                        Icons.done_all_rounded,
                        size: 14,
                        color: Color(0xFF2196F3),
                      ),
                    ),
                ],
              ),

              // --------------------------------------------------
              // REACTIONS
              // --------------------------------------------------
              if (wish.reactions.isNotEmpty) ...[
                const SizedBox(height: 5),
                _buildReactions(wish),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // REACTIONS
  // ============================================================

  Widget _buildReactions(BirthdayChatMessage wish) {
    return Wrap(
      spacing: 4,
      runSpacing: 3,
      children: wish.reactions.map((reaction) {
        final selected = reaction.reactedByCurrentUser;

        return GestureDetector(
          onTap: () => _toggleReaction(wish, reaction.reaction),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFFE3F2FD)
                  : Colors.white.withOpacity(.85),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected
                    ? const Color(0xFF90CAF9)
                    : Colors.grey.shade300,
              ),
            ),
            child: Text(
              '${reaction.reaction} ${reaction.count}',
              style: const TextStyle(fontSize: 10.5),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showComposerEmojiPicker() {
    FocusScope.of(context).unfocus();
    const emojis = [
      '😀',
      '😂',
      '🤣',
      '😊',
      '😍',
      '🥰',
      '😘',
      '😎',
      '🤗',
      '😇',
      '🥳',
      '😢',
      '😭',
      '😮',
      '😡',
      '👍',
      '👏',
      '🙏',
      '❤️',
      '💖',
      '💕',
      '🔥',
      '🎉',
      '🎂',
      '🥳',
      '✨',
      '🌟',
      '💯',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.15),
                  blurRadius: 25,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    const Text(
                      'Emojis',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: textDark,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded, size: 20),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: emojis.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 6,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    final emoji = emojis[index];

                    return InkWell(
                      borderRadius: BorderRadius.circular(14),

                      onTap: () {
                        final currentText = wishController.text;
                        final selection = wishController.selection;

                        final start = selection.start >= 0
                            ? selection.start
                            : currentText.length;

                        final end = selection.end >= 0
                            ? selection.end
                            : currentText.length;

                        final newText =
                            currentText.substring(0, start) +
                            emoji +
                            currentText.substring(end);

                        wishController.value = TextEditingValue(
                          text: newText,
                          selection: TextSelection.collapsed(
                            offset: start + emoji.length,
                          ),
                        );

                        setState(() {});
                      },

                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F7FA),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 26),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
