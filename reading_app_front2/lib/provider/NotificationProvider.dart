import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  // إنشاء نسخة من الخدمة لاستخدامها داخلياً
  final NotificationService _notificationService = NotificationService();

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;

  // حساب الإشعارات غير المقروءة للـ Badge
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// 📥 دالة جلب الإشعارات وتحديث الحالة للـ UI
  Future<void> loadNotifications(String token) async {
    _isLoading = true;
    notifyListeners();

    // استدعاء السيرفس لجلب البيانات الخام
    final rawData = await _notificationService.fetchRawNotifications(token);

    if (rawData != null) {
      // تحويل البيانات الخام إلى كائنات NotificationModel هنا في طبقة الـ Provider
      _notifications = rawData.map((json) => NotificationModel.fromJson(json)).toList();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// 🔄 دالة تحديث الإشعار كمقروء (مع التحديث الفوري المتفائل UI Optimistic Update)
  Future<void> markAsRead(String token, String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index == -1) return;

    final originalNotification = _notifications[index];

    // 1. تحديث محلي سريع جداً لراحة عين المستخدم بالـ UI
    _notifications[index] = NotificationModel(
      id: originalNotification.id,
      type: originalNotification.type,
      title: originalNotification.title,
      body: originalNotification.body,
      createdAt: originalNotification.createdAt,
      bookId: originalNotification.bookId,
      readAt: DateTime.now().toIso8601String(), // نعتبره مقروءاً فوراً
    );
    notifyListeners();

    // 2. إرسال الطلب للسيرفر عبر السيرفس في الخلفية
    bool isSuccess = await _notificationService.markAsReadOnServer(token, notificationId);

    // 3. إذا فشل الطلب على السيرفر، نراجع التعديل المحلي لحالته الأصلية حماية للبيانات
    if (!isSuccess) {
      _notifications[index] = originalNotification;
      notifyListeners();
    }
  }
}