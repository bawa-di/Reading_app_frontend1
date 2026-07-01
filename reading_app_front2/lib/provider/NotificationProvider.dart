import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// 📥 جلب الإشعارات
  Future<void> loadNotifications(String token) async {
    _isLoading = true;
    notifyListeners();

    debugPrint('🕒 [${DateTime.now()}] بدء تحميل الإشعارات...');
    final rawData = await _notificationService.fetchRawNotifications(token);

    if (rawData != null) {
      _notifications = rawData.map((json) => NotificationModel.fromJson(json)).toList();
      debugPrint('✅ تم تحميل ${_notifications.length} إشعاراً بنجاح.');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// 🔄 تحديث الإشعار كمقروء (التعديل المطلوب لضمان إرسال ما يتوقعه السيرفر)
  Future<void> markAsRead(String token, String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index == -1) return;

    final originalNotification = _notifications[index];

    // 1. التحديث الفوري للواجهة
    _notifications[index] = NotificationModel(
      id: originalNotification.id,
      type: originalNotification.type,
      title: originalNotification.title,
      body: originalNotification.body,
      createdAt: originalNotification.createdAt,
      bookId: originalNotification.bookId,
      readAt: DateTime.now().toIso8601String(),
    );
    notifyListeners();

    // 2. إرسال الطلب للسيرفر
    // ملاحظة هامة: إذا كان السيرفر يصر على int، تأكدي أن notificationId هنا رقمي.
    // إذا كان الـ id الخاص بك نصاً، فهذا هو سبب الـ 500.
    debugPrint('📤 [${DateTime.now()}] محاولة إرسال تحديث للإشعار: $notificationId');
    
    bool isSuccess = await _notificationService.markAsReadOnServer(token, notificationId);

    // 3. التراجع في حال الفشل
    if (!isSuccess) {
      debugPrint('❌ فشل تحديث السيرفر للإشعار: $notificationId - التراجع عن التغيير المحلي.');
      _notifications[index] = originalNotification;
      notifyListeners();
    } else {
      debugPrint('✅ تم تحديث الإشعار $notificationId بنجاح على السيرفر.');
    }
  }
}