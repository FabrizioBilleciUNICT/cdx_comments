// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class CdxCommentsLocalizationsEn extends CdxCommentsLocalizations {
  CdxCommentsLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get comments => 'Comments';

  @override
  String get add_a_comment => 'Add a comment...';

  @override
  String get answer => 'Reply';

  @override
  String get answer_to => 'Replying to';

  @override
  String get delete => 'Delete';

  @override
  String get delete_comment => 'Delete comment';

  @override
  String get q_delete_comment =>
      'Are you sure you want to delete this comment?';

  @override
  String get confirm => 'Confirm';

  @override
  String get cancel => 'Cancel';

  @override
  String get report => 'Report';

  @override
  String get q_report_comment => 'Why are you reporting this comment?';

  @override
  String get q_report_user => 'What do you want to do?';

  @override
  String get report_user => 'Report user';

  @override
  String get block_user => 'Block user';

  @override
  String get next => 'Next';

  @override
  String get end => 'Submit';

  @override
  String get report_done => 'Report submitted successfully';

  @override
  String get blocked_until => 'Blocked until';

  @override
  String view_replies(int count) {
    return 'View $count replies';
  }

  @override
  String get comment_empty => 'Comment cannot be empty';

  @override
  String comment_too_many_lines(int maxLines) {
    return 'Comment cannot exceed $maxLines lines';
  }

  @override
  String comment_too_long(int maxLength) {
    return 'Comment cannot exceed $maxLength characters';
  }

  @override
  String get comment_dangerous => 'Comment contains dangerous content';

  @override
  String get comment_bad_words => 'Comment contains inappropriate words';
}
