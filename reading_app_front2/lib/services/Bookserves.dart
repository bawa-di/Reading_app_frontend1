import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';

class BookService {
  static const String _baseUrl = 'http://192.168.34.216:8000/api';

  // 1. دالة جلب كل الكتب
  Future<List<Book>> getAllBooks() async {
    final url = Uri.parse('$_baseUrl/books');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

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

  // 2. ✨ دالة جلب تفاصيل الكتاب المحدثة (ترجع الـ Map كاملة لتشمل الكتب المشابهة)
  Future<Map<String, dynamic>?> getBookDetailsRaw(int bookId) async {
    final url = Uri.parse('$_baseUrl/books/$bookId');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = json.decode(response.body);
        return decodedData; // نعيد الـ Map بالكامل (تحتوي على الكتاب و similar_books)
      } else {
        throw Exception(
          'فشل جلب تفاصيل الكتاب: كود الحالة ${response.statusCode}',
        );
      }
    } catch (e) {
      print('خطأ في الـ Service أثناء جلب تفاصيل الكتاب رقم $bookId: $e');
      rethrow;
    }
  }

  // 3. دالة البحث الموحدة والذكية
  Future<List<Book>> searchBooksFromServer(String queryText) async {
    final String cleanQuery = Uri.encodeComponent(queryText.trim());
    final url = Uri.parse('$_baseUrl/books/search?search=$cleanQuery');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

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

  // 4. دالة إضافة كتاب إلى رفوف القراءة (POST /book_list)
  Future<Map<String, dynamic>> addBookToLibrary({
    required int bookId,
    required String status,
    required String token,
  }) async {
    final url = Uri.parse('$_baseUrl/book_list');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', 
        },
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
      return {
        'success': false,
        'message': 'تعذر الاتصال بالسيرفر، يرجى التحقق من الشبكة.',
      };
    }
  }
}