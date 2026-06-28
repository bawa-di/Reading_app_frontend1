import 'package:flutter/material.dart'; // استدعاء الويدجت لاستخدام debugPrint
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationService {
  final String baseUrl = "http://192.168.34.216:8000/api";

  /// طلب جلب قائمة الإشعارات الخام من السيرفر
  Future<List<dynamic>?> fetchRawNotifications(String token) async {
    final url = Uri.parse('$baseUrl/notifications'); 
    
    // 🪵 طباعة 1: التأكد من بدء استدعاء الدالة وإرسال التوكن
    debugPrint('🚀 [NotificationService]: جاري إرسال طلب جلب الإشعارات...');
    debugPrint('🔗 [الرابط المستهدف]: $url');
    debugPrint('🔑 [التوكن]: Bearer $token');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      // 🪵 طباعة 2: رصد كود الحالة (HTTP Status Code) الراجع من السيرفر
      debugPrint('📡 [رد السيرفر]: كود الحالة الراجع هو = ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        // 🪵 طباعة 3: طباعة النص الجيسون الكامل والراجع بدقة لتفقده
        debugPrint('================= 🔔 فحص جيسون الإشعارات الخام 🔔 =================');
        debugPrint('🔥 [DEBUG] الرد الكامل للاإشعارات: $responseData');
        debugPrint('========================================================================');
        
        // 🪵 طباعة 4: فحص نوع البيانات الأساسية بعد فك التشفير
        debugPrint('🧠 [تحليل الهيكلية]: نوع الـ JSON الراجع هو: ${responseData.runtimeType}');

        // الحالة التي يتبعها كود مَتحكم لارافل الخاص بكِ (تغليف بـ success و data)
        if (responseData is Map && responseData['success'] == true) {
          final List dataList = responseData['data'] is List ? responseData['data'] : [];
          debugPrint('✅ [نجاح التحقق]: تم العثور على حقل "data" كقائمة، وعدد العناصر المرجعة = ${dataList.length}');
          return dataList;
        }
        
        // الحالة الافتراضية للارافل إن تم إرجاع المصفوفة مباشرة
        if (responseData is List) {
          debugPrint('✅ [نجاح التحقق]: السيرفر أرجع مصفوفة إشعارات مباشرة، وعدد العناصر = ${responseData.length}');
          return responseData;
        } 
        
        debugPrint("⚠️ [تنبيه] NotificationService: هيكلية الـ JSON الراجعة غير متوقعة أو حقل success ليس true.");
      } else {
        // 🪵 طباعة 5: رصد المشاكل في حال كانت الحالة ليست 200 (مثل 401 أو 404)
        debugPrint("❌ NotificationService [Fetch] Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      // 🪵 طباعة 6: التقاط الكراشات الناتجة عن تعذر الاتصال بالشبكة أو خطأ بالـ IP
      debugPrint("❌ NotificationService [Fetch] Exception: حدث خطأ غير متوقع أثناء الاتصال: $e");
    }
    return null;
  }

  /// طلب تحديد إشعار معين كمقروء على السيرفر (تمرير الـ ID ديناميكياً)
  Future<bool> markAsReadOnServer(String token, String notificationId) async {
    // تم الإبقاء على الرابط الذي عدلتِه مؤخراً لتحديد المقروء
    final url = Uri.parse('$baseUrl/all_read'); 
    
    // 🪵 طباعة 1: تتبع بدء عملية التحديث كمقروء
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

      // 🪵 طباعة 2: رصد كود حالة التحديث كمقروء
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