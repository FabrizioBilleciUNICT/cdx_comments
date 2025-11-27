import 'package:cdx_comments/cdx_comments.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Comment', () {
    test('should create a comment with all required fields', () {
      final comment = Comment(
        id: '1',
        date: DateTime(2024, 1, 1),
        content: 'Test comment',
        entityId: 'entity-1',
        userId: 'user-1',
        username: 'John Doe',
      );

      expect(comment.id, '1');
      expect(comment.content, 'Test comment');
      expect(comment.entityId, 'entity-1');
      expect(comment.userId, 'user-1');
      expect(comment.username, 'John Doe');
      expect(comment.isMine, false);
      expect(comment.replies, isEmpty);
      expect(comment.isRoot, true);
    });

    test('should calculate initials correctly', () {
      final comment1 = Comment(
        id: '1',
        date: DateTime.now(),
        content: 'Test',
        entityId: 'e1',
        userId: 'u1',
        username: 'John Doe',
      );
      expect(comment1.initials, 'JD'); // First letter of each word: J(ohn) D(oe)

      final comment2 = Comment(
        id: '2',
        date: DateTime.now(),
        content: 'Test',
        entityId: 'e1',
        userId: 'u1',
        username: 'A',
      );
      expect(comment2.initials, 'A');

      final comment3 = Comment(
        id: '3',
        date: DateTime.now(),
        content: 'Test',
        entityId: 'e1',
        userId: 'u1',
        username: 'AB',
      );
      expect(comment3.initials, 'AB');

      final comment4 = Comment(
        id: '4',
        date: DateTime.now(),
        content: 'Test',
        entityId: 'e1',
        userId: 'u1',
        username: '',
      );
      expect(comment4.initials, '??');
    });

    test('should identify root comments correctly', () {
      final rootComment = Comment(
        id: '1',
        date: DateTime.now(),
        content: 'Root',
        entityId: 'e1',
        userId: 'u1',
        username: 'User',
      );
      expect(rootComment.isRoot, true);

      final reply = Comment(
        id: '2',
        date: DateTime.now(),
        content: 'Reply',
        entityId: 'e1',
        userId: 'u1',
        username: 'User',
        parentId: '1',
      );
      expect(reply.isRoot, false);
    });

    test('should create copy with modified fields', () {
      final original = Comment(
        id: '1',
        date: DateTime(2024, 1, 1),
        content: 'Original',
        entityId: 'e1',
        userId: 'u1',
        username: 'User',
        likeCount: 5,
        isLiked: false,
      );

      final modified = original.copyWith(
        content: 'Modified',
        likeCount: 10,
        isLiked: true,
      );

      expect(modified.id, original.id);
      expect(modified.content, 'Modified');
      expect(modified.likeCount, 10);
      expect(modified.isLiked, true);
      expect(modified.entityId, original.entityId);
    });

    test('should create from JSON correctly', () {
      final json = {
        'id': '1',
        'date': '2024-01-01T00:00:00.000Z',
        'content': 'Test',
        'entityId': 'e1',
        'userId': 'u1',
        'username': 'User',
        'likeCount': 5,
        'replyCount': 2,
        'isLiked': true,
      };

      final comment = Comment.fromJson(json, currentUserId: 'u1');

      expect(comment.id, '1');
      expect(comment.content, 'Test');
      expect(comment.likeCount, 5);
      expect(comment.replyCount, 2);
      expect(comment.isLiked, true);
      expect(comment.isMine, true);
    });

    test('should convert to JSON correctly', () {
      final comment = Comment(
        id: '1',
        date: DateTime(2024, 1, 1),
        content: 'Test',
        entityId: 'e1',
        userId: 'u1',
        username: 'User',
        parentId: 'parent-1',
      );

      final json = comment.toJson();

      expect(json['id'], '1');
      expect(json['content'], 'Test');
      expect(json['entityId'], 'e1');
      expect(json['userId'], 'u1');
      expect(json['username'], 'User');
      expect(json['parentId'], 'parent-1');
    });
  });
}

