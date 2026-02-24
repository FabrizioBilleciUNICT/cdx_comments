import 'package:cdx_comments/l10n/app_localizations.dart';
import 'package:cdx_comments/models/comments_app_actions.dart';
import 'package:cdx_comments/models/comments_theme.dart';
import 'package:flutter/material.dart';
import '../models/comment.dart';
import '../models/module_features.dart';
import '../report/sheet.dart';
import '../services/comment_service.dart';

class CommentTile extends StatefulWidget {
  final FeatureChecker featureChecker;
  final CommentService service;
  final Comment comment;
  final void Function()? onLike;
  final void Function()? onDelete;
  final void Function()? onReply;
  final void Function()? onExpand;
  final void Function()? onLoadMoreReplies;
  final void Function() onUserBlocked;
  final CommentsTheme? theme;
  final CommentsAppActions? appActions;

  const CommentTile({
    super.key,
    required this.featureChecker,
    required this.service,
    required this.comment,
    this.onLike,
    this.onDelete,
    this.onReply,
    this.onExpand,
    this.onLoadMoreReplies,
    required this.onUserBlocked,
    this.theme,
    this.appActions,
  });

  @override
  State<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> {
  Offset _longPressPosition = Offset.zero;

  CommentsTheme _getTheme(BuildContext context) {
    return widget.theme ?? DefaultCommentsTheme(context);
  }

  CommentsAppActions _getAppActions() {
    return widget.appActions ?? DefaultCommentsAppActions();
  }

  Widget _buildAvatar(BuildContext context, CommentsTheme commentsTheme) {
    final customAvatar =
        _getAppActions().buildCommentAvatar(context, widget.comment);
    if (customAvatar != null) return customAvatar;
    return CircleAvatar(
      backgroundColor: commentsTheme.primary,
      child: Text(
        widget.comment.initials,
        style: TextStyle(color: commentsTheme.mainBackground),
      ),
    );
  }

  void _delete(BuildContext context, CdxCommentsLocalizations loc) {
    final actions = _getAppActions();
    actions.showConfirmationDialog(
      context: context,
      title: loc.delete_comment,
      message: loc.q_delete_comment,
      confirmText: loc.confirm,
      cancelText: loc.cancel,
      onConfirm: (confirm) {
        if (confirm) {
          widget.onDelete?.call();
        }
      },
    );
  }

  void _report(BuildContext context, CdxCommentsLocalizations loc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => ReportCommentBottomSheet(
        commentId: widget.comment.id,
        userId: widget.comment.userId,
        onUserBlocked: widget.onUserBlocked,
        service: widget.service,
        theme: widget.theme,
        appActions: widget.appActions,
        textStyle: null,
      ),
    );
  }

  void _showMenu(BuildContext context, CdxCommentsLocalizations loc, Offset position) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final Offset tapPosition = position;
    final commentsTheme = _getTheme(context);

    showMenu<VoidCallback>(
      context: context,
      color: commentsTheme.mainBackground,
      position: RelativeRect.fromRect(
        Rect.fromPoints(tapPosition, tapPosition),
        Offset.zero & overlay.size,
      ),
      items: [
        if (widget.onDelete != null)
          PopupMenuItem(
            value: () => _delete(context, loc),
            child: Text(
              loc.delete,
              style: TextStyle(color: commentsTheme.error),
            ),
          ),
        if (!widget.comment.isMine)
          PopupMenuItem(
            value: () => _report(context, loc),
            child: Text(
              loc.report,
              style: TextStyle(color: commentsTheme.mainText),
            ),
          ),
      ],
    ).then((value) => value?.call());
  }

  @override
  Widget build(BuildContext context) {
    final loc = CdxCommentsLocalizations.of(context)!;
    final commentsTheme = _getTheme(context);
    final comment = widget.comment;
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
      child: Column(
        children: [
          GestureDetector(
            onLongPressDown: (d) => setState(() => _longPressPosition = d.globalPosition),
            onLongPress: () => _showMenu(context, loc, _longPressPosition),
            child: Container(
              color: Colors.transparent,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAvatar(context, commentsTheme),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          comment.username,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: commentsTheme.mainText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          comment.content,
                          style: TextStyle(color: commentsTheme.mainText),
                        ),
                        const SizedBox(height: 4),
                        if (widget.featureChecker.commentHasFeature(
                          ModuleFeature.comment,
                        ))
                          GestureDetector(
                            onTap: widget.onReply,
                            child: Text(
                              loc.answer,
                              style: TextStyle(
                                fontSize: 12,
                                color: commentsTheme.minorText,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (widget.featureChecker.commentHasInsight(ModuleInsight.likeCount))
                    IconButton(
                      icon: Column(
                        children: [
                          Icon(
                            comment.isLiked == true
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: comment.isLiked == true ? commentsTheme.likeColor : commentsTheme.minorText,
                          ),
                          Text(
                            comment.likeCount?.toString() ?? '',
                            style: TextStyle(
                              fontSize: 10,
                              color: commentsTheme.minorText,
                            ),
                          ),
                        ],
                      ),
                      onPressed:
                          widget.featureChecker.commentHasFeature(ModuleFeature.like)
                          ? widget.onLike
                          : null,
                    ),
                ],
              ),
            ),
          ),

          if (comment.replies.isEmpty && (comment.replyCount ?? 0) > 0)
            TextButton(
              onPressed: widget.onExpand,
              child: Text(
                loc.view_replies(comment.replyCount ?? 0),
                style: TextStyle(
                  color: commentsTheme.minorText,
                ),
              ),
            ),
          if (comment.replies.isNotEmpty &&
              (comment.replyCount ?? 0) > comment.replies.length &&
              widget.onLoadMoreReplies != null)
            TextButton(
              onPressed: widget.onLoadMoreReplies,
              child: Text(
                loc.load_more_replies,
                style: TextStyle(color: commentsTheme.minorText),
              ),
            ),
        ],
      ),
    );
  }
}
