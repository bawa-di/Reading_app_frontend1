import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:reading_app_front2/models/comment_model.dart';

class CommentService {
  // 💡 تأكدي أن الـ IP مطابق لجهازكِ الحالي دائماً عند تشغيل السيرفر محلياً
  final String baseUrl = "http://192.168.34.216:8000/api"; 

  /// 1. جلب تعليقات كتاب معين
  Future<Map<String, dynamic>> getBookComments({
    required int bookId,
    required String token,
  }) async {
    final url = Uri.parse('$baseUrl/comments/$bookId');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        List<dynamic> commentsJson = responseData['comments'];
        List<CommentModel> comments = commentsJson
            .map((json) => CommentModel.fromJson(json))
            .toList();
            
        return {'success': true, 'comments': comments};
      } else {
        return {'success': false, 'message': responseData['message'] ?? 'فشل جلب التعليقات'};
      }
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال: $e'};
    }
  }

  /// 2. إضافة تعليق جديد أو إرسال رد فرعي (متوافق تماماً مع Laravel Controller الخاص بكِ)
  Future<Map<String, dynamic>> addComment({
    required int bookId,
    required String content,
    required String token,
    int? parentId, // 👈 أضفنا هذا البارامتر الاختياري لتحديد ما إذا كان الطلب عبارة عن "رد"
  }) async {
    
    // 🧠 تحديد الرابط ديناميكياً بناءً على نوع العملية المتوقعة في الباك إند
    final url = parentId != null
        ? Uri.parse('$baseUrl/comments/$parentId/reply') // رابط الـ reply الخاص بكِ في Laravel
        : Uri.parse('$baseUrl/comments');               // رابط إضافة تعليق جديد عادي

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'book_id': bookId, // الـ Laravel يستخرج الـ book_id تلقائياً في الـ reply ولكن نرسله احتياطاً للاستقرار
          'content': content,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // 🔍 فحص ذكي: الباك إند يعيد المفتاح باسم 'reply' في حالة الرد، وباسم 'comment' في التعليق العادي
        final targetData = parentId != null 
            ? responseData['reply'] 
            : responseData['comment'];

        CommentModel newComment = CommentModel.fromJson(targetData);
        return {'success': true, 'comment': newComment};
      } else {
        return {'success': false, 'message': responseData['message'] ?? 'فشلت عملية الإرسال'};
      }
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال أثناء الإرسال: $e'};
    }
  }
  /// 4. تعديل تعليق أو رد موجود (متوافق مع دالة update في Laravel)
  Future<Map<String, dynamic>> updateComment({
    required int commentId,
    required String content,
    required String token,
  }) async {
    final url = Uri.parse('$baseUrl/comments/$commentId'); // ضرب الـ ID في المسار كما ينتظره الـ Controller

    try {
      final response = await http.put( // نستخدم PUT للتعديل
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'content': content,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        CommentModel updatedComment = CommentModel.fromJson(responseData['comment']);
        return {'success': true, 'comment': updatedComment};
      } else {
        return {'success': false, 'message': responseData['message'] ?? 'فشل تعديل التعليق'};
      }
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال أثناء التعديل: $e'};
    }
  }
  Future<Map<String, dynamic>> deleteComment({required int commentId, required String token}) async {
  try {
    final response = await http.delete(
      Uri.parse('$baseUrl/comments/$commentId'), // تأكدي من مطابقة الرابط تبع الـ Laravel عندكِ
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return {'success': true, 'message': 'تم حذف التعليق بنجاح'};
    } else {
      final data = jsonDecode(response.body);
      return {'success': false, 'message': data['message'] ?? 'فشل حذف التعليق'};
    }
  } catch (e) {
    return {'success': false, 'message': e.toString()};
  }
}
}