import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reading_app_front2/conset_app.dart'; // ملف الألوان الخاص بكِ

class NotificationsScreen extends StatefulWidget {
  static String id = 'NotificationsScreen';
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // بيانات تجريبية للإشعارات (يمكن ربطها بالباك اند لاحقاً)
  final List<Map<String, dynamic>> _notifications = [
    {
      "id": "1",
      "type": "challenge", // تحدي قراءة أو تذكير يومي
      "title": "وقت القراءة اليومي! 📚",
      "body": "لا تنسَ قراءة وردك اليومي من رواية 'أنت لي'. لقد قطعت 65% حتى الآن، استمر!",
      "time": "قبل 10 دقائق",
      "isRead": false,
    },
    {
      "id": "2",
      "type": "suggestion", // اقتراح كتاب
      "title": "اقتراح كتاب جديد لك ✨",
      "body": "بناءً على قراءاتك السابقة، قد تعجبك رواية 'أرض زيكولا'. ألقِ نظرة عليها الآن.",
      "time": "قبل ساعتين",
      "isRead": false,
    },
    {
      "id": "3",
      "type": "community", // مجتمعي / لوحة الصدارة
      "title": "تحديث لوحة الصدارة 🏆",
      "body": "تهانينا! لقد صعدت للمركز الثالث في قائمة متصدري القراءة لهذا الأسبوع.",
      "time": "بالأمس",
      "isRead": true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.creamBackground,
        
        // الأب بار الدائري الأنيق المتناسق مع تطبيقك
        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: AppColors.burgundy,
          toolbarHeight: 70.0,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          // زر الرجوع للخلف
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "الإشعارات",
            style: GoogleFonts.katibeh(fontSize: 28, color: Colors.white),
          ),
          centerTitle: true,
          actions: [
            // زر لتحديد الكل كمقروء
            IconButton(
              icon: const Icon(Icons.done_all_rounded, color: Colors.white70),
              onPressed: () {
                setState(() {
                  for (var notification in _notifications) {
                    notification['isRead'] = true;
                  }
                });
              },
            )
          ],
        ),
        
        body: _notifications.isEmpty 
            ? _buildEmptyState() 
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final item = _notifications[index];
                  return _buildNotificationItem(item, index);
                },
              ),
      ),
    );
  }

  // ويدجت بناء عنصر الإشعار مع ميزة السحب للحذف (Dismissible)
  Widget _buildNotificationItem(Map<String, dynamic> item, int index) {
    return Dismissible(
      key: Key(item['id']),
      direction: DismissDirection.startToEnd, // السحب من اليمين لليسار للحذف
      onDismissed: (direction) {
        setState(() {
          _notifications.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حذف الإشعار'), duration: Duration(seconds: 2)),
        );
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 28),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          // إذا كان غير مقروء، نضع خلفية بيضاء ناصعة، وإذا مقروء نضع لون مائل للخلفية قليلاً
          color: item['isRead'] ? Colors.white.withOpacity(0.6) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          leading: _buildNotificationIcon(item['type']),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item['title'],
                  style: GoogleFonts.tajawal(
                    fontWeight: item['isRead'] ? FontWeight.normal : FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
              // نقطة صغيرة زرقاء تعبر عن أن الإشعار غير مقروء بعد
              if (!item['isRead'])
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.pinkAccent,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              Text(
                item['body'],
                style: GoogleFonts.tajawal(
                  fontSize: 12,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item['time'],
                style: GoogleFonts.tajawal(fontSize: 10, color: Colors.grey[400]),
              ),
            ],
          ),
          onTap: () {
            // عند الضغط على الإشعار، نجعله مقروءاً
            setState(() {
              item['isRead'] = true;
            });
          },
        ),
      ),
    );
  }

  // تخصيص الأيقونة واللون حسب نوع الإشعار القادم
  Widget _buildNotificationIcon(String type) {
    IconData iconData;
    Color iconColor;
    Color bgColor;

    switch (type) {
      case 'challenge':
        iconData = Icons.auto_stories_rounded;
        iconColor = AppColors.burgundy;
        bgColor = AppColors.burgundy.withOpacity(0.1);
        break;
      case 'suggestion':
        iconData = Icons.lightbulb_rounded;
        iconColor = Colors.orange.shade700;
        bgColor = Colors.orange.shade50;
        break;
      case 'community':
        iconData = Icons.emoji_events_rounded;
        iconColor = Colors.amber.shade800;
        bgColor = Colors.amber.shade50;
        break;
      default:
        iconData = Icons.notifications_rounded;
        iconColor = Colors.grey;
        bgColor = Colors.grey.shade100;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: iconColor, size: 22),
    );
  }

  // حالة عدم وجود إشعارات
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 70, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 12),
          Text(
            "صندوق الإشعارات فارغ حالياً",
            style: GoogleFonts.tajawal(color: Colors.grey, fontSize: 15),
          ),
        ],
      ),
    );
  }
}