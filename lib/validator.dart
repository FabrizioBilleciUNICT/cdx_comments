
import 'dart:async';
import 'package:cdx_comments/l10n/app_localizations.dart';

class CommentValidator {
  static final CommentValidator _instance = CommentValidator._internal();
  factory CommentValidator() => _instance;
  CommentValidator._internal();

  Set<String>? _badWords;

  Future<void> _loadBadWords() async {
    if (_badWords != null) return;
    final data = DataService().config?.comments.badWords ?? '';
    _badWords = data
        .split('\n')
        .map((w) => w.trim().toLowerCase())
        .where((w) => w.isNotEmpty && !w.startsWith('#'))
        .toSet();
  }

  Future<bool> containsBadWords(String input) async {
    await _loadBadWords();
    final words = input.toLowerCase().split(RegExp(r'\W+'));
    return words.any(_badWords!.contains);
  }

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

  Future<String?> validate(String text, AppLocalizations loc, {int maxLines = 10, int maxLength = 400}) async {
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
