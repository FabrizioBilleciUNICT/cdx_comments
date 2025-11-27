import '../models/comment.dart';
import '../models/comment_config.dart';

/// Service interface for comment operations
abstract class CommentService {
  /// Fetch comments for an entity
  Future<List<Comment>> fetchComments(
    String entityId,
    CommentConfig config,
    int page,
  );
  
  /// Post a new comment
  Future<Comment?> postComment(Comment comment, CommentConfig config);
  
  /// Post a reply to a comment
  Future<Comment?> postReply(Comment comment);
  
  /// Toggle like on a comment
  Future<Comment?> toggleLikeComment(String commentId);
  
  /// Delete a comment
  Future<void> deleteComment(String commentId);
  
  /// Fetch replies for a comment
  Future<List<Comment>> fetchReplies(String commentId, int page);
  
  /// Send a report for a comment
  Future<void> sendReportComment(String commentId, String reasonId);
  
  /// Send a report for a user
  Future<void> sendReportUser(String userId);
  
  /// Block a user
  Future<void> sendBlockUser(String userId);
}

