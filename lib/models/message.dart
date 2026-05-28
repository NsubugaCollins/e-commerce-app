class ChatMessage {
  final int id;
  final int senderId;
  final int receiverId;
  final String? senderName;
  final String message;
  final bool isRead;
  final String? reaction;
  final String? mediaUrl;
  final String? mediaType;
  final String? createdAt;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.senderName,
    required this.message,
    this.isRead = false,
    this.reaction,
    this.mediaUrl,
    this.mediaType,
    this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as int,
      senderId: json['sender_id'] as int,
      receiverId: json['receiver_id'] as int,
      senderName: json['sender_name'] as String?,
      message: json['message'] as String? ?? '',
      isRead: json['is_read'] == true,
      reaction: json['reaction'] as String?,
      mediaUrl: json['media_url'] as String?,
      mediaType: json['media_type'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }
}

class MessageThread {
  final int id;
  final String name;
  final String email;
  final int unreadCount;

  MessageThread({
    required this.id,
    required this.name,
    required this.email,
    required this.unreadCount,
  });

  factory MessageThread.fromJson(Map<String, dynamic> json) {
    return MessageThread(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      unreadCount: (json['unread_count'] as num?)?.toInt() ?? 0,
    );
  }
}
