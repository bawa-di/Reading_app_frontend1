import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// تأكدي من صحة المسار حسب بنية مجلداتك
import 'package:reading_app_front2/models/UserProfileModel.dart';

class UserProfileService {
  // ملاحظة: تأكدي أن الـ IP ما زال نفسه إذا تغيرت شبكة الـ Wi-Fi
  final String baseUrl = "http://192.168.34.252:8000/api";

  Future<UserProfileModel?> getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      print("خطأ: التوكن غير موجود (Token is null)");
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/info'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // نقوم بفك تشفير الـ JSON القادم من الـ Laravel
        final Map<String, dynamic> responseData = json.decode(response.body);

        // نتحقق من نجاح العملية حسب حقل success الذي أضافته زميلتك في الباك إند
        if (responseData['success'] == true) {
          // نمرر الـ JSON كاملاً للموديل، وهو سيتعامل مع الـ 'data' والـ 'stats'
          return UserProfileModel.fromJson(responseData);
        } else {
          print("الباك إند أرجع خطأ: ${responseData['message']}");
          return null;
        }
      } else {
        print("خطأ في السيرفر: Status code ${response.statusCode}");
        return null;
      }
    } catch (e) {
      // التعامل مع أخطاء الشبكة أو الاتصال بالسيرفر المحلي
      print("Exception during fetching user info: $e");
      return null;
    }
  }
}