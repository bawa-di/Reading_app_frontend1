class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String body;
  final String? readAt;
  final String createdAt;
  final int? bookId; 

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.readAt,
    required this.createdAt,
    this.bookId,
  });

  // فحص إذا كان الإشعار مقروءاً أم لا
  bool get isRead => readAt != null;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    // تأمين قراءة حقل data كـ Map لتجنب أخطاء النوع في Dart
    final notificationData = json['data'] is Map ? json['data'] as Map<String, dynamic> : {};

    // 🟢 1. قراءة مرنة للـ body: يبحث عن message الخاصة بلارافل أولاً، وإن لم يجدها يقرأ body
    final String extractedBody = notificationData['message'] ?? notificationData['body'] ?? 'تم تحديث بيانات حسابك.';

    // 🟢 2. بناء عنوان ذكي بناءً على اسم كلاس الإشعار القادم من الباكيند (type) لمنع ظهور العناوين الفارغة
    String extractedTitle = notificationData['title'] ?? 'إشعار جديد';
    final String notificationType = json['type'] ?? '';

    if (notificationType.contains('ReaderTitleChangedNotification')) {
      extractedTitle = '🏆 لقب جديد!';
    } else if (notificationType.contains('BookSuggestionNotification')) {
      extractedTitle = '📚 اقتراح كتاب جديد';
    }

    return NotificationModel(
      // تحويل الـ id إلى String بشكل آمن لأن لارافل يرسله كـ UUID نصي
      id: json['id']?.toString() ?? '', 
      type: notificationType,
      title: extractedTitle, 
      body: extractedBody,   
      readAt: json['read_at'],
      createdAt: json['created_at'] ?? '', 
      bookId: notificationData['book_id'] != null 
          ? int.tryParse(notificationData['book_id'].toString()) 
          : null,
    );
  }
}