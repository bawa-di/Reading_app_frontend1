import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reading_app_front2/conset_app.dart'; // ملف الألوان الخاص بكِ

class FavoritesScreen extends StatefulWidget {
  static String id = 'FavoritesScreen';
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  // بيانات تجريبية لمحاكاة الروايات المضافة للمفضلة
  final List<Map<String, String>> favoriteBooks = [
    {
      "title": "أرض زيكولا",
      "author": "عمرو عبد الحميد",
      "image": "https://via.placeholder.com/150",
      "category": "روايات",
      "rating": "4.8",
    },
    {
      "title": "قواعد العشق الأربعون",
      "author": "إليف شفق",
      "image": "https://via.placeholder.com/150",
      "category": "روايات عالمية",
      "rating": "4.5",
    },
    {
      "title": "الرقص مع الحياة",
      "author": "مهدي الموسوي",
      "image": "https://via.placeholder.com/150",
      "category": "تنمية بشرية",
      "rating": "4.6",
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
          toolbarHeight: 70,
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
          backgroundColor: AppColors.burgundy,
          title: Text(
            "المفضلة",
            style: GoogleFonts.katibeh(fontSize: 30, color: Colors.white),
          ),
          centerTitle: true,
        ),
        
        body: favoriteBooks.isEmpty
            ? _buildEmptyFavorites()
            : ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 15,
                ),
                itemCount: favoriteBooks.length,
                itemBuilder: (context, index) {
                  final book = favoriteBooks[index];
                  return _buildHorizontalBookCard(book, index);
                },
              ),
      ),
    );
  }

  // ويدجت تصميم بطاقة الكتاب المستطيلة (الأفقية الممتدة) وراء بعضها
  Widget _buildHorizontalBookCard(Map<String, String> book, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14), // مسافة بين البطاقات المستطيلة
      height: 125, // ارتفاع ثابت ومناسب للمستطيل الأفقي
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
          // 1. غلاف الكتاب (مستطيل على اليمين)
          Container(
            width: 90,
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
                Icons.book_rounded,
                size: 35,
                color: AppColors.burgundy,
              ),
            ),
          ),

          // 2. تفاصيل الرواية أو الكتاب (في المنتصف)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                        "بقلم: ${book['author']!}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.tajawal(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),

                  // التقييم والتصنيف أسفل التفاصيل
                  Row(
                    children: [
                      // التاج أو التصنيف
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.creamBackground,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          book['category']!,
                          style: GoogleFonts.tajawal(
                            fontSize: 10,
                            color: AppColors.burgundy,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // النجمة والتقييم
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 16,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            book['rating']!,
                            style: GoogleFonts.tajawal(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 3. زر الحذف أو الإلغاء (أيقونة قلب ممتلئ على اليسار)
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: IconButton(
              icon: const Icon(Icons.favorite, color: Colors.red, size: 22),
              onPressed: () {
                setState(() {
                  favoriteBooks.removeAt(index); // إزالة تفاعلية مؤقتة للتجربة
                });
                // هنا يتم ربط دالة حذف الكتاب من المفضلة في الباك-إند لاحقاً
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFavorites() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border_rounded,
            size: 70,
            color: Colors.grey.withOpacity(0.4),
          ),
          const SizedBox(height: 15),
          Text(
            "قائمة المفضلة فارغة حالياً",
            style: GoogleFonts.tajawal(
              color: Colors.grey,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "تصفح الروايات وأضف ما يعجبك لتجده هنا.",
            style: GoogleFonts.tajawal(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
