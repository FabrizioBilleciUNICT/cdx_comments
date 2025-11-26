

import 'models/comment.dart';

class CommentController {

  final DataService dataService;
  final ModuleConfig config;
  CommentController({required this.dataService, required this.config});

  Future<List<Comment>> fetchComments(String entityId) async {
    return await dataService.fetchComments(entityId, config, 1);
  }

  Future<Comment?> postComment(String entityId, String content) async {
    final comment = Comment(
        id: '',
        date: DateTime.now(),
        content: content,
        entityId: entityId,
        userId: dataService.user!.uuid!,
        username: dataService.user!.name ?? '',
    );
    return await dataService.postComment(comment, config);
  }

  Future<Comment?> postReply(String entityId, String parentCommentId, String content) async {
    final comment = Comment(
      id: '',
      date: DateTime.now(),
      content: content,
      parentId: parentCommentId,
      entityId: entityId,
      userId: dataService.user!.uuid!,
      username: dataService.user!.name ?? '',
    );
    return await dataService.postReply(comment);
  }

  Future<Comment?> toggleLike(String commentId) async {
    return await dataService.toggleLikeComment(commentId);
  }

  Future<void> deleteComment(String commentId) async {
    await dataService.deleteComment(commentId);
  }

  Future<List<Comment>> getReplies(String commentId) async {
    return await dataService.fetchReplies(commentId, 1);
  }
}