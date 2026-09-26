class BirthdayChatMessage {
  final int id;
  final int studentId;
  final int senderId;
  final String senderName;
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
    required this.message,
    required this.edited,
    required this.deleted,
    required this.createdAt,
    this.updatedAt,
    this.replyToMessageId,
    this.replyToMessage,
    required this.reactions,
  });

  factory BirthdayChatMessage.fromJson(
    Map<String, dynamic> json,
  ) {
    return BirthdayChatMessage(
      id: json['id'] as int,
      studentId: json['studentId'] as int,
      senderId: json['senderId'] as int,
      senderName: json['senderName'] ?? '',
      message: json['message'] ?? '',
      edited: json['edited'] ?? false,
      deleted: json['deleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      replyToMessageId: json['replyToMessageId'],
      replyToMessage: json['replyToMessage'],
      reactions: (json['reactions'] as List<dynamic>? ?? [])
          .map(
            (reaction) => BirthdayChatReaction.fromJson(
              reaction as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
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

  factory BirthdayChatReaction.fromJson(
    Map<String, dynamic> json,
  ) {
    return BirthdayChatReaction(
      reaction: json['reaction'] ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
      reactedByCurrentUser:
          json['reactedByCurrentUser'] ?? false,
    );
  }
}