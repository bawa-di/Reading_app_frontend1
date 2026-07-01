import 'package:flutter/material.dart';
import 'package:reading_app_front2/models/comment_model.dart';
import 'package:reading_app_front2/services/comment_service.dart';

class CommentProvider with ChangeNotifier {
  final CommentService _commentService = CommentService();

  List<CommentModel> _comments = [];
  List<CommentModel> get comments => _comments;

  // --- التعديلات الخاصة بإخفاء/عرض الردود ---
  final Set<int> _visibleReplyIds = {};

  bool isReplyVisible(int commentId) => _visibleReplyIds.contains(commentId);

  void toggleReplies(int commentId) {
    if (_visibleReplyIds.contains(commentId)) {
      _visibleReplyIds.remove(commentId);
    } else {
      _visibleReplyIds.add(commentId);
    }
    notifyListeners();
  }
  // ------------------------------------------

  bool _isFetching = false;
  bool get isFetching => _isFetching;

  bool _isSending = false;
  bool get isSending => _isSending;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  /// 1. دالة جلب التعليقات
  Future<void> fetchComments({required int bookId, required String token}) async {
    _isFetching = true;
    _errorMessage = '';
    _comments = [];
    notifyListeners();

    final result = await _commentService.getBookComments(bookId: bookId, token: token);

    if (result['success'] == true) {
      List<CommentModel> fetchedComments = result['comments'];
      fetchedComments.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      _comments = fetchedComments;
    } else {
      _errorMessage = result['message'] ?? 'فشل جلب التعليقات';
    }

    _isFetching = false;
    notifyListeners();
  }

  /// 2. إرسال تعليق جديد
  Future<bool> sendComment({
    required int bookId,
    required String content,
    required String token,
  }) async {
    if (content.trim().isEmpty) return false;

    _isSending = true;
    _errorMessage = '';
    notifyListeners();

    final result = await _commentService.addComment(
      bookId: bookId,
      content: content,
      token: token,
    );

    if (result['success'] == true) {
      CommentModel newComment = result['comment'];
      _comments.add(newComment);
      _isSending = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'] ?? 'فشل إرسال التعليق';
      _isSending = false;
      notifyListeners();
      return false;
    }
  }

  /// 3. إرسال الردود
  Future<bool> sendReply({
    required int bookId,
    required int parentId,
    required String content,
    required String token,
  }) async {
    if (content.trim().isEmpty) return false;

    _isSending = true;
    _errorMessage = '';
    notifyListeners();

    final result = await _commentService.addComment(
      bookId: bookId,
      content: content,
      token: token,
      parentId: parentId,
    );

    if (result['success'] == true) {
      CommentModel newReply = result['comment'];
      final parentIndex = _comments.indexWhere((c) => c.id == parentId);
      
      if (parentIndex != -1) {
        _comments[parentIndex].replies.add(newReply);
        // ضمان بقاء الردود مفتوحة عند إضافة رد جديد
        _visibleReplyIds.add(parentId);
      }

      _isSending = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'] ?? 'فشل إرسال الرد';
      _isSending = false;
      notifyListeners();
      return false;
    }
  }

  /// 4. تعديل التعليق
  Future<bool> editComment({
    required int commentId,
    required String content,
    required String token,
  }) async {
    if (content.trim().isEmpty) return false;

    _isSending = true; 
    _errorMessage = '';
    notifyListeners();

    final result = await _commentService.updateComment(
      commentId: commentId,
      content: content,
      token: token,
    );

    if (result['success'] == true) {
      final mainCommentIndex = _comments.indexWhere((c) => c.id == commentId);
      
      if (mainCommentIndex != -1) {
        _comments[mainCommentIndex] = _comments[mainCommentIndex].copyWith(content: content);
      } else {
        for (var mainComment in _comments) {
          final replyIndex = mainComment.replies.indexWhere((r) => r.id == commentId);
          if (replyIndex != -1) {
            mainComment.replies[replyIndex] = mainComment.replies[replyIndex].copyWith(content: content);
            break;
          }
        }
      }

      _isSending = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'] ?? 'فشل تعديل التعليق';
      _isSending = false;
      notifyListeners();
      return false;
    }
  }

  /// 5. حذف التعليق
  Future<bool> deleteComment({required int commentId, required String token}) async {
    _isSending = true;
    _errorMessage = '';
    notifyListeners();

    final result = await _commentService.deleteComment(commentId: commentId, token: token);

    if (result['success'] == true) {
      final mainIndex = _comments.indexWhere((c) => c.id == commentId);
      
      if (mainIndex != -1) {
        _comments.removeAt(mainIndex);
      } else {
        for (var mainComment in _comments) {
          final replyIndex = mainComment.replies.indexWhere((r) => r.id == commentId);
          if (replyIndex != -1) {
            mainComment.replies.removeAt(replyIndex);
            break;
          }
        }
      }

      _isSending = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'] ?? 'فشل حذف التعليق';
      _isSending = false;
      notifyListeners();
      return false;
    }
  }
}