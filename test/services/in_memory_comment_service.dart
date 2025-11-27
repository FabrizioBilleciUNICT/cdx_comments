import 'package:cdx_comments/cdx_comments.dart';

/// In-memory implementation of CommentService for testing
class InMemoryCommentService implements CommentService {
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
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate network delay
    return _commentsByEntity[entityId]?.where((c) => c.parentId == null).toList() ?? [];
  }

  @override
  Future<Comment?> postComment(Comment comment, CommentConfig config) async {
    await Future.delayed(const Duration(milliseconds: 100));
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
    await Future.delayed(const Duration(milliseconds: 100));
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
    await Future.delayed(const Duration(milliseconds: 100));
    final comment = _commentsById[commentId];
    if (comment == null) return null;

    final likes = _likesByComment.putIfAbsent(commentId, () => {});
    final wasLiked = likes.contains('user'); // Simplified: using 'user' as test user
    
    if (wasLiked) {
      likes.remove('user');
    } else {
      likes.add('user');
    }

    return comment.copyWith(
      isLiked: !wasLiked,
      likeCount: likes.length,
    );
  }

  @override
  Future<void> deleteComment(String commentId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final comment = _commentsById.remove(commentId);
    if (comment != null) {
      _commentsByEntity[comment.entityId]?.removeWhere((c) => c.id == commentId);
      _repliesByParent[comment.parentId ?? '']?.removeWhere((c) => c.id == commentId);
    }
  }

  @override
  Future<List<Comment>> fetchReplies(String commentId, int page) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _repliesByParent[commentId] ?? [];
  }

  @override
  Future<void> sendReportComment(String commentId, String reasonId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    // In-memory: just simulate the call
  }

  @override
  Future<void> sendReportUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    // In-memory: just simulate the call
  }

  @override
  Future<void> sendBlockUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    // In-memory: just simulate the call
  }

  /// Clear all data (useful for test cleanup)
  void clear() {
    _commentsByEntity.clear();
    _commentsById.clear();
    _repliesByParent.clear();
    _likesByComment.clear();
    _nextId = 1;
  }
}

