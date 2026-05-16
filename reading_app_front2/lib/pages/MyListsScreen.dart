import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reading_app_front2/conset_app.dart'; // ملف الألوان الخاص بكِ

class MyListsScreen extends StatefulWidget {
  static String id = 'MyListsScreen';
  const MyListsScreen({super.key});

  @override
  State<MyListsScreen> createState() => _MyListsScreenState();
}

class _MyListsScreenState extends State<MyListsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 1. بيانات تجريبية لقسم "أقرأه الآن"
  final List<Map<String, String>> readingNowBooks = [
    {"title": "قواعد العشق الأربعون", "author": "إليف شفق", "progress": "65%"},
  ];

  // 2. بيانات تجريبية لقسم "أرغب بقراءته"
  final List<Map<String, String>> wantToReadBooks = [
    {
      "title": "أرض زيكولا",
      "author": "عمرو عبد الحميد",
      "date": "أُضيف بالأمس",
    },
    {
      "title": "الرقص مع الحياة",
      "author": "مهدي الموسوي",
      "date": "أُضيف قبل أسبوع",
    },
  ];

  // 3. بيانات تجريبية لقسم "أنهيتها"
  final List<Map<String, String>> completedBooks = [
    {
      "title": "مقدمة ابن خلدون",
      "author": "ابن خلدون",
      "finishDate": "تم الإنجاز في 2026/04",
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.creamBackground,
        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0, // يمنع ظهور خط رمادي عند سحب القائمة
          backgroundColor: AppColors.burgundy,
          toolbarHeight: 70, // تحديد حجم الـ AppBar وإعطائه مساحة مريحة
          // إجبار الـ AppBar والمحتوى الذي بداخله على الانقصاص بشكل دائري نظيف
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "قوائمي",
            style: GoogleFonts.katibeh(fontSize: 30, color: Colors.white),
          ),
          centerTitle: true,

          bottom: TabBar(
            controller: _tabController,

            // 🟢 التعديل الأهم: يجعل الخط الأفقي الممتد شفافاً تماماً ويلغيه من زوايا الشاشة
            dividerColor: Colors.transparent,

            // جعل مؤشر التحديد يمتد على طول نص الكلمة فقط ولا يضرب في الحواف الدائرية
            indicatorSize: TabBarIndicatorSize.label,
            indicatorColor: Colors.white,
            indicatorWeight: 3,

            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: GoogleFonts.tajawal(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            tabs: const [
              Tab(text: "أقرأه الآن"),
              Tab(text: "أرغب بقراءته"),
              Tab(text: "أنهيتها"),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildBookList(readingNowBooks, isReadingNow: true),
            _buildBookList(wantToReadBooks, isWantToRead: true),
            _buildBookList(completedBooks, isCompleted: true),
          ],
        ),
      ),
    );
  }

  // ويدجت بناء قائمة الكتب بشكل بطاقات مستطيلة وراء بعضها
  Widget _buildBookList(
    List<Map<String, String>> booksList, {
    bool isReadingNow = false,
    bool isWantToRead = false,
    bool isCompleted = false,
  }) {
    if (booksList.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      itemCount: booksList.length,
      itemBuilder: (context, index) {
        final book = booksList[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          height: 115,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // غلاف الكتاب الأيمن
              Container(
                width: 85,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.burgundy.withOpacity(0.05),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.bookmark_rounded,
                    size: 32,
                    color: AppColors.burgundy,
                  ),
                ),
              ),

              // تفاصيل الكتاب في المنتصف
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        book['title']!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.tajawal(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "المؤلف: ${book['author']!}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.tajawal(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),

                      if (isReadingNow) ...[
                        Row(
                          children: [
                            const Icon(
                              Icons.trending_up_rounded,
                              color: AppColors.burgundy,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "وصلت إلى: ${book['progress']!}",
                              style: GoogleFonts.tajawal(
                                fontSize: 11,
                                color: AppColors.burgundy,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ] else if (isWantToRead) ...[
                        Text(
                          book['date']!,
                          style: GoogleFonts.tajawal(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ] else if (isCompleted) ...[
                        Row(
                          children: [
                            const Icon(
                              Icons.check_circle_outline_rounded,
                              color: Colors.green,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              book['finishDate']!,
                              style: GoogleFonts.tajawal(
                                fontSize: 11,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // زر الخيارات الأيسر
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.grey),
                onPressed: () {},
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.import_contacts_rounded,
            size: 60,
            color: Colors.grey.withOpacity(0.3),
          ),
          const SizedBox(height: 12),
          Text(
            "لا توجد كتب في هذه القائمة حالياً",
            style: GoogleFonts.tajawal(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
