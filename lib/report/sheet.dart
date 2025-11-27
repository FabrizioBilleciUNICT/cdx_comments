
import 'package:cdx_bootstrap/ui/custom_button.dart';
import 'package:cdx_bootstrap/ui/divider.dart';
import 'package:cdx_comments/l10n/app_localizations.dart';
import 'package:cdx_comments/report/provider.dart';
import 'package:cdx_comments/report/report.dart';
import 'package:cdx_comments/services/comment_service.dart';
import 'package:cdx_core/core/models/text_data.dart';
import 'package:cdx_core/injector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReportCommentBottomSheet extends StatelessWidget {
  final String commentId;
  final String userId;
  final Function() onUserBlocked;
  final CommentService service;

  const ReportCommentBottomSheet({
    super.key,
    required this.commentId,
    required this.userId,
    required this.onUserBlocked,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    final loc = CdxCommentsLocalizations.of(context)!;
    return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
              decoration: BoxDecoration(
                color: DI.colors().mainText,
                borderRadius: BorderRadius.vertical(top: DI.theme().radius.card.topRight),
              ),
              child: SafeArea(child: _content(context, loc))
          );
        }
    );
  }

  TextData get _data => TextData(color: DI.colors().mainBackground);

  Widget _content(BuildContext context, CdxCommentsLocalizations loc) {
    return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DI.app().bold18(loc.report, data: _data),
          ),
          LineDivider(color: DI.colors().mainBackground.withValues(alpha: 0.2)),
          Expanded(
              child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  child: ChangeNotifierProvider(
                    create: (_) => CommentReportProvider(service, onUserBlocked),
                    child: Builder(
                        builder: (context) {
                          return Consumer<CommentReportProvider>(
                            builder: (context, provider, _) {
                              switch (provider.step) {
                                case ReportStep.reason:
                                  return _reportReason(context, loc, provider);
                                case ReportStep.user:
                                  return _reportUser(context, loc, provider);
                              }
                            },
                          );
                        }
                    ),
                  )
              )
          )
        ]
    );
  }

  Widget _reportReason(BuildContext context, CdxCommentsLocalizations loc, CommentReportProvider provider) {
    return Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DI.app().bold18(loc.q_report_comment, data: _data),
          const SizedBox(height: 16),
          for (final reason in reportReasons)
            ListTile(
              title: DI.app().normal14(reason.label, data: _data),
              leading: Radio<ReportReason>(
                value: reason,
                groupValue: provider.selectedReason,
                onChanged: (val) => provider.selectReason(val!),
              ),
              onTap: () => provider.selectReason(reason),
            ),
          const Spacer(),
          Selector<CommentReportProvider, ReportReason?>(
              selector: (context, provider) => provider.selectedReason,
              builder: (BuildContext context, ReportReason? value, Widget? child) =>
                  Row(children: [PrimaryButton(
                      onPressed: provider.goToNextStep,
                      text: loc.next,
                      enabled: value != null
                  )])
          )
        ]
    );
  }

  Widget _reportUser(BuildContext context, CdxCommentsLocalizations loc, CommentReportProvider provider) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DI.app().bold18(loc.q_report_user, data: _data),
        const SizedBox(height: 16),
        CheckboxListTile(
          value: provider.reportUser,
          onChanged: provider.toggleReportUser,
          title: DI.app().normal15(loc.report_user, data: _data),
        ),
        const SizedBox(height: 16),
        CheckboxListTile(
          value: provider.blockUser,
          onChanged: provider.toggleBlockUser,
          title: DI.app().normal15(loc.block_user, data: _data),
        ),
        const Spacer(),
        Selector<CommentReportProvider, bool>(
          selector: (context, provider) => provider.loading,
          builder: (BuildContext context, bool loading, Widget? child) => Row(children: [PrimaryButton(
            loading: loading,
              onPressed: () async {
                await provider.submitReport(commentId, userId);
                if (context.mounted) {
                  Navigator.pop(context);
                  DI.app().showInfoSnackbar(context, loc.report_done);
                }
              },
              text: loc.end,
          )]),
        )
      ],
    );
  }
}


