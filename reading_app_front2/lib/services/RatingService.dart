import 'dart:convert';
import 'package:http/http.dart' as http;

class RatingService {
  final String baseUrl = "http://192.168.34.216:8000/api"; 

  // 1. إضافة أو تحديث تقييم
  Future<Map<String, dynamic>> submitRating(int bookId, int ratingValue, String token) async {
    final url = Uri.parse('$baseUrl/ratings/$bookId');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'rating': ratingValue}),
      );
      
      final data = jsonDecode(response.body);
      
      // التعديل: التأكد من التعامل مع كود الحالة 201 (Created) إذا كان لارافيل يرجعها
      return {
        'success': response.statusCode == 200 || response.statusCode == 201,
        'message': data['message'] ?? 'تم التقييم بنجاح',
        'rating': data['rating'],
      };
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالسيرفر'};
    }
  }

  // 2. جلب متوسط تقييم الكتاب
  Future<double> getAverageRating(int bookId) async {
    final url = Uri.parse('$baseUrl/ratings/$bookId/average');
    try {
      final response = await http.get(url, headers: {'Accept': 'application/json'});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // التعديل: التعامل مع حالة أن الحقل قد يكون فارغاً أو صفر
        if (data['average_rating'] != null) {
           return double.tryParse(data['average_rating'].toString()) ?? 0.0;
        }
      }
      return 0.0;
    } catch (_) {
      return 0.0;
    }
  }

  // 3. جلب تقييم المستخدم الحالي للكتاب
  Future<int> getUserRatingForBook(int bookId, String token) async {
    final url = Uri.parse('$baseUrl/ratings/$bookId');
    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      // التعديل: أحياناً لارافيل قد يرجع 404 إذا لم يجد تقييم، 
      // دالة getUserRatingForBook يجب أن تتعامل مع هذا بدون مشاكل
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return int.tryParse(data['rating'].toString()) ?? 0;
      }
      return 0; 
    } catch (_) {
      return 0;
    }
  }

  // 4. حذف التقييم
  Future<bool> deleteRating(int bookId, String token) async {
    final url = Uri.parse('$baseUrl/ratings/$bookId');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      // التعديل: الحذف غالباً يرجع 200 أو 204
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (_) {
      return false;
    }
  }
}