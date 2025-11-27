/// Configuration for the comments module.
///
/// This class holds configuration settings that affect comment behavior,
/// such as the list of bad words to filter.
///
/// Example:
/// ```dart
/// const config = CommentConfig(
///   badWords: 'bad\nword\ntest\n# This is a comment',
/// );
/// ```
class CommentConfig {
  /// Newline-separated list of bad words to filter.
  ///
  /// Lines starting with '#' are treated as comments and ignored.
  /// The list is case-insensitive when used for validation.
  final String badWords;
  
  /// Creates a new [CommentConfig].
  ///
  /// [badWords] is a newline-separated string of words to filter.
  /// Empty lines and lines starting with '#' are ignored.
  const CommentConfig({
    required this.badWords,
  });
}

