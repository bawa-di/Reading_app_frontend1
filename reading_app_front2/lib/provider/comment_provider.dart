import 'package:flutter/material.dart';
import 'package:reading_app_front2/models/comment_model.dart';
import 'package:reading_app_front2/services/comment_service.dart';

class CommentProvider with ChangeNotifier {
  final CommentService _commentService = CommentService();

  List<CommentModel> _comments = [];
  List<CommentModel> get comments => _comments;

  // حالة جلب البيانات (Loading عند فتح الصفحة)
  bool _isFetching = false;
  bool get isFetching => _isFetching;

  // حالة إرسال البيانات (Loading عند الضغط على زر إرسال)
  bool _isSending = false;
  bool get isSending => _isSending;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  /// 1. دالة جلب تعليقات الكتاب وتخزينها
  Future<void> fetchComments({required int bookId, required String token}) async {
    _isFetching = true;
    _errorMessage = '';
    _comments = [];
    notifyListeners();

    final result = await _commentService.getBookComments(bookId: bookId, token: token);

    if (result['success'] == true) {
      _comments = result['comments'];
    } else {
      _errorMessage = result['message'] ?? 'فشل جلب التعليقات';
    }

    _isFetching = false;
    notifyListeners();
  }

  /// 2. دالة إرسال تعليق جديد وتحديث الواجهة فوراً
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
      
      // إدخال التعليق الجديد أول القائمة المحلية ليعرض للمستخدم فوراً
      _comments.insert(0, newComment);
      
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

  /// 3. دالة إرسال الردود وتحديث القائمة محلياً
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

  /// 4. 🚀 دالة تعديل التعليق المحدثة كلياً بالـ copyWith وبدون أي أخطاء
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
      // البحث عن التعليق فيما إذا كان تعليقاً رئيسياً
      final mainCommentIndex = _comments.indexWhere((c) => c.id == commentId);
      
      if (mainCommentIndex != -1) {
        // جلب الوقت الجديد الراجع من السيرفر إذا كان موجوداً
        String? newCreatedAt = (result['comment'] != null && result['comment'] is CommentModel) 
            ? result['comment'].createdAt 
            : null;
        
        // 🔥 استخدام copyWith لتجاوز الـ final بنجاح
        _comments[mainCommentIndex] = _comments[mainCommentIndex].copyWith(
          content: content,
          createdAt: newCreatedAt,
        );
      } else {
        // إذا لم يكن رئيسياً، نبحث عنه داخل الـ replies الخاصة بكل تعليق
        for (var mainComment in _comments) {
          final replyIndex = mainComment.replies.indexWhere((r) => r.id == commentId);
          if (replyIndex != -1) {
            String? newCreatedAt = (result['comment'] != null && result['comment'] is CommentModel) 
                ? result['comment'].createdAt 
                : null;
            
            // 🔥 استخدام copyWith للردود وتجاوز الـ final بنجاح
            mainComment.replies[replyIndex] = mainComment.replies[replyIndex].copyWith(
              content: content,
              createdAt: newCreatedAt,
            );
            break;
          }
        }
      }

      _isSending = false;
      notifyListeners(); // تحديث فوري للـ UI
      return true;
    } else {
      _errorMessage = result['message'] ?? 'فشل تعديل التعليق';
      _isSending = false;
      notifyListeners();
      return false;
    }
  }
  /// 5. دالة حذف التعليق أو الرد وتحديث القائمة محلياً فوراً
  Future<bool> deleteComment({required int commentId, required String token}) async {
    _isSending = true; // نستخدم المؤشر لمنع الضغط المتكرر أثناء الحذف
    _errorMessage = '';
    notifyListeners();

    final result = await _commentService.deleteComment(commentId: commentId, token: token);

    if (result['success'] == true) {
      // 🧠 البحث والحذف: هل هو تعليق رئيسي؟
      final mainIndex = _comments.indexWhere((c) => c.id == commentId);
      
      if (mainIndex != -1) {
        // إذا تعليق رئيسي، بنحذفه من القائمة الأساسية
        _comments.removeAt(mainIndex);
      } else {
        // 🔍 إذا ما لقيناه بالرئيسي، بكون "رد"، بنلف على الردود جوات كل تعليق وبنحذفه
        for (var mainComment in _comments) {
          final replyIndex = mainComment.replies.indexWhere((r) => r.id == commentId);
          if (replyIndex != -1) {
            mainComment.replies.removeAt(replyIndex);
            break;
          }
        }
      }

      _isSending = false;
      notifyListeners(); // تحديث فوري للواجهة بعد الحذف
      return true;
    } else {
      _errorMessage = result['message'] ?? 'فشل حذف التعليق';
      _isSending = false;
      notifyListeners();
      return false;
    }
  }
}