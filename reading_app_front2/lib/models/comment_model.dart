import 'package:intl/intl.dart';

class CommentModel {
  final int id;
  final int bookId;
  final int userId;
  final String content;
  final int? parentId;
  final String createdAt;
  final String userName;
  final String? userImg;
  final List<CommentModel> replies; 

  CommentModel({
    required this.id,
    required this.bookId,
    required this.userId,
    required this.content,
    this.parentId,
    required this.createdAt,
    required this.userName,
    this.userImg,
    required this.replies,
  });

  /// ✨ دالة نسخ الكائن وتعديل النصوص دون تصفير باقي البيانات
  CommentModel copyWith({
    String? content,
    String? createdAt,
    List<CommentModel>? replies,
  }) {
    return CommentModel(
      id: this.id,                     // بيبقى ثابت
      bookId: this.bookId,             // بيبقى ثابت
      userId: this.userId,             // بيبقى ثابت
      parentId: this.parentId,         // بيبقى ثابت
      userName: this.userName,         // بيبقى ثابت (بيمنع اختفاء الاسم)
      userImg: this.userImg,           // بيبقى ثابت (بيمنع اختفاء الصورة)
      content: content ?? this.content, // بيتحدث إذا بعثنا نص جديد
      createdAt: createdAt ?? this.createdAt, // بيتحدث إذا بعثنا وقت جديد
      replies: replies ?? this.replies, // بتبقى القائمة القديمة أو تتحدث بالجديدة
    );
  }

  /// 🛠️ دالة مساعدة لتنظيف وتنسيق التاريخ القادم من السيرفر
  static String _cleanDate(String rawDate) {
    if (rawDate.isEmpty) return '';
    try {
      // تحويل النص الصيغة الخام (ISO 8601) إلى كائن DateTime مع مراعاة التوقيت المحلي لجهاز المستخدم
      DateTime parsedDate = DateTime.parse(rawDate).toLocal();
      // تنسيق التاريخ ليصبح (سنة-شهر-يوم ساعة:دقيقة) بدون أجزاء الثانية وبدون حرف الـ Z
      return DateFormat('yyyy-MM-dd HH:mm').format(parsedDate);
    } catch (e) {
      // في حال وجود صيغة غير متوقعة، يتم تنظيفها يدوياً كخطة بديلة لحذف الأصفار والـ Z
      if (rawDate.contains('T')) {
        String withoutMillis = rawDate.split('.').first;
        return withoutMillis.replaceAll('T', ' ');
      }
      return rawDate;
    }
  }

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final userData = json['user'] ?? {};
    
    var repliesList = json['replies'] as List? ?? [];
    List<CommentModel> parsedReplies = repliesList
        .map((replyJson) => CommentModel.fromJson(replyJson))
        .toList();

    String? rawImg = userData['profile_img'];
    String? fullImgUrl;

    if (rawImg != null && rawImg.isNotEmpty) {
      final String serverIp = "http://192.168.34.216:8000"; 
      
      String cleanPath = rawImg.startsWith('/') ? rawImg.substring(1) : rawImg;
      
      // 🔄 إلحاق كلمة storage ليتطابق الرابط مع مجلد الـ public/storage الفعلي
      if (!cleanPath.startsWith('storage/')) {
        cleanPath = 'storage/$cleanPath';
      }
      
      fullImgUrl = "$serverIp/$cleanPath";
    }

    return CommentModel(
      id: json['id'],
      bookId: json['book_id'],
      userId: json['user_id'],
      content: json['content'] ?? '',
      parentId: json['parent_id'],
      // ✨ تمرير التاريخ الخام إلى دالة التنظيف قبل حفظه في الكائن
      createdAt: _cleanDate(json['created_at'] ?? ''),
      userName: userData['name'] ?? 'قارئة دُفّة',
      userImg: fullImgUrl, 
      replies: parsedReplies,
    );
  }
}