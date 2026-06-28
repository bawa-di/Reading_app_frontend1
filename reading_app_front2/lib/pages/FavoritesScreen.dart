import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:reading_app_front2/conset_app.dart'; // ملف الألوان الخاص بكِ
import 'package:reading_app_front2/models/book.dart';
import 'package:reading_app_front2/provider/favorites_provider.dart';
import 'package:reading_app_front2/widget/book_card.dart'; // استيراد الكرت الموحد الخاص بكِ

class FavoritesScreen extends StatelessWidget {
  static String id = 'FavoritesScreen';
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // جلب البروفايدر للاستماع لبيانات المفضلة الحية
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final List<Book> books = favoritesProvider.favoriteBooks; 

    // 🟢 قمنا بإزالة Directionality من هنا لأن التطبيق مبرمج بالكامل RTL في الـ MaterialApp
    // لف الشاشة بـ Directionality محلياً يسبب أحياناً إعادة حساب القياسات (Constraints) بشكل خاطئ للـ Containers الداخلية.
    return Scaffold(
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
      
      body: favoritesProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.burgundy,
              ),
            )
          : books.isEmpty
              ? _buildEmptyFavorites()
              : Padding(
                  // 🟢 وضعنا الـ Padding هنا حول الـ ListView بالكامل تماماً كما فعلتِ في التابع _buildBookSection في الرئيسية
                  padding: const EdgeInsets.only(top: 14),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 20), // نفس بادينغ الرئيسية تماماً
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      // 🟢 عرض الكرت مباشرة وبشكل حر ليأخذ نفس الـ Constraints التي يأخذها في الرئيسية
                      return BookCard(book: books[index]);
                    },
                  ),
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