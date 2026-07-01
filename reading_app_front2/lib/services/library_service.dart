import 'dart:convert';
import 'package:http/http.dart' as http;

class LibraryService {
  static const String _baseUrl = 'http://192.168.34.216:8000/api';

  /// 1. جلب المكتبة (GET)
  Future<Map<String, dynamic>> getAllLibraryBooks(String token) async {
    final url = Uri.parse('$_baseUrl/book_list');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': responseData['data'] ?? {}};
      }
      return {'success': false, 'message': responseData['message'] ?? 'فشل جلب البيانات'};
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال'};
    }
  }

  /// 2. إضافة كتاب جديد للقائمة (POST) - تم التعديل لاستقبال رسائل الخطأ من الباك
  Future<Map<String, dynamic>> addBookToShelf(int bookId, String serverStatus, String token) async {
    final url = Uri.parse('$_baseUrl/book_list');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'book_id': bookId, 'status': serverStatus}),
      );

      // تحليل الرد دائماً لاستخراج رسالة الخطأ أو النجاح من الباك
      final Map<String, dynamic> responseData = json.decode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true, 
          'message': responseData['message'] ?? 'تمت الإضافة بنجاح',
          'data': responseData['data'] // مهمة جداً لتحديث اللقب أو حالة الكتاب
        };
      } else {
        // هنا نقوم بإرجاع الرسالة الحقيقية (مثل رسائل المنع في الباك)
        return {
          'success': false, 
          'message': responseData['message'] ?? 'فشل الإضافة'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالسيرفر'};
    }
  }

  /// 3. تحديث حالة كتاب موجود (PATCH)
  Future<Map<String, dynamic>> updateBookStatus(int bookId, String serverStatus, String token) async {
    final url = Uri.parse('$_baseUrl/book_list/$bookId');

    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'status': serverStatus}),
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true, 
          'message': responseData['message'] ?? 'تم التحديث بنجاح',
          'data': responseData['data']
        };
      }
      return {'success': false, 'message': responseData['message'] ?? 'فشل التحديث'};
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالسيرفر'};
    }
  }

  /// 4. حذف كتاب (DELETE)
  Future<Map<String, dynamic>> removeBookFromShelf(int bookId, String token) async {
    final url = Uri.parse('$_baseUrl/book_list/$bookId');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': responseData['message'] ?? 'تم الحذف بنجاح'};
      }
      return {'success': false, 'message': responseData['message'] ?? 'فشل الحذف'};
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال'};
    }
  }
  /// 5. تحديث تقدم القراءة (POST)
  Future<Map<String, dynamic>> updateReadProgress(int bookId, int pages, String token) async {
    final url = Uri.parse('$_baseUrl/read-progress/update');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'book_id': bookId, 
          'pages': pages
        }),
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      // الـ Controller الخاص بكِ يرجع 200 عند النجاح، أو 403/404 عند الفشل
      if (response.statusCode == 200) {
        return {
          'success': true,
          'pages_read': responseData['pages_read'],
          'message': 'تم حفظ التقدم'
        };
      } else {
        // هنا نلتقط رسائل المنع (مثل: الحد التجريبي أو لم يدفع)
        return {
          'success': false,
          'message': responseData['message'] ?? 'فشل تحديث التقدم'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالسيرفر'};
    }
  }
  
}