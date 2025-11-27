/// Represents a comment with support for nested replies.
///
/// A comment can be either a root comment (top-level) or a reply to another comment.
/// Root comments have [parentId] set to `null`, while replies have it set to the parent's ID.
///
/// Example:
/// ```dart
/// final comment = Comment(
///   id: 'comment-1',
///   date: DateTime.now(),
///   content: 'This is a comment',
///   entityId: 'post-123',
///   userId: 'user-1',
///   username: 'John Doe',
///   likeCount: 5,
///   isLiked: false,
/// );
/// ```
class Comment {
  /// Unique identifier for this comment.
  final String id;
  
  /// Date and time when the comment was created.
  final DateTime date;
  
  /// ID of the parent comment, if this is a reply.
  ///
  /// `null` for root comments, non-null for replies.
  final String? parentId;
  
  /// The text content of the comment.
  final String content;
  
  /// ID of the entity (post, article, etc.) this comment belongs to.
  final String entityId;
  
  /// ID of the user who created this comment.
  final String userId;
  
  /// Display name of the user who created this comment.
  final String username;
  
  /// Number of likes this comment has received.
  ///
  /// Can be `null` if likes are not enabled or not yet loaded.
  final int? likeCount;
  
  /// Number of replies this comment has.
  ///
  /// Can be `null` if reply count is not available.
  /// This may differ from [replies].length if replies are not yet loaded.
  int? replyCount;
  
  /// Whether the current user has liked this comment.
  ///
  /// `null` if the like status is not available.
  final bool? isLiked;

  /// Whether this comment was created by the current user.
  ///
  /// This is a UI-only property, not present in the API response.
  /// Used to determine if the user can edit/delete this comment.
  final bool isMine;
  
  /// List of direct replies to this comment.
  ///
  /// This is a UI-only property for managing nested replies.
  /// The list may be empty even if [replyCount] > 0 if replies haven't been loaded yet.
  final List<Comment> replies;

  /// Creates a new [Comment].
  ///
  /// Required parameters:
  /// - [id]: Unique identifier
  /// - [date]: Creation date and time
  /// - [content]: Comment text
  /// - [entityId]: ID of the entity this comment belongs to
  /// - [userId]: ID of the comment author
  /// - [username]: Display name of the comment author
  ///
  /// Optional parameters:
  /// - [parentId]: ID of parent comment (for replies)
  /// - [likeCount]: Number of likes (default: `null`)
  /// - [replyCount]: Number of replies (default: `null`)
  /// - [isLiked]: Whether current user liked it (default: `null`)
  /// - [isMine]: Whether current user created it (default: `false`)
  /// - [replies]: List of direct replies (default: empty list)
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

  /// Gets the initials for the comment author.
  ///
  /// For names with multiple words, takes the first letter of the first two words.
  /// For single words, takes the first 1-2 characters.
  /// Returns '??' if the username is empty.
  ///
  /// Examples:
  /// - "John Doe" -> "JD"
  /// - "Alice" -> "AL"
  /// - "A" -> "A"
  /// - "" -> "??"
  String get initials {
    if (username.isEmpty) return '??';
    final words = username.trim().split(RegExp(r'\s+'));
    if (words.length >= 2) {
      return (words[0][0] + words[1][0]).toUpperCase();
    }
    return username.length >= 2 
        ? username.substring(0, 2).toUpperCase()
        : username.substring(0, 1).toUpperCase();
  }
  
  /// Whether this is a root comment (not a reply).
  ///
  /// Returns `true` if [parentId] is `null`, `false` otherwise.
  bool get isRoot => parentId == null;

  /// Creates a copy of this comment with the given fields replaced.
  ///
  /// All parameters are optional. If a parameter is not provided,
  /// the value from this comment is used.
  ///
  /// Returns a new [Comment] instance with updated values.
  ///
  /// Example:
  /// ```dart
  /// final updated = comment.copyWith(
  ///   likeCount: comment.likeCount! + 1,
  ///   isLiked: true,
  /// );
  /// ```
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

  /// Creates a [Comment] from a JSON map.
  ///
  /// The JSON should contain the following fields:
  /// - `id`: String (required)
  /// - `date`: ISO 8601 date string (required)
  /// - `parentId`: String? (optional, for replies)
  /// - `content`: String (required)
  /// - `entityId`: String (required)
  /// - `userId`: String (required)
  /// - `username`: String (required)
  /// - `likeCount`: int? (optional, defaults to 0)
  /// - `replyCount`: int? (optional, defaults to 0)
  /// - `isLiked`: bool? (optional, defaults to false)
  ///
  /// [json] is the JSON map to parse.
  /// [currentUserId] is used to determine if [isMine] should be `true`.
  /// [replies] is an optional list of replies to include.
  ///
  /// Returns a new [Comment] instance.
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



  /// Converts this comment to a JSON map.
  ///
  /// Only includes fields that should be sent to the server.
  /// Excludes computed properties like [initials] and UI-only properties.
  ///
  /// Returns a map with the following fields:
  /// - `id`: String
  /// - `parentId`: String? (only if not null)
  /// - `content`: String
  /// - `entityId`: String
  /// - `userId`: String
  /// - `username`: String
  ///
  /// Note: `date`, `likeCount`, and `replyCount` are excluded as they
  /// are typically managed by the server.
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
