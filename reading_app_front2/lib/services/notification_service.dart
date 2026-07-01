import 'package:flutter/material.dart'; 
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationService {
  final String baseUrl = "http://192.168.34.216:8000/api";

  /// طلب جلب قائمة الإشعارات الخام من السيرفر
  Future<List<dynamic>?> fetchRawNotifications(String token) async {
    final url = Uri.parse('$baseUrl/notifications'); 


    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      debugPrint('📡 [رد السيرفر]: كود الحالة الراجع هو = ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        debugPrint('================= 🔔 فحص جيسون الإشعارات الخام 🔔 =================');
        debugPrint('🔥 [DEBUG] الرد الكامل للاإشعارات: $responseData');
        debugPrint('========================================================================');
        
        if (responseData is Map && responseData['success'] == true) {
          final List dataList = responseData['data'] is List ? responseData['data'] : [];
          debugPrint('✅ [نجاح التحقق]: تم العثور على حقل "data" كقائمة، وعدد العناصر المرجعة = ${dataList.length}');
          return dataList;
        }
        
        if (responseData is List) {
          debugPrint('✅ [نجاح التحقق]: السيرفر أرجع مصفوفة إشعارات مباشرة، وعدد العناصر = ${responseData.length}');
          return responseData;
        } 
        
        debugPrint("⚠️ [تنبيه] NotificationService: هيكلية الـ JSON الراجعة غير متوقعة أو حقل success ليس true.");
      } else {
        debugPrint("❌ NotificationService [Fetch] Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      debugPrint("❌ NotificationService [Fetch] Exception: حدث خطأ غير متوقع أثناء الاتصال: $e");
    }
    return null;
  }

  /// طلب تحديد إشعار معين كمقروء على السيرفر (مع تعديل تمرير الـ ID ديناميكياً)
  Future<bool> markAsReadOnServer(String token, String notificationId) async {
    // تم تعديل الرابط ليحتوي على {id} ليتطابق مع الـ Route المعرف في Laravel
    final url = Uri.parse('$baseUrl/all_read/$notificationId'); 
    
    debugPrint('📤 [NotificationService]: جاري إرسال طلب تحديد الإشعار كمقروء...');
    debugPrint('🔗 [الرابط المستهدف]: $url');
    debugPrint('🆔 [معرف الإشعار المراد تحديثه]: $notificationId');
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      debugPrint('📡 [رد السيرفر لتحديث القراءة]: كود الحالة هو = ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        debugPrint('================= 🔄 فحص رد طلب التحديث كمقروء 🔄 =================');
        debugPrint('🔥 [DEBUG] رد السيرفر: $responseData');
        debugPrint('========================================================================');

        if (responseData is Map) {
          bool successStatus = responseData['success'] == true;
          debugPrint('🧠 [تحليل الرد]: حالة النجاح المرجعة من الباكيند هي = $successStatus');
          return successStatus;
        }
        return true; 
      } else {
        debugPrint("❌ NotificationService [MarkRead] Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      debugPrint("❌ NotificationService [MarkRead] Exception: حدث خطأ أثناء التحديث كمقروء: $e");
    }
    return false;
  }
}