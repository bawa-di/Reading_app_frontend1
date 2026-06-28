import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:reading_app_front2/conset_app.dart'; // ملف الألوان الخاص بكِ
import 'package:reading_app_front2/provider/SuggestionProvider.dart';
import 'package:reading_app_front2/provider/user_provider.dart'; // لجلب التوكن الخاص بالمستخدم الحالي

class MySuggestionsScreen extends StatefulWidget {
  static String id = 'MySuggestionsScreen';
  const MySuggestionsScreen({super.key});

  @override
  State<MySuggestionsScreen> createState() => _MySuggestionsScreenState();
}

class _MySuggestionsScreenState extends State<MySuggestionsScreen> {
  
  @override
  void initState() {
    super.initState();
    // 🚀 جلب الاقتراحات الحية من السيرفر فور تحميل الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.token;

      if (token != null && token.isNotEmpty) {
        Provider.of<SuggestionProvider>(context, listen: false)
            .getUserSuggestions(token: token);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final suggestionProvider = context.watch<SuggestionProvider>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.creamBackground,
        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: AppColors.burgundy,
          toolbarHeight: 65.0,
          title: Text(
            "اقتراحاتي",
            style: GoogleFonts.katibeh(fontSize: 30, color: Colors.white),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            // الهيدر التعريفي العلوي مدمج بشكل انسيابي وبحواف دائرية ناعمة
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 20, top: 5),
              decoration: const BoxDecoration(
                color: AppColors.burgundy,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Text(
                "تابع حالة الكتب التي قمت باقتراحها لإضافتها إلى مكتبة دُفّة",
                textAlign: TextAlign.center,
                style: GoogleFonts.tajawal(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 13,
                  height: 1.4
                ),
              ),
            ),

            const SizedBox(height: 12),

            // قائمة عرض بطاقات الاقتراحات الحية
            Expanded(
              child: suggestionProvider.isFetching
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.burgundy,
                      ),
                    )
                  : suggestionProvider.userSuggestions.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          itemCount: suggestionProvider.userSuggestions.length,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemBuilder: (context, index) {
                            final item = suggestionProvider.userSuggestions[index];
                            return _buildSuggestionCard(item);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // ✨ تصميم مخصص لبطاقة الاقتراحات أكثر فخامة وعمقاً بصرياً
  Widget _buildSuggestionCard(dynamic item) {
    String fullDate = item['created_at'] ?? '';
    String formattedDate = fullDate.length >= 10 ? fullDate.substring(0, 10).replaceAll('-', '/') : fullDate;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // أيقونة الكتاب الجانبية المنسقة
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.creamBackground.withOpacity(0.7),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.burgundy.withOpacity(0.08), width: 1)
            ),
            child: const Icon(Icons.auto_stories_rounded, color: AppColors.burgundy, size: 24),
          ),
          
          const SizedBox(width: 14),
          
          // تفاصيل الكتاب (العنوان، المؤلف والتاريخ)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'] ?? 'بدون عنوان',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.tajawal(
                    fontWeight: FontWeight.bold, 
                    fontSize: 15,
                    color: Colors.black87
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.person_outline_rounded, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        "المؤلف: ${item['author'] ?? 'غير معروف'}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.tajawal(color: Colors.grey[600], fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 12, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text(
                      formattedDate,
                      style: GoogleFonts.tajawal(color: Colors.grey[400], fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 8),
          
          // التاغات الملونة الذكية المحدّثة مع أيقونة دلالية في الزاوية
          _buildStatusTag(item['status'] ?? 'pending'), 
        ],
      ),
    );
  }

  // ✨ تاغات ملونة ومحسنة مع أيقونة رقيقة تعكس حالة الطلب
  Widget _buildStatusTag(String status) {
    Color bgColor;
    Color textColor;
    String statusText;
    IconData iconData;

    switch (status) {
      case 'approved':
      case 'accepted':
        bgColor = const Color(0xFFE8F5E9); // أخضر هادئ ومريح
        textColor = const Color(0xFF2E7D32);
        statusText = "تم القبول";
        iconData = Icons.check_circle_rounded;
        break;
      case 'rejected':
      case 'declined':
        bgColor = const Color(0xFFFFEBEE); // أحمر ناعم
        textColor = const Color(0xFFC62828);
        statusText = "مرفوض";
        iconData = Icons.cancel_rounded;
        break;
      case 'pending':
      default:
        bgColor = const Color(0xFFFFF3E0); // أورنج دافئ للانتظار
        textColor = const Color(0xFFE65100);
        statusText = "قيد النظَر";
        iconData = Icons.timelapse_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, color: textColor, size: 13),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: GoogleFonts.tajawal(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  // واجهة الحالة الفارغة منسقة بما يتناسب مع ألوان دُفّة
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.burgundy.withOpacity(0.05),
              shape: BoxShape.circle
            ),
            child: Icon(
              Icons.cloud_queue_rounded,
              size: 60,
              color: AppColors.burgundy.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "لا توجد اقتراحات سابقة لديكِ",
            style: GoogleFonts.tajawal(
              color: Colors.grey[500], 
              fontSize: 15,
              fontWeight: FontWeight.w500
            ),
          ),
        ],
      ),
    );
  }
}