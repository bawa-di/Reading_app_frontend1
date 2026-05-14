import 'dart:convert';
import 'package:http/http.dart' as http;

class LeaderboardService {
  // ملاحظة: تأكدي دائماً أن IP الجهاز الحقيقي مطبق هنا ليعمل المحاكي
  static const String baseUrl = "http://192.168.34.252:8000/api";

  // --- 1. جلب قائمة جميع المستخدمين (usersProgress) ---
  Future<List<Map<String, dynamic>>> getUsersProgress(String token) async {
    return _fetchData(token, '$baseUrl/users_pogress_list');
  }

  // --- 2. جلب قائمة المتابعين (getFollowers) ---
  Future<List<Map<String, dynamic>>> getFollowers(String token) async {
    return _fetchData(token, '$baseUrl/followers');
  }

  // --- 3. جلب قائمة الذين أتابعهم (getFollowing) ---
  Future<List<Map<String, dynamic>>> getFollowing(String token) async {
    return _fetchData(token, '$baseUrl/following');
  }

  // --- 4. جلب تفاصيل مستخدم محدد (Stats & Info) ---
  // هذه الدالة الجديدة التي طلبتِها لتبويب "أتابعهم" أو عند الضغط على البروفايل
 // --- جلب تفاصيل مستخدم محدد (Stats & Info) ---
  // Route::get('/followed_users/{followedUserId}', ...)
  Future<Map<String, dynamic>?> getFollowedUserDetails(String token, int followedUserId) async {
    try {
      // بناء الرابط ليكون /api/followed_users/5 مثلاً
      final String url = '$baseUrl/followed_users/$followedUserId';
      
      print("--- [جاري طلب تفاصيل المستخدم من: $url] ---");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // معالجة رابط الصورة ليعمل على المحاكي إذا كانت الصورة موجودة
        if (data['success'] == true && data['data']['profile_img'] != null) {
          String img = data['data']['profile_img'];
          data['data']['profile_img'] = img
              .replaceAll('localhost', '192.168.34.252')
              .replaceAll('127.0.0.1', '192.168.34.252');
        }
        return data;
      } else {
        print("⚠️ خطأ من السيرفر: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ خطأ في الاتصال أثناء جلب بيانات المستخدم: $e");
      return null;
    }
  }

  // --- 5. دالة متابعة مستخدم (Follow) باستخدام POST ---
  Future<Map<String, dynamic>> followUser(String token, int userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/follow/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      return _handleResponse(response);
    } catch (e) {
      print("❌ Error in Follow Action: $e");
      return {'success': false, 'message': "فشل الاتصال بالشبكة"};
    }
  }

  // --- 6. دالة إلغاء متابعة مستخدم (Unfollow) باستخدام DELETE ---
  Future<Map<String, dynamic>> unfollowUser(String token, int userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/unfollow/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      return _handleResponse(response);
    } catch (e) {
      print("❌ Error in Unfollow Action: $e");
      return {'success': false, 'message': "فشل الاتصال بالشبكة"};
    }
  }

  // دالة موحدة لمعالجة الـ Response القادم من POST أو DELETE
  Map<String, dynamic> _handleResponse(http.Response response) {
    final data = json.decode(response.body);
    if (response.statusCode == 200 || response.statusCode == 400) {
      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? "",
        'is_following': data['is_following'] ?? false,
      };
    }
    return {'success': false, 'message': "خطأ في السيرفر: ${response.statusCode}"};
  }

  // --- دالة داخلية مشتركة لجلب البيانات (GET) ---
  Future<List<Map<String, dynamic>>> _fetchData(String token, String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', 
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final dynamic decodedResponse = json.decode(response.body);
        List<dynamic> rawData = [];

        if (decodedResponse is Map && decodedResponse.containsKey('data')) {
          var dataContent = decodedResponse['data'];
          if (dataContent is Map) {
            if (dataContent.containsKey('followers')) rawData = dataContent['followers'];
            else if (dataContent.containsKey('following')) rawData = dataContent['following'];
          } else if (dataContent is List) {
            rawData = dataContent;
          }
        } else if (decodedResponse is List) {
          rawData = decodedResponse;
        }

        return rawData.map((item) {
          Map<String, dynamic> userMap = Map<String, dynamic>.from(item);
          if (userMap['profile_img'] != null) {
            String img = userMap['profile_img'];
            userMap['profile_img'] = img
                .replaceAll('localhost', '192.168.34.252')
                .replaceAll('127.0.0.1', '192.168.34.252');
          }
          return userMap;
        }).toList();
      } 
      return [];
    } catch (e) {
      print("❌ Unexpected Error in LeaderboardService: $e");
      return [];
    }
  }
}