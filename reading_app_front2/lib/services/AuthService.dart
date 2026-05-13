import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _baseUrl = "http://192.168.34.252:8000/api";

  // --- دالة تسجيل حساب جديد ---
  Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
    String? imagePath,
  }) async {
    final url = Uri.parse('$_baseUrl/register');

    try {
      var request = http.MultipartRequest('POST', url);

      request.fields['name'] = name;
      request.fields['email'] = email.trim();
      request.fields['password'] = password;
      request.fields['password_confirmation'] = password;

      if (imagePath != null && imagePath.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath('profile_img', imagePath),
        );
      }

      request.headers.addAll({'Accept': 'application/json'});

      log("--- [إرسال طلب Multipart: Register] ---");
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      log("Status: ${response.statusCode}");
      log("Body: ${response.body}");

      return {"status": response.statusCode, "body": jsonDecode(response.body)};
    } catch (e) {
      log("Error during Register: $e");
      return {
        "status": 500,
        "body": {"message": "خطأ: $e"},
      };
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
      final cleanEmail = email.trim();

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': cleanEmail, 'password': password}),
      );

      log("Server Response Status: ${response.statusCode}");
      log("Server Response Body: ${response.body}");

      return {"status": response.statusCode, "body": jsonDecode(response.body)};
    } catch (e) {
      log("Critical Connection Error: $e");
      return {
        "status": 500,
        "body": {"message": "خطأ في الاتصال بالسيرفر: $e"},
      };
    }
  }

  // --- دالة تسجيل الخروج ---
  Future<Map<String, dynamic>> logoutUser() async {
    final url = Uri.parse('$_baseUrl/logout');
    try {
      log("--- محاولة تسجيل الخروج من السيرفر ---");

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        log("No token found in SharedPreferences");
        return {
          "status": 401,
          "body": {"message": "لم يتم العثور على توكن"},
        };
      }

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      log("Server Response Status: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 401) {
        await prefs.remove('token');
        log("Token removed from SharedPreferences successfully");
      }

      return {"status": response.statusCode, "body": jsonDecode(response.body)};
    } catch (e) {
      log("Logout Error: $e");
      return {
        "status": 500,
        "body": {"message": "خطأ في الاتصال أثناء تسجيل الخروج: $e"},
      };
    }
  }

  // --- دالة حذف الحساب (الجديدة) ---
  Future<Map<String, dynamic>> deleteAccount() async {
    final url = Uri.parse(
      '$_baseUrl/delete-account',
    ); // تأكدي أن هذا الرابط يطابق الـ Route في Laravel
    try {
      log("--- محاولة حذف الحساب من السيرفر ---");

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        log("Delete Account Error: No token found");
        return {
          "status": 401,
          "body": {"message": "غير مصرح لك بالدخول"},
        };
      }

      final response = await http.delete(
        // أو http.delete حسب تعريفك في الـ Routes
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      log("Server Response Status (Delete): ${response.statusCode}");
      log("Server Response Body (Delete): ${response.body}");

      // إذا نجح الحذف في السيرفر، نمسح التوكن فوراً من الجهاز
      if (response.statusCode == 200) {
        await prefs.remove('token');
        log("Account deleted and token removed from SharedPreferences");
      }

      return {"status": response.statusCode, "body": jsonDecode(response.body)};
    } catch (e) {
      log("Delete Account Connection Error: $e");
      return {
        "status": 500,
        "body": {"message": "خطأ في الاتصال أثناء حذف الحساب: $e"},
      };
    }
  }
}
