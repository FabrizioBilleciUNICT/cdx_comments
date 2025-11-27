import 'package:cdx_comments/cdx_comments.dart';
import 'package:cdx_comments/l10n/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CommentValidator', () {
    late CommentValidator validator;
    late CdxCommentsLocalizationsEn localizations;

    setUp(() {
      localizations = CdxCommentsLocalizationsEn();
      validator = CommentValidator(badWordsData: 'bad\nword\ntest');
    });

    test('should reject empty comments', () async {
      final error = await validator.validate('', localizations);
      expect(error, isNotNull);
      expect(error, localizations.comment_empty);
    });

    test('should reject comments with too many lines', () async {
      final text = List.generate(11, (i) => 'Line $i').join('\n');
      final error = await validator.validate(text, localizations, maxLines: 10);
      expect(error, isNotNull);
      expect(error, contains('10'));
    });

    test('should reject comments that are too long', () async {
      final text = 'a' * 401;
      final error = await validator.validate(text, localizations, maxLength: 400);
      expect(error, isNotNull);
      expect(error, contains('400'));
    });

    test('should reject comments with dangerous content', () async {
      final dangerousContents = [
        '<script>alert("xss")</script>',
        '<div>html</div>',
        'DROP TABLE users',
        'SELECT * FROM users',
        'INSERT INTO users',
        '-- comment',
      ];

      for (final content in dangerousContents) {
        final error = await validator.validate(content, localizations);
        expect(error, isNotNull, reason: 'Should reject: $content');
        expect(error, localizations.comment_dangerous);
      }
    });

    test('should reject comments with bad words', () async {
      final error = await validator.validate('This is a bad word', localizations);
      expect(error, isNotNull);
      expect(error, localizations.comment_bad_words);
    });

    test('should accept valid comments', () async {
      final validComments = [
        'This is a valid comment',
        'Another valid comment with multiple words',
        'Valid comment with numbers 123',
      ];

      for (final comment in validComments) {
        final error = await validator.validate(comment, localizations);
        expect(error, isNull, reason: 'Should accept: $comment');
      }
    });

    test('should ignore bad words starting with #', () async {
      final validatorWithComments = CommentValidator(
        badWordsData: '#bad\nword\ntest',
      );
      // 'bad' is commented out, but 'word' is still active, so it should fail
      final error = await validatorWithComments.validate('This is a word', localizations);
      expect(error, isNotNull);
      // But 'bad' alone should pass
      final error2 = await validatorWithComments.validate('This is a bad comment', localizations);
      expect(error2, isNull); // 'bad' is commented out, so it should pass
    });

    test('should detect bad words case-insensitively', () async {
      final error = await validator.validate('This is a BAD word', localizations);
      expect(error, isNotNull);
      expect(error, localizations.comment_bad_words);
    });
  });
}

