import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer'; // استيراد للمراقبة الاحترافية

class AuthService {
  static const String _baseUrl = "http://192.168.34.252:8000/api";
Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
    String? imagePath, 
  }) async {
    final url = Uri.parse('$_baseUrl/register');

    try {
      // نستخدم MultipartRequest لإرسال ملف حقيقي وليس مجرد نص
      var request = http.MultipartRequest('POST', url);

      // إضافة النصوص
      request.fields['name'] = name;
      request.fields['email'] = email.trim();
      request.fields['password'] = password;
      request.fields['password_confirmation'] = password;

      // إضافة الصورة كملف حقيقي (هذا ما يطلبه اللارافل)
      if (imagePath != null && imagePath.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath(
          'profile_img', // اسم الحقل في اللارافل
          imagePath,
        ));
      }

      // إضافة الـ Headers
      request.headers.addAll({
        'Accept': 'application/json',
      });

      print("--- [إرسال طلب Multipart] ---");
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print("Status: ${response.statusCode}");
      print("Body: ${response.body}");

      return {
        "status": response.statusCode,
        "body": jsonDecode(response.body)
      };
    } catch (e) {
      print("Error: $e");
      return {"status": 500, "body": {"message": "خطأ: $e"}};
    }
  }
  // --- دالة تسجيل الدخول ---
  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$_baseUrl/login');
    try {
      log("--- محاولة تسجيل الدخول ---");
      // تنظيف الإيميل من أي فراغات خفية
      final cleanEmail = email.trim(); 
      
      log("Sending Data: email: '$cleanEmail', password: '$password'");

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': cleanEmail, 
          'password': password
        }),
      );

      // طباعة الرد القادم من لارافل حرفياً
      log("Server Response Status: ${response.statusCode}");
      log("Server Response Body: ${response.body}");

      return {
        "status": response.statusCode, 
        "body": jsonDecode(response.body)
      };
    } catch (e) {
      log("Critical Connection Error: $e");
      return {
        "status": 500,
        "body": {"message": "خطأ في الاتصال بالسيرفر: $e"},
      };
    }
  }
}