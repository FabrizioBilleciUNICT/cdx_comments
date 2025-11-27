import 'package:cdx_comments/report/report.dart';
import 'package:cdx_comments/services/comment_service.dart';
import 'package:flutter/material.dart';

/// Steps in the report flow.
enum ReportStep {
  /// First step: selecting the reason for reporting.
  reason,
  
  /// Second step: choosing to report/block the user.
  user,
}

/// Provider for managing the comment/user reporting flow.
///
/// This provider manages the state of the reporting dialog, including
/// the selected reason, whether to report the user, and whether to block them.
///
/// Example:
/// ```dart
/// final provider = CommentReportProvider(
///   commentService,
///   () => print('User was blocked'),
/// );
/// ```
class CommentReportProvider extends ChangeNotifier {
  /// The service for sending reports.
  final CommentService service;
  
  /// Callback invoked when a user is blocked.
  final Function() onUserBlocked;
  
  /// Creates a new [CommentReportProvider].
  ///
  /// [service] is used to send the report to the server.
  /// [onUserBlocked] is called when a user is successfully blocked.
  CommentReportProvider(this.service, this.onUserBlocked);

  /// The reason selected for reporting the comment.
  ///
  /// `null` if no reason has been selected yet.
  ReportReason? selectedReason;
  
  /// The current step in the report flow.
  ///
  /// Starts at [ReportStep.reason] and moves to [ReportStep.user] after
  /// a reason is selected.
  ReportStep step = ReportStep.reason;
  /// Whether to block the user.
  bool _blockUser = false;
  
  /// Whether the user should be blocked.
  bool get blockUser => _blockUser;
  
  /// Whether to report the user.
  bool _reportUser = false;
  
  /// Whether the user should be reported.
  bool get reportUser => _reportUser;
  
  /// Whether a report submission is in progress.
  bool _loading = false;
  
  /// Whether a report is currently being submitted.
  bool get loading => _loading;

  /// Selects a reason for reporting the comment.
  ///
  /// [reason] is the [ReportReason] selected by the user.
  void selectReason(ReportReason reason) {
    selectedReason = reason;
    notifyListeners();
  }

  /// Toggles whether to report the user.
  ///
  /// [value] is the new value. If `null`, defaults to `false`.
  void toggleReportUser(bool? value) {
    _reportUser = value ?? false;
    notifyListeners();
  }

  /// Toggles whether to block the user.
  ///
  /// [value] is the new value. If `null`, defaults to `false`.
  void toggleBlockUser(bool? value) {
    _blockUser = value ?? false;
    notifyListeners();
  }

  /// Advances to the next step in the report flow.
  ///
  /// Only advances if a reason has been selected.
  /// Moves from [ReportStep.reason] to [ReportStep.user].
  void goToNextStep() {
    if (selectedReason != null) {
      step = ReportStep.user;
      notifyListeners();
    }
  }

  /// Resets the report provider to its initial state.
  ///
  /// Clears the selected reason, resets all flags, and returns to the first step.
  void reset() {
    selectedReason = null;
    _reportUser = false;
    _blockUser = false;
    step = ReportStep.reason;
    notifyListeners();
  }

  /// Submits the report to the server.
  ///
  /// Sends the report for the comment and optionally reports/blocks the user
  /// based on the current state.
  ///
  /// [commentId] is the ID of the comment being reported.
  /// [userId] is the ID of the user who created the comment.
  ///
  /// After submission, resets the provider state and calls [onUserBlocked]
  /// if the user was blocked.
  Future<void> submitReport(String commentId, String userId) async {
    _loading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    await service.sendReportComment(commentId, selectedReason!.id);
    if (_reportUser) {
      await service.sendReportUser(userId);
    }
    if (_blockUser) {
      await service.sendBlockUser(userId);
      onUserBlocked();
    }
    _loading = false;
    notifyListeners();
    reset();
  }
}
