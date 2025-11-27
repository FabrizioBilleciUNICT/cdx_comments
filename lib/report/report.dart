/// A reason for reporting a comment.
///
/// Each report reason has an ID (used for server communication) and
/// a label (displayed to the user).
///
/// Example:
/// ```dart
/// const reason = ReportReason('spam', 'Spam or misleading content');
/// ```
class ReportReason {
  /// Unique identifier for this report reason.
  ///
  /// This ID is sent to the server when submitting a report.
  final String id;
  
  /// Human-readable label for this report reason.
  ///
  /// This is displayed to the user in the report dialog.
  final String label;
  
  /// Creates a new [ReportReason].
  ///
  /// [id] is the unique identifier.
  /// [label] is the display text.
  const ReportReason(this.id, this.label);
}

/// Predefined list of report reasons.
///
/// These are the standard reasons users can select when reporting a comment.
/// The labels are in Italian; they should be localized based on the app's language.
///
/// To customize, create your own list with localized labels:
/// ```dart
/// final localizedReasons = [
///   ReportReason('spam', localizations.report_reason_spam),
///   ReportReason('hate', localizations.report_reason_hate),
///   // ...
/// ];
/// ```
const List<ReportReason> reportReasons = [
  ReportReason('spam', 'Spam o contenuto fuorviante'),
  ReportReason('hate', 'Incitamento all\'odio o violenza'),
  ReportReason('harassment', 'Molestie o bullismo'),
];
