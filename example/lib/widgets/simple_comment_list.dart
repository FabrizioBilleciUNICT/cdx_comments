import 'package:cdx_comments/cdx_comments.dart';
import 'package:flutter/material.dart';

/// Simplified comment list widget for the example app.
///
/// This widget demonstrates how to use the CommentProvider and related APIs
/// without requiring cdx_core and cdx_bootstrap dependencies.
class SimpleCommentList extends StatelessWidget {
  final CommentProvider provider;
  final CommentService service;
  final UserInfo user;
  final FeatureChecker featureChecker;

  const SimpleCommentList({
    super.key,
    required this.provider,
    required this.service,
    required this.user,
    required this.featureChecker,
  });

  @override
  Widget build(BuildContext context) {
    final loc = CdxCommentsLocalizations.of(context)!;

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(
                loc.comments,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              Text(
                '${provider.comments.length}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ],
          ),
        ),

        // Comments list
        Expanded(
          child: provider.comments.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.comment_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No comments yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Be the first to comment!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.comments.length,
                  itemBuilder: (context, index) {
                    final comment = provider.comments[index];
                    return _CommentCard(
                      comment: comment,
                      provider: provider,
                      service: service,
                      featureChecker: featureChecker,
                      user: user,
                    );
                  },
                ),
        ),

        // Input section
        if (featureChecker.commentHasFeature(ModuleFeature.comment))
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: _CommentInput(provider: provider),
          ),
      ],
    );
  }
}

class _CommentCard extends StatelessWidget {
  final Comment comment;
  final CommentProvider provider;
  final CommentService service;
  final FeatureChecker featureChecker;
  final UserInfo user;

  const _CommentCard({
    required this.comment,
    required this.provider,
    required this.service,
    required this.featureChecker,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final loc = CdxCommentsLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Comment header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    comment.initials,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _formatDate(comment.date),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (comment.isMine)
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.red,
                    onPressed: () => _showDeleteDialog(context, loc),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Comment content
            Text(
              comment.content,
              style: const TextStyle(fontSize: 14),
            ),

            const SizedBox(height: 12),

            // Actions
            Row(
              children: [
                if (featureChecker.commentHasFeature(ModuleFeature.comment))
                  TextButton.icon(
                    onPressed: () => provider.setReplyTo(comment),
                    icon: const Icon(Icons.reply, size: 16),
                    label: Text(loc.answer),
                  ),
                if (featureChecker.commentHasFeature(ModuleFeature.like))
                  TextButton.icon(
                    onPressed: () => provider.toggleLike(comment.id),
                    icon: Icon(
                      comment.isLiked == true
                          ? Icons.favorite
                          : Icons.favorite_border,
                      size: 16,
                      color: comment.isLiked == true ? Colors.red : null,
                    ),
                    label: Text(
                      featureChecker.commentHasInsight(ModuleInsight.likeCount)
                          ? '${comment.likeCount ?? 0}'
                          : '',
                    ),
                  ),
                const Spacer(),
                TextButton(
                  onPressed: () => _showReportDialog(context, loc),
                  child: Text(loc.report),
                ),
              ],
            ),

            // Replies
            if (comment.replies.isNotEmpty) ...[
              const Divider(),
              const SizedBox(height: 8),
              ...comment.replies.map((reply) => Padding(
                    padding: const EdgeInsets.only(left: 32, bottom: 8),
                    child: _ReplyCard(
                      reply: reply,
                      provider: provider,
                      parentId: comment.id,
                    ),
                  )),
            ],

            // Expand replies button
            if (comment.replies.isEmpty &&
                (comment.replyCount ?? 0) > 0)
              TextButton(
                onPressed: () => provider.expandReplies(comment.id),
                child: Text(loc.view_replies(comment.replyCount ?? 0)),
              ),

            // Replying indicator
            if (provider.replyingTo?.id == comment.id)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      '${loc.answer_to} ${comment.username}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => provider.setReplyTo(null),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, CdxCommentsLocalizations loc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.delete_comment),
        content: Text(loc.q_delete_comment),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.cancel),
          ),
          TextButton(
            onPressed: () {
              provider.deleteComment(comment.id);
              Navigator.pop(context);
            },
            child: Text(
              loc.confirm,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showReportDialog(BuildContext context, CdxCommentsLocalizations loc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.report),
        content: Text('Report functionality would be implemented here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.cancel),
          ),
          TextButton(
            onPressed: () {
              // Report implementation
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(loc.report_done)),
              );
            },
            child: Text(loc.confirm),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class _ReplyCard extends StatelessWidget {
  final Comment reply;
  final CommentProvider provider;
  final String parentId;

  const _ReplyCard({
    required this.reply,
    required this.provider,
    required this.parentId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                reply.initials,
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reply.username,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reply.content,
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
            if (reply.isMine)
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18),
                color: Colors.red,
                onPressed: () => provider.deleteReply(parentId, reply.id),
              ),
          ],
        ),
      ),
    );
  }
}

class _CommentInput extends StatefulWidget {
  final CommentProvider provider;

  const _CommentInput({required this.provider});

  @override
  State<_CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<_CommentInput> {
  @override
  Widget build(BuildContext context) {
    final loc = CdxCommentsLocalizations.of(context)!;
    final provider = widget.provider;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (provider.replyingTo != null)
          Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${loc.answer_to} ${provider.replyingTo!.username}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => provider.setReplyTo(null),
                ),
              ],
            ),
          ),
        Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                provider.controller.user.initials,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: provider.inputController,
                decoration: InputDecoration(
                  hintText: loc.add_a_comment,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendComment(loc),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: provider.inputController.text.trim().isNotEmpty
                  ? () => _sendComment(loc)
                  : null,
            ),
          ],
        ),
      ],
    );
  }

  void _sendComment(CdxCommentsLocalizations loc) {
    widget.provider.sendComment(
      loc,
      onInputError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }
}

