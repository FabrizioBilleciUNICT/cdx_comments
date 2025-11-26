
import 'package:cdx_comments/report/report.dart';
import 'package:flutter/material.dart';

enum ReportStep {
  reason,
  user,
}

class CommentReportProvider extends ChangeNotifier {

  final DataService dataService;
  final Function() onUserBlocked;
  
  CommentReportProvider(this.dataService, this.onUserBlocked);

  ReportReason? selectedReason;
  ReportStep step = ReportStep.reason;
  bool _blockUser = false;
  bool get blockUser => _blockUser;
  bool _reportUser = false;
  bool get reportUser => _reportUser;
  bool _loading = false;
  bool get loading => _loading;

  void selectReason(ReportReason reason) {
    selectedReason = reason;
    notifyListeners();
  }

  void toggleReportUser(bool? value) {
    _reportUser = value ?? false;
    notifyListeners();
  }

  void toggleBlockUser(bool? value) {
    _blockUser = value ?? false;
    notifyListeners();
  }

  void goToNextStep() {
    if (selectedReason != null) {
      step = ReportStep.user;
      notifyListeners();
    }
  }

  void reset() {
    selectedReason = null;
    _reportUser = false;
    _blockUser = false;
    step = ReportStep.reason;
    notifyListeners();
  }

  Future<void> submitReport(String commentId, String userId) async {
    _loading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    await dataService.sendReportComment(commentId, selectedReason!.id);
    if (_reportUser) {
      await dataService.sendReportUser(userId);
    }
    if (_blockUser) {
      await dataService.sendBlockUser(userId);
      onUserBlocked();
    }
    _loading = false;
    notifyListeners();
    reset();
  }
}
