import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';

class BookService {
  static const String _baseUrl = 'http://192.168.34.216:8000/api';

  // دالة مساعدة لإنشاء الهيدرز
  Map<String, String> _getHeaders(String? token) {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // 1. دالة جلب كل الكتب
  Future<List<Book>> getAllBooks() async {
    final url = Uri.parse('$_baseUrl/books');
    try {
      final response = await http.get(url, headers: _getHeaders(null));

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = json.decode(response.body);
        if (decodedData['success'] == true && decodedData['data'] != null) {
          final List<dynamic> booksList = decodedData['data'];
          return booksList.map((item) => Book.fromJson(item)).toList();
        }
        return [];
      } else {
        throw Exception('فشل جلب الكتب: كود الحالة ${response.statusCode}');
      }
    } catch (e) {
      print('خطأ في الـ Service أثناء جلب الكتب: $e');
      rethrow;
    }
  }

  // 2. ✨ دالة جلب تفاصيل الكتاب (تمت إضافة التوكن كمتغير إجباري)
  Future<Map<String, dynamic>?> getBookDetailsRaw(int bookId, String token) async {
    final url = Uri.parse('$_baseUrl/books/$bookId');

    try {
      final response = await http.get(url, headers: _getHeaders(token));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('فشل جلب تفاصيل الكتاب: كود الحالة ${response.statusCode}');
      }
    } catch (e) {
      print('خطأ في الـ Service أثناء جلب تفاصيل الكتاب رقم $bookId: $e');
      rethrow;
    }
  }

// 3. دالة البحث المحدثة (تتعامل مع كل معايير السيرفر)
Future<List<Book>> searchBooksFromServer(Map<String, String> filters) async {
  // بناء الـ URL مع الـ Parameters
  // سيتحول الكود لشيء مثل: /books/search?title=...&author=...&gener=...&access_type=...
  final uri = Uri.parse('$_baseUrl/books/search').replace(queryParameters: filters);

  try {
    final response = await http.get(uri, headers: _getHeaders(null));

    if (response.statusCode == 200) {
      final Map<String, dynamic> decodedData = json.decode(response.body);
      if (decodedData['success'] == true && decodedData['data'] != null) {
        final List<dynamic> booksList = decodedData['data'];
        return booksList.map((item) => Book.fromJson(item)).toList();
      }
      return [];
    } else {
      throw Exception('فشل عملية البحث: كود الحالة ${response.statusCode}');
    }
  } catch (e) {
    print('خطأ في الـ Service أثناء البحث عن الكتب: $e');
    rethrow;
  }
}

  // 4. دالة إضافة كتاب إلى رفوف القراءة
  Future<Map<String, dynamic>> addBookToLibrary({
    required int bookId,
    required String status,
    required String token,
  }) async {
    final url = Uri.parse('$_baseUrl/book_list');

    try {
      final response = await http.post(
        url,
        headers: _getHeaders(token),
        body: jsonEncode({
          'book_id': bookId,
          'status': status,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'فشلت عملية حفظ الكتاب بالرفوف.',
        };
      }
    } catch (e) {
      print('خطأ في الـ Service أثناء إضافة كتاب للرف: $e');
      return {'success': false, 'message': 'تعذر الاتصال بالسيرفر.'};
    }
  }
}