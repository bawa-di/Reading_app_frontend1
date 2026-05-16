
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reading_app_front2/conset_app.dart'; // ملف الألوان الخاص بكِ

class MySuggestionsScreen extends StatefulWidget {
  static String id = 'MySuggestionsScreen';
  const MySuggestionsScreen({super.key});

  @override
  State<MySuggestionsScreen> createState() => _MySuggestionsScreenState();
}

class _MySuggestionsScreenState extends State<MySuggestionsScreen> {
  // بيانات تجريبية (Mock Data) لمحاكاة استجابة الباك-إند والشكل الجمالي
  final List<Map<String, String>> dummySuggestions = [
    {
      "title": "أرض زيكولا - الجزء الثالث",
      "author": "عمرو عبد الحميد",
      "status": "pending", // قيد الانتظار
      "date": "2026/05/16",
    },
    {
      "title": "قواعد العشق الأربعون",
      "author": "إليف شفق",
      "status": "approved", // تم القبول
      "date": "2026/04/15",
    },
    {
      "title": "كتاب تاريخي مجهول",
      "author": "مؤلف غير معروف",
      "status": "rejected", // مرفوض
      "date": "2026/03/20",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.creamBackground,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.burgundy,

          title: Text(
            "اقتراحاتي",
            style: GoogleFonts.katibeh(fontSize: 30, color: Colors.white),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            // هيدر تعريفي علوي أنيق ومبسط للحفاظ على انسيابية الشاشات
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
              decoration: const BoxDecoration(
                color: AppColors.burgundy,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: const Text(
                "تابع حالة الكتب التي قمت باقتراحها لإضافتها إلى مكتبة دُفّة",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),

            const SizedBox(height: 10),

            // قائمة عرض بطاقات الاقتراحات
            Expanded(
              child: dummySuggestions.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      itemCount: dummySuggestions.length,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      itemBuilder: (context, index) {
                        final item = dummySuggestions[index];
                        return _buildSuggestionCard(item);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // تصميم بطاقة الاقتراح الواحدة
  Widget _buildSuggestionCard(Map<String, String> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.creamBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.auto_stories, color: AppColors.burgundy),
        ),
        title: Text(
          item['title']!,
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Text(
              "المؤلف: ${item['author']!}",
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 5),
            Text(
              item['date']!,
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
        trailing: _buildStatusTag(
          item['status']!,
        ), // التاغ الملون المعتمد على قرار الإدارة
      ),
    );
  }

  // التاغات الملونة الذكية التي تمثل سيناريو الإشعارات وحالة الطلب
  Widget _buildStatusTag(String status) {
    Color bgColor;
    Color textColor;
    String statusText;

    switch (status) {
      case 'approved':
        bgColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        statusText = "تم القبول";
        break;
      case 'rejected':
        bgColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red;
        statusText = "مرفوض";
        break;
      case 'pending':
      default:
        bgColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        statusText = "قيد الانتظار";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statusText,
        style: GoogleFonts.tajawal(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_queue_rounded,
            size: 70,
            color: Colors.grey.withOpacity(0.4),
          ),
          const SizedBox(height: 15),
          Text(
            "لا توجد اقتراحات سابقة لديك",
            style: GoogleFonts.tajawal(color: Colors.grey, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
