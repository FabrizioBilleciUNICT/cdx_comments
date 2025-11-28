import 'package:cdx_comments/l10n/app_localizations.dart';
import 'package:cdx_comments/models/comments_app_actions.dart';
import 'package:cdx_comments/models/comments_theme.dart';
import 'package:cdx_comments/models/comments_text_style.dart';
import 'package:cdx_comments/utils/date_formatter.dart';
import 'package:cdx_comments/widgets/line_divider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/module_features.dart';
import '../models/user_info.dart';
import '../provider.dart';
import '../services/comment_service.dart';
import 'comment_tile.dart';

class CommentBottomSheet extends StatelessWidget {
  final DateTime? userBlockedUntil;
  final FeatureChecker featureChecker;
  final CommentService service;
  final UserInfo user;
  final CommentsTheme? theme;
  final CommentsAppActions? appActions;
  final CommentsTextStyle? textStyle;
  
  const CommentBottomSheet({
    super.key,
    required this.userBlockedUntil,
    required this.featureChecker,
    required this.service,
    required this.user,
    this.theme,
    this.appActions,
    this.textStyle,
  });

  void _onInputError(BuildContext context, String error) {
    final actions = appActions ?? DefaultCommentsAppActions();
    actions.showErrorSnackbar(context, error);
  }

  CommentsTheme _getTheme(BuildContext context) {
    return theme ?? DefaultCommentsTheme(context);
  }

  CommentsTextStyle _getTextStyle(BuildContext context) {
    return textStyle ?? DefaultCommentsTextStyle(context);
  }

  Widget _buildUserAvatar(BuildContext context, CommentsTheme commentsTheme) {
    final actions = appActions ?? DefaultCommentsAppActions();
    final customAvatar = actions.buildUserAvatar(context, user);
    if (customAvatar != null) return customAvatar;
    return CircleAvatar(
      backgroundColor: commentsTheme.primary,
      child: Text(
        user.initials,
        style: TextStyle(color: commentsTheme.mainBackground),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommentProvider>();
    final loc = CdxCommentsLocalizations.of(context)!;
    final commentsTheme = _getTheme(context);
    final commentsTextStyle = _getTextStyle(context);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            backgroundColor: commentsTheme.mainBackground,
            body: Container(
              decoration: BoxDecoration(
                color: commentsTheme.mainBackground,
                borderRadius: commentsTheme.cardRadius,
              ),
              child: Column(
                children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    loc.comments,
                    style: commentsTextStyle.bold18(color: commentsTheme.mainText),
                  ),
                ),
                LineDivider(color: commentsTheme.minorText.withOpacity(0.2)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            controller: scrollController,
                            itemCount: provider.comments.length,
                            itemBuilder: (context, index) {
                              final comment = provider.comments[index];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CommentTile(
                                    key: ValueKey(comment.id),
                                    featureChecker: featureChecker,
                                    service: service,
                                    comment: comment,
                                    onLike: () => provider.toggleLike(comment.id),
                                    onDelete: comment.isMine ? () => provider.deleteComment(comment.id) : null,
                                    onReply: userBlockedUntil != null ? (){} : () => provider.setReplyTo(comment),
                                    onExpand: () => provider.expandReplies(comment.id),
                                    onUserBlocked: () => provider.loadComments(),
                                    theme: theme,
                                    appActions: appActions,
                                  ),
                                  ...comment.replies.map((reply) => Padding(
                                    padding: const EdgeInsets.only(left: 32.0),
                                    child: CommentTile(
                                      key: ValueKey(reply.id),
                                      featureChecker: featureChecker,
                                      service: service,
                                      comment: reply,
                                      onLike: () => provider.toggleReplyLike(comment.id, reply.id),
                                      onDelete: reply.isMine ? () => provider.deleteReply(comment.id, reply.id) : null,
                                      onReply: userBlockedUntil != null ? (){} : () => provider.setReplyTo(comment),
                                      onUserBlocked: () => provider.loadComments(),
                                      theme: theme,
                                      appActions: appActions,
                                    ),
                                  )),
                                  const SizedBox(height: 8),
                                ],
                              );
                            },
                          ),
                        ),
                        if (provider.replyingTo != null)
                          Container(
                            color: commentsTheme.minorText.withOpacity(0.1),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "${loc.answer_to} ${provider.replyingTo!.username}",
                                      style: commentsTextStyle.normal14(color: commentsTheme.mainText),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.close, color: commentsTheme.mainText),
                                    onPressed: () => provider.setReplyTo(null),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (featureChecker.commentHasFeature(ModuleFeature.comment))
                          SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Row(
                                children: [
                                  _buildUserAvatar(context, commentsTheme),
                                  const SizedBox(width: 8),
                                  if (userBlockedUntil != null)
                                    Expanded(child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: commentsTheme.minorText.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${loc.blocked_until} ${DateFormatter.format(userBlockedUntil!, 'dd/MM/yyyy HH:mm', locale: 'it')}',
                                        style: commentsTextStyle.normal12(
                                          color: commentsTheme.minorText,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ))
                                  else Expanded(
                                    child: TextField(
                                      controller: provider.inputController,
                                      inputFormatters: [LengthLimitingTextInputFormatter(400)],
                                      keyboardType: TextInputType.multiline,
                                      maxLines: 5,
                                      minLines: 1,
                                      style: commentsTextStyle.normal14(color: commentsTheme.mainText),
                                      decoration: InputDecoration(
                                        hintText: loc.add_a_comment,
                                        hintStyle: commentsTextStyle.normal14(color: commentsTheme.minorText),
                                        fillColor: commentsTheme.mainBackground,
                                        filled: true,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(24),
                                          borderSide: BorderSide(color: commentsTheme.minorText.withOpacity(0.3)),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(24),
                                          borderSide: BorderSide(color: commentsTheme.primary),
                                        ),
                                        suffixIcon: provider.inputController.text.trim().isNotEmpty
                                            ? IconButton(
                                          icon: Icon(Icons.send, color: commentsTheme.primary),
                                          onPressed: () => provider.sendComment(loc, onInputError: (e) => _onInputError(context, e)),
                                        )
                                            : null,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                )],
              ),
            ),
          ),
        );
      },
    );
  }
}
