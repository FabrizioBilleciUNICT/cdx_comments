
import 'package:cdx_core/injector.dart';
import 'package:flutter/material.dart';
import '../models/comment.dart';
import '../report/sheet.dart';

class CommentTile extends StatelessWidget {
  final DataService ds;
  final Comment comment;
  final void Function()? onLike;
  final void Function()? onDelete;
  final void Function()? onReply;
  final void Function()? onExpand;
  final void Function() onUserBlocked;

  const CommentTile({
    super.key,
    required this.ds,
    required this.comment,
    this.onLike,
    this.onDelete,
    this.onReply,
    this.onExpand,
    required this.onUserBlocked,
  });

  void _delete(BuildContext context, AppLocalizations loc) {
    AppUtils.openConfirmationDialog(
        context,
        loc.delete_comment,
        loc.q_delete_comment,
        loc.confirm,
        (confirm) {
          if (confirm) {
            onDelete?.call();
          }
        }
    );
  }

  void _report(BuildContext context, AppLocalizations loc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => ReportCommentBottomSheet(
        commentId: comment.id,
        userId: comment.userId,
        onUserBlocked: onUserBlocked,
      ),
    );
  }

  void _showMenu(BuildContext context, AppLocalizations loc, TapDownDetails details) {
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
    final loc = AppLocalizations.of(context)!;
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
                        if (ds.commentHasFeature(ModuleFeature.comment))
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
                  if (ds.commentHasInsight(ModuleInsight.likeCount))
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
                      onPressed: ds.commentHasFeature(ModuleFeature.like) ? onLike : null,
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
