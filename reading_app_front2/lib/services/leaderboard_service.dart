import 'dart:convert';
import 'package:http/http.dart' as http;

class LeaderboardService {
  static const String myIp = "192.168.34.216";
  static const String baseUrl = "http://$myIp:8000/api";

  // دالة لتنظيف الروابط وتجنب الأخطاء إذا كانت القيمة null
  String _fixImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return "";
    return imageUrl
        .replaceAll('localhost', myIp)
        .replaceAll('127.0.0.1', myIp);
  }

  // --- 1. جلب قائمة المستخدمين (العامة) ---
  Future<List<Map<String, dynamic>>> getUsersProgress(String token) async {
    return _fetchData(token, '$baseUrl/users_pogress_list');
  }

  // --- 2. جلب قائمة المتابعين ---
  Future<List<Map<String, dynamic>>> getFollowers(String token) async {
    return _fetchData(token, '$baseUrl/followers');
  }

  // --- 3. جلب قائمة الذين أتابعهم ---
  Future<List<Map<String, dynamic>>> getFollowing(String token) async {
    return _fetchData(token, '$baseUrl/following');
  }

  // --- 4. جلب تفاصيل مستخدم محدد (لـ Sheet التفاصيل) ---
  Future<Map<String, dynamic>?> getFollowedUserDetails(String token, int followedUserId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/followed_users/$followedUserId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          // تنظيف صورة البروفايل
          if (data['data']['profile_img'] != null) {
            data['data']['profile_img'] = _fixImageUrl(data['data']['profile_img'].toString());
          }
          return data['data']; 
        }
      }
      return null;
    } catch (e) {
      print("❌ Error fetching user details: $e");
      return null;
    }
  }

  // --- 5. دالة المتابعة (Follow) ---
  Future<Map<String, dynamic>> followUser(String token, int userId) async {
    return _sendPostOrDelete(token, '$baseUrl/follow/$userId', 'POST');
  }

  // --- 6. دالة إلغاء المتابعة (Unfollow) ---
  Future<Map<String, dynamic>> unfollowUser(String token, int userId) async {
    return _sendPostOrDelete(token, '$baseUrl/unfollow/$userId', 'DELETE');
  }

  // --- دالة موحدة لـ POST و DELETE ---
  Future<Map<String, dynamic>> _sendPostOrDelete(String token, String url, String method) async {
    try {
      http.Response response;
      if (method == 'POST') {
        response = await http.post(Uri.parse(url), headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'});
      } else {
        response = await http.delete(Uri.parse(url), headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'});
      }
      
      final data = json.decode(response.body);
      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? "",
        'is_following': data['is_following'] ?? false,
      };
    } catch (e) {
      return {'success': false, 'message': "خطأ في الاتصال بالسيرفر"};
    }
  }

  // --- دالة مشتركة وقوية لجلب القوائم (GET) ---
  Future<List<Map<String, dynamic>>> _fetchData(String token, String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final dynamic decodedResponse = json.decode(response.body);
        List<dynamic> rawData = [];

        // استخراج البيانات بمرونة حسب شكل الـ JSON
        if (decodedResponse is Map) {
          var data = decodedResponse['data'];
          if (data is Map) {
            // البحث عن المفاتيح الشائعة في الـ Response
            rawData = data['followers'] ?? data['following'] ?? data['users'] ?? [];
          } else if (data is List) {
            rawData = data;
          }
        } else if (decodedResponse is List) {
          rawData = decodedResponse;
        }

        // تحويل البيانات وتنظيف الصور
        return rawData.map((item) {
          Map<String, dynamic> userMap = Map<String, dynamic>.from(item);
          userMap['profile_img'] = _fixImageUrl(userMap['profile_img']?.toString());
          return userMap;
        }).toList();
      }
      return [];
    } catch (e) {
      print("❌ Error fetching list: $e");
      return [];
    }
  }
}