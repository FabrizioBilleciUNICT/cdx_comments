import 'package:cdx_comments/cdx_comments.dart';
import 'package:cdx_comments/l10n/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';
import '../services/in_memory_comment_service.dart';

void main() {
  group('CommentProvider', () {
    late InMemoryCommentService service;
    late CommentConfig config;
    late UserInfo user;
    late CommentController controller;
    late CommentValidator validator;
    late CommentProvider provider;
    late CdxCommentsLocalizationsEn localizations;

    setUp(() {
      service = InMemoryCommentService();
      config = const CommentConfig(badWords: '');
      user = const UserInfo(uuid: 'user-1', name: 'Test User');
      controller = CommentController(
        service: service,
        config: config,
        user: user,
      );
      validator = CommentValidator(badWordsData: config.badWords);
      provider = CommentProvider(
        controller: controller,
        postId: 'entity-1',
        validator: validator,
      );
      localizations = CdxCommentsLocalizationsEn();
    });

    tearDown(() {
      service.clear();
    });

    test('should initialize with empty comments', () {
      expect(provider.comments, isEmpty);
      expect(provider.replyingTo, isNull);
    });

    test('should load comments', () async {
      await controller.postComment('entity-1', 'Comment 1');
      await controller.postComment('entity-1', 'Comment 2');

      await provider.loadComments();

      expect(provider.comments.length, 2);
    });

    test('should add a comment', () async {
      await provider.addComment('New comment');

      expect(provider.comments.length, 1);
      expect(provider.comments.first.content, 'New comment');
    });

    test('should reply to a comment', () async {
      final parent = await controller.postComment('entity-1', 'Parent');
      expect(parent, isNotNull);

      await provider.loadComments();
      await provider.replyTo('entity-1', parent!.id, 'Reply');

      final parentInList = provider.comments.firstWhere((c) => c.id == parent.id);
      expect(parentInList.replies.length, 1);
      expect(parentInList.replies.first.content, 'Reply');
    });

    test('should toggle like on a comment', () async {
      final comment = await controller.postComment('entity-1', 'Test');
      expect(comment, isNotNull);

      await provider.loadComments();
      await provider.toggleLike(comment!.id);

      final updated = provider.comments.firstWhere((c) => c.id == comment.id);
      expect(updated.isLiked, true);
    });

    test('should delete a comment', () async {
      final comment = await controller.postComment('entity-1', 'To delete');
      expect(comment, isNotNull);

      await provider.loadComments();
      expect(provider.comments.length, 1);

      await provider.deleteComment(comment!.id);
      expect(provider.comments, isEmpty);
    });

    test('should expand replies', () async {
      final parent = await controller.postComment('entity-1', 'Parent');
      expect(parent, isNotNull);

      await controller.postReply('entity-1', parent!.id, 'Reply 1');
      await controller.postReply('entity-1', parent.id, 'Reply 2');

      await provider.loadComments();
      await provider.expandReplies(parent.id);

      final parentInList = provider.comments.firstWhere((c) => c.id == parent.id);
      expect(parentInList.replies.length, 2);
    });

    test('should set and clear reply target', () {
      final comment = Comment(
        id: '1',
        date: DateTime.now(),
        content: 'Test',
        entityId: 'e1',
        userId: 'u1',
        username: 'User',
      );

      provider.setReplyTo(comment);
      expect(provider.replyingTo, comment);

      provider.setReplyTo(null);
      expect(provider.replyingTo, isNull);
    });

    test('should send comment with validation', () async {
      provider.inputController.text = 'Valid comment';
      
      bool errorCalled = false;
      provider.sendComment(
        localizations,
        onInputError: (_) => errorCalled = true,
      );
      
      // Wait a bit for async operations
      await Future.delayed(const Duration(milliseconds: 200));

      expect(errorCalled, false);
      expect(provider.comments.length, 1);
      expect(provider.inputController.text, isEmpty);
    });

    test('should call onInputError for invalid comment', () async {
      // Use a comment that will fail validation (contains bad word)
      validator = CommentValidator(badWordsData: 'bad\nword');
      provider = CommentProvider(
        controller: controller,
        postId: 'entity-1',
        validator: validator,
      );
      provider.inputController.text = 'This is a bad comment';
      
      String? errorMessage;
      provider.sendComment(
        localizations,
        onInputError: (error) => errorMessage = error,
      );
      
      // Wait a bit for async operations
      await Future.delayed(const Duration(milliseconds: 200));

      expect(errorMessage, isNotNull);
      expect(provider.comments, isEmpty);
    });
  });
}

