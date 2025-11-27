import 'package:cdx_bootstrap/ui/divider.dart';
import 'package:cdx_comments/l10n/app_localizations.dart';
import 'package:cdx_core/core/models/text_data.dart';
import 'package:cdx_core/injector.dart';
import 'package:cdx_core/utils/extensions.dart';
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
  
  const CommentBottomSheet({
    super.key,
    required this.userBlockedUntil,
    required this.featureChecker,
    required this.service,
    required this.user,
  });

  void _onInputError(BuildContext context, String error) {
    DI.app().showErrorSnackbar(context, error);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommentProvider>();
    final loc = CdxCommentsLocalizations.of(context)!;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              color: DI.colors().mainText,
              borderRadius: BorderRadius.vertical(top: DI.theme().radius.card.topRight),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DI.app().bold18(loc.comments, data: TextData(color: DI.colors().mainBackground)),
                ),
                LineDivider(color: DI.colors().mainBackground.withValues(alpha: 0.2)),
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
                            color: DI.colors().mainBackground.withValues(alpha: 0.15),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "${loc.answer_to} ${provider.replyingTo!.username}",
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close),
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
                                  CircleAvatar(backgroundColor: DI.colors().primary, child: Text(user.initials)),
                                  const SizedBox(width: 8),
                                  if (userBlockedUntil != null)
                                    Expanded(child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: DI.colors().minorText.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: DI.app().normal12(
                                          '${loc.blocked_until} '
                                              '${userBlockedUntil!.format('dd/MM/yyyy HH:mm', 'it')}',
                                          data: TextData(color: DI.colors().minorText, align: TextAlign.center)
                                      ),
                                    ))
                                  else Expanded(
                                    child: TextField(
                                      controller: provider.inputController,
                                      inputFormatters: [LengthLimitingTextInputFormatter(400)],
                                      keyboardType: TextInputType.multiline,
                                      maxLines: 5,
                                      minLines: 1,
                                      decoration: InputDecoration(
                                        hintText: loc.add_a_comment,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(24),
                                          borderSide: const BorderSide(color: Colors.grey),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(24),
                                          borderSide: const BorderSide(color: Colors.grey),
                                        ),
                                        suffixIcon: provider.inputController.text.trim().isNotEmpty
                                            ? IconButton(
                                          icon: const Icon(Icons.send),
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
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
