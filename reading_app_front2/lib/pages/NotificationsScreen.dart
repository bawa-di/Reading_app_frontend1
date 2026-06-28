import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:reading_app_front2/conset_app.dart'; 
import 'package:reading_app_front2/provider/NotificationProvider.dart';
import 'package:reading_app_front2/provider/user_provider.dart'; // استيراد البروفايدر للوصول للتوكن
import '../models/notification_model.dart';

class NotificationsScreen extends StatelessWidget {
  static String id = 'NotificationsScreen';

  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // جلب التوكن مباشرة من UserProvider (الذي قمنا بتهيئته في main.dart)
    final userToken = Provider.of<UserProvider>(context, listen: false).token;

    // جلب البيانات عند بناء الواجهة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (userToken != null) {
        Provider.of<NotificationProvider>(context, listen: false).loadNotifications(userToken);
      }
    });

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.creamBackground,
        appBar: _buildAppBar(context, userToken),
        body: Consumer<NotificationProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator(color: AppColors.burgundy));
            }

            if (provider.notifications.isEmpty) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              color: AppColors.burgundy,
              onRefresh: () => provider.loadNotifications(userToken ?? ''),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemCount: provider.notifications.length,
                itemBuilder: (context, index) {
                  final item = provider.notifications[index];
                  return _buildNotificationItem(context, item, provider, userToken ?? '');
                },
              ),
            );
          },
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, String? token) {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.burgundy,
      toolbarHeight: 70.0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text("الإشعارات", style: GoogleFonts.katibeh(fontSize: 28, color: Colors.white)),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.done_all_rounded, color: Colors.white70),
          onPressed: () {
            final provider = Provider.of<NotificationProvider>(context, listen: false);
            for (var notification in provider.notifications) {
              if (!notification.isRead && token != null) {
                provider.markAsRead(token, notification.id);
              }
            }
          },
        )
      ],
    );
  }

  Widget _buildNotificationItem(BuildContext context, NotificationModel item, NotificationProvider provider, String token) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) => {}, // أضيفي منطق الحذف من الباك إند هنا إذا أردتِ
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: Colors.red.shade400, borderRadius: BorderRadius.circular(16)),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_sweep_rounded, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: item.isRead ? Colors.white.withOpacity(0.6) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 3))],
        ),
        child: ListTile(
          leading: _buildNotificationIcon(item.type),
          title: Text(item.title, style: GoogleFonts.tajawal(fontWeight: item.isRead ? FontWeight.normal : FontWeight.bold, fontSize: 14)),
          subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 6),
            Text(item.body, style: GoogleFonts.tajawal(fontSize: 12, color: Colors.grey[600])),
            Text(item.createdAt, style: GoogleFonts.tajawal(fontSize: 10, color: Colors.grey[400])),
          ]),
          onTap: () {
            if (!item.isRead) provider.markAsRead(token, item.id);
          },
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(String type) {
    // منطق الأيقونات الخاص بكِ (كما هو)
    IconData iconData = type.contains('ReaderTitleChangedNotification') ? Icons.emoji_events_rounded : Icons.notifications_rounded;
    return Container(width: 44, height: 44, decoration: BoxDecoration(color: Colors.amber.shade50, shape: BoxShape.circle), child: Icon(iconData, color: Colors.amber.shade800, size: 22));
  }

  Widget _buildEmptyState() {
    return Center(child: Text("صندوق الإشعارات فارغ حالياً", style: GoogleFonts.tajawal(color: Colors.grey)));
  }
}