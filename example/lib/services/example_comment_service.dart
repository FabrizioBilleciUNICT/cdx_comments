import 'package:cdx_comments/cdx_comments.dart';

/// Example implementation of CommentService using in-memory storage.
///
/// This is a simple implementation for demonstration purposes.
/// It stores comments in memory and simulates network delays.
///
/// In a real application, you would implement this interface to call your
/// backend API. For example:
///
/// ```dart
/// class ApiCommentService implements CommentService {
///   final ApiClient _api;
///
///   @override
///   Future<List<Comment>> fetchComments(...) async {
///     final response = await _api.get('/comments/$entityId');
///     return (response.data as List).map((json) => 
///       Comment.fromJson(json, currentUserId: _currentUserId)
///     ).toList();
///   }
///   // ... implement other methods
/// }
/// ```
class ExampleCommentService implements CommentService {
  final Map<String, List<Comment>> _commentsByEntity = {};
  final Map<String, Comment> _commentsById = {};
  final Map<String, List<Comment>> _repliesByParent = {};
  final Map<String, Set<String>> _likesByComment = {};
  int _nextId = 1;

  @override
  Future<List<Comment>> fetchComments(
    String entityId,
    CommentConfig config,
    int page,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Return only root comments (comments without a parent)
    return _commentsByEntity[entityId]
            ?.where((c) => c.parentId == null)
            .toList() ??
        [];
  }

  @override
  Future<Comment?> postComment(Comment comment, CommentConfig config) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final newComment = comment.copyWith(
      id: 'comment_${_nextId++}',
      date: DateTime.now(),
      likeCount: 0,
      isLiked: false,
    );
    
    _commentsById[newComment.id] = newComment;
    _commentsByEntity.putIfAbsent(comment.entityId, () => []).add(newComment);
    
    return newComment;
  }

  @override
  Future<Comment?> postReply(Comment comment) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final newReply = comment.copyWith(
      id: 'comment_${_nextId++}',
      date: DateTime.now(),
      likeCount: 0,
      isLiked: false,
    );
    
    _commentsById[newReply.id] = newReply;
    _repliesByParent.putIfAbsent(comment.parentId!, () => []).add(newReply);
    
    if (comment.entityId.isNotEmpty) {
      _commentsByEntity.putIfAbsent(comment.entityId, () => []).add(newReply);
    }
    
    return newReply;
  }

  @override
  Future<Comment?> toggleLikeComment(String commentId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final comment = _commentsById[commentId];
    if (comment == null) return null;

    final likes = _likesByComment.putIfAbsent(commentId, () => {});
    final wasLiked = likes.contains('user-1'); // Using 'user-1' as test user
    
    if (wasLiked) {
      likes.remove('user-1');
    } else {
      likes.add('user-1');
    }

    return comment.copyWith(
      isLiked: !wasLiked,
      likeCount: likes.length,
    );
  }

  @override
  Future<void> deleteComment(String commentId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final comment = _commentsById.remove(commentId);
    if (comment != null) {
      _commentsByEntity[comment.entityId]?.removeWhere((c) => c.id == commentId);
      _repliesByParent[comment.parentId ?? '']?.removeWhere((c) => c.id == commentId);
    }
  }

  @override
  Future<List<Comment>> fetchReplies(String commentId, int page) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _repliesByParent[commentId] ?? [];
  }

  @override
  Future<void> sendReportComment(String commentId, String reasonId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // In a real app, send this to your backend
    // ignore: avoid_print
    print('Reported comment $commentId for reason: $reasonId');
  }

  @override
  Future<void> sendReportUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // In a real app, send this to your backend
    // ignore: avoid_print
    print('Reported user: $userId');
  }

  @override
  Future<void> sendBlockUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // In a real app, send this to your backend
    // ignore: avoid_print
    print('Blocked user: $userId');
  }
}

