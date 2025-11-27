import 'dart:async';
import 'package:cdx_comments/l10n/app_localizations.dart';

/// Validator for comment content.
///
/// Validates comment text for:
/// - Empty content
/// - Maximum length and line count
/// - Dangerous content (XSS, SQL injection, etc.)
/// - Bad words (configurable list)
///
/// Example:
/// ```dart
/// final validator = CommentValidator(
///   badWordsData: 'bad\nword\ntest',
/// );
/// final error = await validator.validate('This is a comment', localizations);
/// if (error != null) {
///   // Show error to user
/// }
/// ```
class CommentValidator {
  /// The bad words data as a newline-separated string.
  ///
  /// Lines starting with '#' are treated as comments and ignored.
  /// Words are case-insensitive.
  final String badWordsData;
  
  /// Creates a new [CommentValidator].
  ///
  /// [badWordsData] is a newline-separated string of bad words to check against.
  /// Empty lines and lines starting with '#' are ignored.
  CommentValidator({required this.badWordsData});

  /// Cached set of bad words (loaded lazily).
  Set<String>? _badWords;

  /// Loads bad words from [badWordsData] into [_badWords].
  ///
  /// This method is called automatically when needed and caches the result.
  /// Lines starting with '#' are treated as comments and ignored.
  Future<void> _loadBadWords() async {
    if (_badWords != null) return;
    _badWords = badWordsData
        .split('\n')
        .map((w) => w.trim().toLowerCase())
        .where((w) => w.isNotEmpty && !w.startsWith('#'))
        .toSet();
  }

  /// Checks if the input contains any bad words.
  ///
  /// The check is case-insensitive. Words are split by non-word characters.
  ///
  /// [input] is the text to check.
  ///
  /// Returns `true` if bad words are found, `false` otherwise.
  Future<bool> containsBadWords(String input) async {
    await _loadBadWords();
    final words = input.toLowerCase().split(RegExp(r'\W+'));
    return words.any(_badWords!.contains);
  }

  /// Censors bad words in the input by replacing them with asterisks.
  ///
  /// Each bad word is replaced with asterisks matching its length.
  /// The check is case-insensitive.
  ///
  /// [input] is the text to censor.
  ///
  /// Returns the censored text with bad words replaced by asterisks.
  Future<String> censorBadWords(String input) async {
    await _loadBadWords();
    return input.splitMapJoin(
      RegExp(r'\b\w+\b'),
      onMatch: (match) {
        final word = match.group(0)!;
        return _badWords!.contains(word.toLowerCase()) ? '*' * word.length : word;
      },
      onNonMatch: (nonMatch) => nonMatch,
    );
  }

  /// Checks if the input contains dangerous content.
  ///
  /// Detects:
  /// - Script tags (`<script>...</script>`)
  /// - HTML tags (`<...>`)
  /// - SQL injection patterns (`DROP TABLE`, `SELECT * FROM`, `INSERT INTO`, `--`)
  ///
  /// [input] is the text to check.
  ///
  /// Returns `true` if dangerous content is detected, `false` otherwise.
  bool containsDangerousContent(String input) {
    final patterns = [
      RegExp(r'<script.*?>.*?</script>', caseSensitive: false),
      RegExp(r'<.*?>', caseSensitive: false),
      RegExp(r'drop\s+table', caseSensitive: false),
      RegExp(r'select\s+\*?\s*from', caseSensitive: false),
      RegExp(r'insert\s+into', caseSensitive: false),
      RegExp(r'--', caseSensitive: false),
    ];
    return patterns.any((p) => p.hasMatch(input));
  }

  /// Validates comment text according to all rules.
  ///
  /// Checks the text for:
  /// - Empty content
  /// - Maximum line count (default: 10)
  /// - Maximum character length (default: 400)
  /// - Dangerous content (XSS, SQL injection, etc.)
  /// - Bad words
  ///
  /// [text] is the comment text to validate.
  /// [loc] is the [CdxCommentsLocalizations] instance for error messages.
  /// [maxLines] is the maximum number of lines allowed (default: 10).
  /// [maxLength] is the maximum character length allowed (default: 400).
  ///
  /// Returns a localized error message if validation fails, or `null` if valid.
  ///
  /// Example:
  /// ```dart
  /// final error = await validator.validate(
  ///   'This is a comment',
  ///   localizations,
  ///   maxLines: 5,
  ///   maxLength: 200,
  /// );
  /// if (error != null) {
  ///   print('Validation error: $error');
  /// }
  /// ```
  Future<String?> validate(String text, CdxCommentsLocalizations loc, {int maxLines = 10, int maxLength = 400}) async {
    if (text.trim().isEmpty) return loc.comment_empty;
    if (text.split('\n').length > maxLines) {
      return loc.comment_too_many_lines(maxLines);
    }
    if (text.length > maxLength) {
      return loc.comment_too_long(maxLength);
    }
    if (containsDangerousContent(text)) {
      return loc.comment_dangerous;
    }
    if (await containsBadWords(text)) {
      return loc.comment_bad_words;
    }
    return null;
  }
}
