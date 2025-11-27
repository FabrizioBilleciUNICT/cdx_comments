
import 'package:cdx_comments/l10n/app_localizations.dart';
import 'package:cdx_core/injector.dart';
import 'package:flutter/material.dart';
import '../models/comment.dart';
import '../models/module_features.dart';
import '../report/sheet.dart';
import '../services/comment_service.dart';

class CommentTile extends StatelessWidget {
  final FeatureChecker featureChecker;
  final CommentService service;
  final Comment comment;
  final void Function()? onLike;
  final void Function()? onDelete;
  final void Function()? onReply;
  final void Function()? onExpand;
  final void Function() onUserBlocked;

  const CommentTile({
    super.key,
    required this.featureChecker,
    required this.service,
    required this.comment,
    this.onLike,
    this.onDelete,
    this.onReply,
    this.onExpand,
    required this.onUserBlocked,
  });

  void _delete(BuildContext context, CdxCommentsLocalizations loc) {
    DI.app().openConfirmationDialog(
        context,
        title: loc.delete_comment,
        message: loc.q_delete_comment,
        confirmText: loc.confirm,
        cancelText: loc.cancel,
        confirm: (confirm) {
          if (confirm) {
            onDelete?.call();
          }
        }
    );
  }

  void _report(BuildContext context, CdxCommentsLocalizations loc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => ReportCommentBottomSheet(
        commentId: comment.id,
        userId: comment.userId,
        onUserBlocked: onUserBlocked,
        service: service,
      ),
    );
  }

  void _showMenu(BuildContext context, CdxCommentsLocalizations loc, TapDownDetails details) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final Offset tapPosition = details.globalPosition;

    showMenu<VoidCallback>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromPoints(
          tapPosition,
          tapPosition,
        ),
        Offset.zero & overlay.size,
      ),
      items: [
        if (onDelete != null)
          PopupMenuItem(
            value: () => _delete(context, loc),
            child: Text(loc.delete, style: TextStyle(color: DI.colors().error))
          ),
        PopupMenuItem(
            value: () => _report(context, loc),
            child: Text(loc.report)
        ),
      ],
    ).then((value) => value?.call());
  }

  @override
  Widget build(BuildContext context) {
    final loc = CdxCommentsLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
      child: Column(
        children: [
          GestureDetector(
            onTapDown: (d) => _showMenu(context, loc, d),
            child: Container(
              color: Colors.transparent,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(backgroundColor: DI.colors().primary, child: Text(comment.initials)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(comment.username, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(comment.content),
                        const SizedBox(height: 4),
                        if (featureChecker.commentHasFeature(ModuleFeature.comment))
                          GestureDetector(
                            onTap: onReply,
                            child: Text(
                                loc.answer,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: DI.colors().mainBackground.withValues(alpha: 0.5)
                                )
                            ),
                          )
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (featureChecker.commentHasInsight(ModuleInsight.likeCount))
                    IconButton(
                      icon: Column(
                        children: [
                          Icon(
                            comment.isLiked == true ? Icons.favorite : Icons.favorite_border,
                            color: comment.isLiked == true ? Colors.red : null,
                          ),
                          Text(comment.likeCount?.toString() ?? ''),
                        ],
                      ),
                      onPressed: featureChecker.commentHasFeature(ModuleFeature.like) ? onLike : null,
                    ),
                ],
              ),
            ),
          ),

          if (comment.replies.isEmpty && (comment.replyCount ?? 0) > 0)
            TextButton(
              onPressed: onExpand,
              child: Text(
                  loc.view_replies(comment.replyCount ?? 0),
                  style: TextStyle(color: DI.colors().mainBackground.withValues(alpha: 0.5))
              ),
            )
        ],
      ),
    );
  }
}
