import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reading_app_front2/models/book.dart'; // تأكدي من صحة مسار الموديل في مشروعكِ

class FavoriteService {
  final String baseUrl = 'http://192.168.34.216:8000/api';

  // تابع جلب التوكن المحفوظ تلقائياً من الـ SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token'); 
    debugPrint('FavoriteService: Token retrieved = $token');
    return token;
  }

  // 🟢 جلب قائمة الكتب المفضلة كاملة مع معالجة العلاقات (Relations) والـ Maps في لارافيل
  Future<List<Book>> fetchFavorites() async {
    final token = await _getToken();
    if (token == null) {
      debugPrint('FavoriteService Fetch: لم يتم العثور على توكن!');
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/favorites'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('FavoriteService Fetch: Status Code = ${response.statusCode}');
      debugPrint('FavoriteService Fetch: Response Body = ${response.body}');

      if (response.statusCode == 200) {
        final dynamic decodedData = jsonDecode(response.body);
        
        List<dynamic> list = [];

        // 1. استخراج القائمة الأساسية سواء كانت قادمة كـ Map أو List مباشرة
        if (decodedData is Map) {
          if (decodedData.containsKey('data')) {
            list = decodedData['data'];
          } else if (decodedData.containsKey('favorites')) {
            list = decodedData['favorites'];
          } else if (decodedData.containsKey('books')) {
            list = decodedData['books'];
          } else {
            list = decodedData.values.toList();
          }
        } else if (decodedData is List) {
          list = decodedData;
        }

        // 2. الحل السحري لتعبئة البيانات: الدخول إلى كائن العلاقة الداخلي 'book' إذا وُجد
        return list.map<Book>((item) {
          if (item is Map && item.containsKey('book') && item['book'] != null) {
            debugPrint('🎯 تم العثور على علاقة book داخل المفضلة للكتاب: ${item['book']['title']}');
            return Book.fromJson(item['book']); // نقوم بتحويل كائن الكتاب الفعلي المليء بالبيانات والـ ID الصحيح
          }
          // إذا كان لارافيل يرسل بيانات الكتاب مباشرة كـ سطر عادي بدون علاقة مدمجة
          return Book.fromJson(item);
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching favorites from server: $e');
      return [];
    }
  }

  // إرسال طلب إضافة كتاب للمفضلة إلى السيرفر
  Future<bool> addToFavorites(int bookId) async {
    final token = await _getToken();
    if (token == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/add_favorites'), 
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', 
        },
        body: jsonEncode({'book_id': bookId}),
      );

      debugPrint('FavoriteService: Add response code = ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 409) {
        return true; 
      }
      return false;
    } catch (e) {
      debugPrint('Error adding to favorites: $e');
      return false;
    }
  }

  // دالة إلغاء المفضلة (الحذف) برابط مباشر متوافقة مع الـ Route::delete في لارافيل
  Future<bool> removeFromFavorites(int bookId) async {
    final token = await _getToken();
    if (token == null) return false;

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/delete_favorites/$bookId'), 
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('FavoriteService: Remove response code = ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true; 
      }
      return false;
    } catch (e) {
      debugPrint('Error removing from favorites: $e');
      return false;
    }
  }
}