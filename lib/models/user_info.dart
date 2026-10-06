/// Information about the current user.
///
/// This class holds basic user information needed for comment operations.
///
/// Example:
/// ```dart
/// const user = UserInfo(
///   uuid: 'user-123',
///   name: 'John Doe',
/// );
/// ```
class UserInfo {
  /// Unique identifier for the user.
  final String uuid;
  
  /// Display name of the user.
  final String name;
  
  /// Creates a new [UserInfo] instance.
  ///
  /// Both [uuid] and [name] are required.
  const UserInfo({
    required this.uuid,
    required this.name,
  });
  
  /// Gets the user's initials for display in avatars.
  ///
  /// For names with multiple words, takes the first letter of the first two words.
  /// For single words, takes the first 1-2 characters.
  /// If [name] is blank, derives up to two letters from [uuid] (alphanumeric only).
  ///
  /// Examples:
  /// - "John Doe" -> "JD"
  /// - "Alice" -> "AL"
  /// - "A" -> "A"
  /// - "" with uuid "ab12-cd" -> "AB"
  String get initials {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return _initialsFromId(uuid);
    }
    final words = trimmed.split(RegExp(r'\s+'));
    if (words.length >= 2) {
      return (words[0][0] + words[1][0]).toUpperCase();
    }
    return trimmed.length >= 2
        ? trimmed.substring(0, 2).toUpperCase()
        : trimmed.substring(0, 1).toUpperCase();
  }
}

String _initialsFromId(String id) {
  final alnum = id.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
  if (alnum.isEmpty) return '?';
  if (alnum.length >= 2) return alnum.substring(0, 2).toUpperCase();
  return alnum[0].toUpperCase();
}

