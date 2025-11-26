
class ReportReason {
  final String id;
  final String label;
  const ReportReason(this.id, this.label);
}

const List<ReportReason> reportReasons = [
  ReportReason('spam', 'Spam o contenuto fuorviante'),
  ReportReason('hate', 'Incitamento all\'odio o violenza'),
  ReportReason('harassment', 'Molestie o bullismo'),
];
