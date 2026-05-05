import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// تأكدي أن هذا هو المسار الصحيح للموديل في مشروعك
import 'package:reading_app_front2/models/UserProfileModel.dart';

class UserProfileService {
  final String baseUrl = "http://192.168.34.252:8000/api";

  // التعديل هنا: الدالة يجب أن ترجع UserProfileModel وليس اسم الكلاس
  Future<UserProfileModel?> getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      print("Token is null");
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/info'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // التعديل هنا: نستخدم FromJson الخاص بالموديل
        return UserProfileModel.fromJson(json.decode(response.body));
      } else {
        print("Error: Status code ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Exception: $e");
      return null;
    }
  }
}
