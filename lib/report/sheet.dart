
import 'package:cdx_comments/l10n/app_localizations.dart';
import 'package:cdx_comments/models/comments_app_actions.dart';
import 'package:cdx_comments/models/comments_theme.dart';
import 'package:cdx_comments/models/comments_text_style.dart';
import 'package:cdx_comments/report/provider.dart';
import 'package:cdx_comments/report/report.dart';
import 'package:cdx_comments/services/comment_service.dart';
import 'package:cdx_comments/widgets/line_divider.dart';
import 'package:cdx_comments/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReportCommentBottomSheet extends StatelessWidget {
  final String commentId;
  final String userId;
  final Function() onUserBlocked;
  final CommentService service;
  final CommentsTheme? theme;
  final CommentsAppActions? appActions;
  final CommentsTextStyle? textStyle;

  const ReportCommentBottomSheet({
    super.key,
    required this.commentId,
    required this.userId,
    required this.onUserBlocked,
    required this.service,
    this.theme,
    this.appActions,
    this.textStyle,
  });

  CommentsTheme _getTheme(BuildContext context) {
    return theme ?? DefaultCommentsTheme(context);
  }

  CommentsTextStyle _getTextStyle(BuildContext context) {
    return textStyle ?? DefaultCommentsTextStyle(context);
  }

  CommentsAppActions _getAppActions() {
    return appActions ?? DefaultCommentsAppActions();
  }

  @override
  Widget build(BuildContext context) {
    final loc = CdxCommentsLocalizations.of(context)!;
    final commentsTheme = _getTheme(context);
    return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
              decoration: BoxDecoration(
                color: commentsTheme.mainBackground,
                borderRadius: commentsTheme.cardRadius,
              ),
              child: SafeArea(child: _content(context, loc))
          );
        }
    );
  }

  Widget _content(BuildContext context, CdxCommentsLocalizations loc) {
    final commentsTheme = _getTheme(context);
    final commentsTextStyle = _getTextStyle(context);
    return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              loc.report,
              style: commentsTextStyle.bold18(color: commentsTheme.mainText),
            ),
          ),
          LineDivider(color: commentsTheme.minorText.withOpacity(0.2)),
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
    final commentsTheme = _getTheme(context);
    final commentsTextStyle = _getTextStyle(context);
    return Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.q_report_comment,
            style: commentsTextStyle.bold18(color: commentsTheme.mainText),
          ),
          const SizedBox(height: 16),
          for (final reason in reportReasons)
            ListTile(
              title: Text(
                reason.label,
                style: commentsTextStyle.normal14(color: commentsTheme.mainText),
              ),
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
    final commentsTheme = _getTheme(context);
    final commentsTextStyle = _getTextStyle(context);
    final actions = _getAppActions();
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.q_report_user,
          style: commentsTextStyle.bold18(color: commentsTheme.mainText),
        ),
        const SizedBox(height: 16),
        CheckboxListTile(
          value: provider.reportUser,
          onChanged: provider.toggleReportUser,
          title: Text(
            loc.report_user,
            style: commentsTextStyle.normal15(color: commentsTheme.mainText),
          ),
        ),
        const SizedBox(height: 16),
        CheckboxListTile(
          value: provider.blockUser,
          onChanged: provider.toggleBlockUser,
          title: Text(
            loc.block_user,
            style: commentsTextStyle.normal15(color: commentsTheme.mainText),
          ),
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
                  actions.showInfoSnackbar(context, loc.report_done);
                }
              },
              text: loc.end,
          )]),
        )
      ],
    );
  }
}


