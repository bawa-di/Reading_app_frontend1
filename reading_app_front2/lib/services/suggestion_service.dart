import 'dart:convert';
import 'package:http/http.dart' as http;

class SuggestionService {
  // 💡 الرابط الخاص بجهازكِ الحالي متصل بشبكة الـ Wi-Fi المشتركة
  final String baseUrl = "http://192.168.34.216:8000/api"; 

  // 1️⃣ دالة إرسال اقتراح جديد (صحيحة وتم تأمين الـ StatusCode للنجاح)
  Future<Map<String, dynamic>> submitSuggestion({
    required String token,
    required String title,
    required String author,
    String? description,
    int? relatedBookId,
  }) async {
    final url = Uri.parse('$baseUrl/suggestions');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'title': title,
          'author': author,
          'description': description,
          'related_book_id': relatedBookId,
        }),
      );

      final responseData = jsonDecode(response.body);

      // تأمين قراءة كود 200 أو 201 حسب رد الـ Laravel لضمان الاستقرار
      if ((response.statusCode == 200 || response.statusCode == 201) && responseData['success'] == true) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'تم إرسال الاقتراح بنجاح',
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'فشل إرسال الاقتراح',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'حدث خطأ في الاتصال بالسيرفر: $e',
      };
    }
  }

  // 2️⃣ دالة جلب اقتراحات المستخدم الحالي (مضافة للربط مع دالة mySuggestions في Laravel)
  Future<Map<String, dynamic>> fetchUserSuggestions({required String token}) async {
    // 💡 تأكدي أن مسار الـ Route عند زميلتكِ هو 'my-suggestions' أو عدليه لما يتوافق معها
    final url = Uri.parse('$baseUrl/suggestions/mine'); 

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
        return {
          'success': true,
          'data': responseData['data'], // يحتوي على الـ List القادمة من الباك إند
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'فشل تحميل اقتراحاتكِ',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'حدث خطأ في الاتصال بالسيرفر: $e',
      };
    }
  }
}