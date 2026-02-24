import 'package:cdx_comments/l10n/app_localizations.dart';
import 'package:cdx_comments/validator.dart';
import 'package:flutter/material.dart';
import 'controller.dart';
import 'models/comment.dart';

/// Provider for managing comment state and UI interactions.
///
/// This class manages the state of comments for a specific entity (post).
/// It handles loading, adding, replying, liking, and deleting comments,
/// and notifies listeners when the state changes.
///
/// Example:
/// ```dart
/// final provider = CommentProvider(
///   controller: commentController,
///   postId: 'post-123',
///   validator: commentValidator,
/// );
/// ```
class CommentProvider with ChangeNotifier {
  /// The controller for comment operations.
  final CommentController controller;
  
  /// The ID of the entity (post) this provider manages comments for.
  final String postId;
  
  /// Text editing controller for the comment input field.
  final TextEditingController inputController = TextEditingController();
  
  /// Validator for comment content.
  final CommentValidator validator;
  
  /// Creates a new [CommentProvider].
  ///
  /// Automatically loads comments for [postId] on initialization.
  /// Sets up a listener on [inputController] to notify listeners when input changes.
  ///
  /// All parameters are required:
  /// - [controller]: The [CommentController] to use for operations
  /// - [postId]: The ID of the entity to manage comments for
  /// - [validator]: The [CommentValidator] to validate comment content
  CommentProvider({
    required this.controller,
    required this.postId,
    required this.validator,
  }) {
    loadComments();
    inputController.addListener(() {
      notifyListeners();
    });
  }

  List<Comment> _comments = [];
  final Map<String, int> _replyPageByComment = {};
  
  /// The list of comments for this entity.
  ///
  /// This list contains only root comments (top-level comments without a parent).
  /// Replies are nested within each comment's [Comment.replies] list.
  List<Comment> get comments => _comments;

  /// The comment currently being replied to, if any.
  Comment? _replyingTo;
  
  /// The comment that the user is currently replying to.
  ///
  /// Returns `null` if the user is not replying to any comment.
  Comment? get replyingTo => _replyingTo;

  /// Sets the comment to reply to.
  ///
  /// When a user starts replying to a comment, call this method with that comment.
  /// Set to `null` to cancel the reply.
  ///
  /// [comment] is the comment to reply to, or `null` to clear the reply target.
  void setReplyTo(Comment? comment) {
    _replyingTo = comment;
    notifyListeners();
  }

  /// Loads comments for the entity.
  ///
  /// Fetches all root comments from the server and updates the [comments] list.
  /// Notifies listeners when the operation completes.
  Future<void> loadComments() async {
    _comments = await controller.fetchComments(postId);
    notifyListeners();
  }

  /// Adds a new comment to the entity.
  ///
  /// Creates a new top-level comment (not a reply).
  /// The comment is inserted at the beginning of the [comments] list.
  ///
  /// [content] is the text content of the comment.
  ///
  /// If the comment creation fails, this method does nothing (the comment
  /// is not added to the list).
  Future<void> addComment(String content) async {
    final Comment? comment = await controller.postComment(postId, content);
    if (comment == null) return;
    _comments.insert(0, comment);
    notifyListeners();
  }

  /// Adds a reply to a comment.
  ///
  /// Creates a new reply to the specified parent comment and adds it to
  /// that comment's replies list.
  ///
  /// [entityId] is the identifier of the entity.
  /// [parentId] is the ID of the comment being replied to.
  /// [content] is the text content of the reply.
  ///
  /// If the reply creation fails or the parent comment is not found,
  /// this method does nothing.
  Future<void> replyTo(String entityId, String parentId, String content) async {
    final Comment? comment = await controller.postReply(entityId, parentId, content);
    if (comment == null) return;
    final index = _comments.indexWhere((c) => c.id == parentId);
    if (index != -1) {
      final updatedReplies = [..._comments[index].replies, comment];
      _comments[index] = _comments[index].copyWith(replies: updatedReplies);
      notifyListeners();
    }
  }

  /// Toggles the like status of a comment.
  ///
  /// Updates the comment's like status and count in the local state.
  /// The comment must be in the [comments] list for the update to take effect.
  ///
  /// [commentId] is the ID of the comment to toggle like for.
  ///
  /// If the operation fails or the comment is not found, this method does nothing.
  Future<void> toggleLike(String commentId) async {
    final Comment? comment = await controller.toggleLike(commentId);
    if (comment == null) return;
    final index = _comments.indexWhere((c) => c.id == commentId);
    if (index != -1) {
      _comments[index] = comment.copyWith(replies: _comments[index].replies);
      notifyListeners();
    }
  }

  /// Deletes a comment from the list.
  ///
  /// Removes the comment from the [comments] list and deletes it from the server.
  ///
  /// [commentId] is the ID of the comment to delete.
  ///
  /// Note: This only deletes root comments. To delete a reply, use [deleteReply].
  Future<void> deleteComment(String commentId) async {
    await controller.deleteComment(commentId);
    _comments.removeWhere((c) => c.id == commentId);

    notifyListeners();
  }

  Future<void> expandReplies(String commentId) async {
    final index = _comments.indexWhere((c) => c.id == commentId);
    if (index != -1) {
      final replies = await controller.getReplies(commentId, 1);
      _comments[index] = _comments[index].copyWith(replies: replies);
      _replyPageByComment[commentId] = 1;
      notifyListeners();
    }
  }

  Future<void> loadMoreReplies(String commentId) async {
    final index = _comments.indexWhere((c) => c.id == commentId);
    if (index == -1) return;
    final nextPage = (_replyPageByComment[commentId] ?? 1) + 1;
    final more = await controller.getReplies(commentId, nextPage);
    if (more.isEmpty) return;
    _replyPageByComment[commentId] = nextPage;
    final c = _comments[index];
    _comments[index] = c.copyWith(replies: [...c.replies, ...more]);
    notifyListeners();
  }

  /// Toggles the like status of a reply.
  ///
  /// Updates a reply's like status and count within a parent comment's replies list.
  ///
  /// [parentId] is the ID of the parent comment.
  /// [replyId] is the ID of the reply to toggle like for.
  ///
  /// If the parent comment or reply is not found, this method does nothing.
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

  /// Deletes a reply from a parent comment.
  ///
  /// Removes the reply from the parent comment's replies list and deletes it from the server.
  /// Also updates the parent comment's [Comment.replyCount].
  ///
  /// [parentId] is the ID of the parent comment.
  /// [replyId] is the ID of the reply to delete.
  ///
  /// If the parent comment is not found, this method does nothing.
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

  /// Sends a comment or reply based on the current state.
  ///
  /// Validates the content in [inputController], then either:
  /// - Adds a new comment if [replyingTo] is `null`
  /// - Adds a reply if [replyingTo] is not `null`
  ///
  /// After sending, clears the input field and resets [replyingTo] if it was set.
  ///
  /// [loc] is the [CdxCommentsLocalizations] instance for error messages.
  /// [onInputError] is a callback that will be called with an error message
  /// if validation fails.
  ///
  /// If the input is empty, this method returns without doing anything.
  void sendComment(CdxCommentsLocalizations loc, {required void Function(String) onInputError}) async {
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
