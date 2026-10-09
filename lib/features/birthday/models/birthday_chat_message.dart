class BirthdayChatMessage {
  final int id;
  final int studentId;
  final int senderId;
  final String senderName;
  final String? senderUsername;
  final String message;
  final bool edited;
  final bool deleted;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int? replyToMessageId;
  final String? replyToMessage;
  final List<BirthdayChatReaction> reactions;

  BirthdayChatMessage({
    required this.id,
    required this.studentId,
    required this.senderId,
    required this.senderName,
    this.senderUsername,
    required this.message,
    required this.edited,
    required this.deleted,
    required this.createdAt,
    this.updatedAt,
    this.replyToMessageId,
    this.replyToMessage,
    required this.reactions,
  });

  factory BirthdayChatMessage.fromJson(Map<String, dynamic> json) {
    final reactionData = json['reactions'];

    return BirthdayChatMessage(
      id: _toInt(json['id']) ?? 0,
      studentId: _toInt(json['studentId']) ?? 0,
      senderId: _toInt(json['senderId']) ?? 0,
      senderName: _toString(json['senderName']) ?? '',
      senderUsername: _toString(json['senderUsername']),
      message: _toString(json['message']) ?? '',
      edited: json['edited'] == true || json['isEdited'] == true,
      deleted: json['deleted'] == true || json['isDeleted'] == true,
      createdAt: _toDateTime(json['createdAt']) ?? DateTime.now(),
      updatedAt: _toDateTime(json['updatedAt']),
      replyToMessageId: _toInt(
        json['replyToMessageId'] ?? json['parentMessageId'],
      ),
      replyToMessage: _toString(json['replyToMessage']),
      reactions: reactionData is List
          ? reactionData
              .whereType<Map>()
              .map(
                (item) => BirthdayChatReaction.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : <BirthdayChatReaction>[],
    );
  }

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value == null) return null;
    return int.tryParse(value.toString());
  }

  static String? _toString(dynamic value) {
    return value?.toString();
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}

class BirthdayChatReaction {
  final String reaction;
  final int count;
  final bool reactedByCurrentUser;

  BirthdayChatReaction({
    required this.reaction,
    required this.count,
    required this.reactedByCurrentUser,
  });

  factory BirthdayChatReaction.fromJson(Map<String, dynamic> json) {
    final rawCount = json['count'];

    return BirthdayChatReaction(
      reaction: json['reaction']?.toString() ?? '',
      count: rawCount is num
          ? rawCount.toInt()
          : int.tryParse(rawCount?.toString() ?? '') ?? 0,
      reactedByCurrentUser: json['reactedByCurrentUser'] == true,
    );
  }
}