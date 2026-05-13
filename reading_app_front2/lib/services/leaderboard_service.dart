import 'dart:convert';
import 'package:http/http.dart' as http;

class LeaderboardService {
  static const String baseUrl = "http://192.168.34.252:8000/api";

  Future<List<Map<String, dynamic>>> getUsersProgress(String token) async {
    try {
      print("--- [بدء طلب البيانات من الباك-إند] ---");
      
      final response = await http.get(
        Uri.parse('$baseUrl/users_pogress_list'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', 
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final dynamic decodedResponse = json.decode(response.body);
        List<dynamic> rawData = [];

        if (decodedResponse is List) {
          rawData = decodedResponse;
        } else if (decodedResponse is Map && decodedResponse.containsKey('data')) {
          rawData = decodedResponse['data'];
        }

        // --- تعديل روابط الصور لتعمل على المحاكي ---
        return rawData.map((item) {
          Map<String, dynamic> userMap = Map<String, dynamic>.from(item);
          if (userMap['profile_img'] != null) {
            String img = userMap['profile_img'];
            // استبدال localhost أو 127.0.0.1 بـ IP الجهاز الحقيقي
            if (img.contains('localhost')) {
              userMap['profile_img'] = img.replaceAll('localhost', '192.168.34.252');
            } else if (img.contains('127.0.0.1')) {
              userMap['profile_img'] = img.replaceAll('127.0.0.1', '192.168.34.252');
            }
          }
          return userMap;
        }).toList();
      } 
      
      return [];
    } catch (e) {
      print("Unexpected Error: $e");
      return [];
    }
  }
}