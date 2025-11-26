
class Comment {
  final String id;
  final DateTime date;
  final String? parentId;
  final String content;
  final String entityId;
  final String userId;
  final String username;
  final int? likeCount;
  int? replyCount;
  final bool? isLiked;

  // Proprietà UI local state (non presenti nell'API)
  final bool isMine;
  final List<Comment> replies;

  Comment({
    required this.id,
    required this.date,
    this.parentId,
    required this.content,
    required this.entityId,
    required this.userId,
    required this.username,
    this.likeCount,
    this.replyCount,
    this.isLiked,
    this.isMine = false,
    this.replies = const [],
  });

  String get initials => username.isNotEmpty
      ? username.substring(0, 2).toUpperCase()
      : '??';
  bool get isRoot => parentId == null;

  Comment copyWith({
    String? id,
    DateTime? date,
    String? parentId,
    String? content,
    String? entityId,
    String? userId,
    String? username,
    int? likeCount,
    int? replyCount,
    bool? isLiked,
    bool? isMine,
    List<Comment>? replies,
  }) {
    return Comment(
      id: id ?? this.id,
      date: date ?? this.date,
      parentId: parentId ?? this.parentId,
      content: content ?? this.content,
      entityId: entityId ?? this.entityId,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      likeCount: likeCount ?? this.likeCount,
      replyCount: replyCount ?? this.replyCount,
      isLiked: isLiked ?? this.isLiked,
      isMine: isMine ?? this.isMine,
      replies: replies ?? this.replies,
    );
  }

  factory Comment.fromJson(Map<String, dynamic> json, {required String? currentUserId, List<Comment>? replies}) {
    return Comment(
      id: json['id'],
      date: DateTime.parse(json['date']),
      parentId: json['parentId'],
      content: json['content'],
      entityId: json['entityId'],
      userId: json['userId'],
      username: json['username'],
      likeCount: json['likeCount'] ?? 0,
      replyCount: json['replyCount'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      isMine: currentUserId != null && currentUserId == json['userId'],
      replies: replies ?? [],
    );
  }



  Map<String, String> toJson() {
    return {
      'id': id,
      //'date': date.toIso8601String(),
      if (parentId != null) 'parentId': parentId!,
      'content': content,
      'entityId': entityId,
      'userId': userId,
      'username': username,
      //'likeCount': likeCount,
      //'replyCount': replyCount,
    };
  }
}
