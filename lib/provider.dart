
import 'package:cdx_comments/validator.dart';
import 'package:flutter/material.dart';
import 'controller.dart';
import 'models/comment.dart';

class CommentProvider with ChangeNotifier {
  final CommentController controller;
  final String postId;
  final TextEditingController inputController = TextEditingController();
  final CommentValidator validator = CommentValidator();

  CommentProvider({required this.controller, required this.postId}) {
    loadComments();
    inputController.addListener(() {
      notifyListeners();
    });
  }

  List<Comment> _comments = [];
  List<Comment> get comments => _comments;

  Comment? _replyingTo;
  Comment? get replyingTo => _replyingTo;

  void setReplyTo(Comment? comment) {
    _replyingTo = comment;
    notifyListeners();
  }

  Future<void> loadComments() async {
    _comments = await controller.fetchComments(postId);
    notifyListeners();
  }

  Future<void> addComment(String content) async {
    final Comment? comment = await controller.postComment(postId, content);
    if (comment == null) return;
    _comments.insert(0, comment);
    notifyListeners();
  }

  Future<void> replyTo(String entityId, String parentId, String content) async {
    final Comment? comment = await controller.postReply(entityId, parentId, content);
    if (comment == null) return;
    final index = _comments.indexWhere((c) => c.id == parentId);
    if (index != -1) {
      _comments[index].replies.add(comment);
      notifyListeners();
    }
  }

  Future<void> toggleLike(String commentId) async {
    final Comment? comment = await controller.toggleLike(commentId);
    if (comment == null) return;
    final index = _comments.indexWhere((c) => c.id == commentId);
    if (index != -1) {
      _comments[index] = comment.copyWith(replies: _comments[index].replies);
      notifyListeners();
    }
  }

  Future<void> deleteComment(String commentId) async {
    await controller.deleteComment(commentId);
    _comments.removeWhere((c) => c.id == commentId);

    notifyListeners();
  }

  Future<void> expandReplies(String commentId) async {
    final index = _comments.indexWhere((c) => c.id == commentId);
    if (index != -1) {
      final replies = await controller.getReplies(commentId);
      _comments[index] = _comments[index].copyWith(replies: replies);
      notifyListeners();
    }
  }

  Future<void> toggleReplyLike(String parentId, String replyId) async {
    final Comment? updatedReply = await controller.toggleLike(replyId);
    if (updatedReply == null) return;

    final parentIndex = _comments.indexWhere((c) => c.id == parentId);
    if (parentIndex == -1) return;

    final replyIndex = _comments[parentIndex].replies.indexWhere((r) => r.id == replyId);
    if (replyIndex == -1) return;

    final updatedReplies = [..._comments[parentIndex].replies];
    updatedReplies[replyIndex] = updatedReply;

    _comments[parentIndex] = _comments[parentIndex].copyWith(replies: updatedReplies);
    notifyListeners();
  }

  Future<void> deleteReply(String parentId, String replyId) async {
    await controller.deleteComment(replyId);

    final parentIndex = _comments.indexWhere((c) => c.id == parentId);
    if (parentIndex == -1) return;

    final updatedReplies = _comments[parentIndex]
        .replies
        .where((r) => r.id != replyId)
        .toList();

    _comments[parentIndex] = _comments[parentIndex].copyWith(
        replies: updatedReplies,
        replyCount: updatedReplies.length
    );
    notifyListeners();
  }

  void sendComment(AppLocalizations loc, {required void Function(String) onInputError}) async {
    final text = inputController.text.trim();
    if (text.isEmpty) return;

    final error = await validator.validate(text, loc);
    if (error != null) {
      onInputError(error);
      return;
    }

    if (replyingTo != null) {
      replyTo(
        postId,
        replyingTo!.id,
        text,
      );
      setReplyTo(null);
    } else {
      addComment(text);
    }
    inputController.clear();
  }
}
