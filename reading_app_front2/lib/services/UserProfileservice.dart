import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reading_app_front2/models/UserProfileModel.dart';
import 'package:http_parser/http_parser.dart';

class UserProfileService {
  final String baseUrl = "http://192.168.34.216:8000/api";

  Future<UserProfileModel?> getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) return null;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/info'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return UserProfileModel.fromJson(responseData);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<http.Response> updateProfile({
    String? name,
    String? email,
    String? password,
    String? passwordConfirmation,
    String? oldPassword,
    File? imageFile,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    print("--- بداية عملية التحديث ---");
    print("التوكن المستخدم: $token");

    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/update'));

    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    // خداع الطريقة للباك إند
    request.fields['_method'] = 'PUT';
    print("نوع الطلب (Spoofing): PUT");

    if (name != null) {
      request.fields['name'] = name;
      print("تم إضافة الاسم: $name");
    }
    if (email != null) {
      request.fields['email'] = email;
      print("تم إضافة الإيميل: $email");
    }

    if (password != null && password.isNotEmpty) {
      request.fields['password'] = password;
      request.fields['password_confirmation'] = passwordConfirmation ?? "";
      request.fields['old_password'] = oldPassword ?? "";
      print("تم إضافة حقول كلمة المرور");
    }

    // جزء الصورة مع الطباعة التفصيلية
    if (imageFile != null) {
      print("يوجد صورة جاري معالجتها...");
      print("مسار الصورة المحلي: ${imageFile.path}");

      String extension = imageFile.path.split('.').last;
      print("امتداد الصورة المعالج: $extension");

      var multipartFile = await http.MultipartFile.fromPath(
        'profile_img',
        imageFile.path,
        contentType: MediaType('image', extension),
      );

      request.files.add(multipartFile);
      print("تم إضافة الملف للطلب بنجاح (Key: profile_img)");
    } else {
      print("لا توجد صورة مرسلة في هذا الطلب");
    }

    try {
      print("جاري إرسال الطلب إلى السيرفر...");
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print("--- رد السيرفر ---");
      print("كود الحالة (Status Code): ${response.statusCode}");
      print("جسم الرد (Response Body): ${response.body}");

      return response;
    } catch (e) {
      print("خطأ فادح أثناء الإرسال: $e");
      rethrow;
    }
  }
}
