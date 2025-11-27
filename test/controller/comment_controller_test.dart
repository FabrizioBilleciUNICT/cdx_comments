import 'package:cdx_comments/cdx_comments.dart';
import 'package:flutter_test/flutter_test.dart';
import '../services/in_memory_comment_service.dart';

void main() {
  group('CommentController', () {
    late InMemoryCommentService service;
    late CommentConfig config;
    late UserInfo user;
    late CommentController controller;

    setUp(() {
      service = InMemoryCommentService();
      config = const CommentConfig(badWords: '');
      user = const UserInfo(uuid: 'user-1', name: 'Test User');
      controller = CommentController(
        service: service,
        config: config,
        user: user,
      );
    });

    tearDown(() {
      service.clear();
    });

    test('should fetch comments for an entity', () async {
      // Post a comment first
      await controller.postComment('entity-1', 'Test comment');
      
      final comments = await controller.fetchComments('entity-1');
      expect(comments.length, 1);
      expect(comments.first.content, 'Test comment');
    });

    test('should post a new comment', () async {
      final comment = await controller.postComment('entity-1', 'New comment');
      
      expect(comment, isNotNull);
      expect(comment!.content, 'New comment');
      expect(comment.entityId, 'entity-1');
      expect(comment.userId, user.uuid);
      expect(comment.username, user.name);
    });

    test('should post a reply to a comment', () async {
      final parent = await controller.postComment('entity-1', 'Parent comment');
      expect(parent, isNotNull);

      final reply = await controller.postReply(
        'entity-1',
        parent!.id,
        'Reply comment',
      );

      expect(reply, isNotNull);
      expect(reply!.content, 'Reply comment');
      expect(reply.parentId, parent.id);
      expect(reply.userId, user.uuid);
    });

    test('should toggle like on a comment', () async {
      final comment = await controller.postComment('entity-1', 'Test');
      expect(comment, isNotNull);

      final liked = await controller.toggleLike(comment!.id);
      expect(liked, isNotNull);
      expect(liked!.isLiked, true);
      expect(liked.likeCount, 1);

      final unliked = await controller.toggleLike(comment.id);
      expect(unliked, isNotNull);
      expect(unliked!.isLiked, false);
      expect(unliked.likeCount, 0);
    });

    test('should delete a comment', () async {
      final comment = await controller.postComment('entity-1', 'To delete');
      expect(comment, isNotNull);

      await controller.deleteComment(comment!.id);

      final comments = await controller.fetchComments('entity-1');
      expect(comments.where((c) => c.id == comment.id), isEmpty);
    });

    test('should fetch replies for a comment', () async {
      final parent = await controller.postComment('entity-1', 'Parent');
      expect(parent, isNotNull);

      await controller.postReply('entity-1', parent!.id, 'Reply 1');
      await controller.postReply('entity-1', parent.id, 'Reply 2');

      final replies = await controller.getReplies(parent.id);
      expect(replies.length, 2);
    });
  });
}

