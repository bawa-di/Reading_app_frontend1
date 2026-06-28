import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:reading_app_front2/conset_app.dart'; 
import 'package:reading_app_front2/models/book.dart'; 
import 'package:reading_app_front2/pages/BookDetailsScreen.dart';
import 'package:reading_app_front2/provider/LibraryProvider.dart';
import 'package:reading_app_front2/provider/user_provider.dart';

class MyListsScreen extends StatefulWidget {
  static String id = 'MyListsScreen';
  const MyListsScreen({super.key});

  @override
  State<MyListsScreen> createState() => _MyListsScreenState();
}

class _MyListsScreenState extends State<MyListsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // 🔄 جلب البيانات الحية من السيرفر فور تحميل هذه الشاشة باستخدام التوكن للتأكيد
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.token != null && userProvider.token!.isNotEmpty) {
        Provider.of<LibraryProvider>(context, listen: false).fetchUserLibrary(
          token: userProvider.token!,
        );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 🛠️ دالة ذكية لتصحيح روابط الصور وتجنب مشاكل الـ localhost في المحاكيات
  String? _getValidImageUrl(Book book) {
    // 1. محاولة قراءة الرابط من عدة مسميات محتملة داخل الموديل الخاص بكِ
    String? rawUrl = book.coverImagePath; 
    
    // إذا كان المسمى لديكِ مختلفاً، يمكنكِ تفعيل الأسطر بالأسفل:
    // rawUrl ??= (book as dynamic).image;
    // rawUrl ??= (book as dynamic).cover;

    if (rawUrl == null || rawUrl.isEmpty) return null;

    // 2. إذا كان الرابط يحتوي على localhost وكان التشغيل من محاكي أندرويد، نقوم باستبداله بـ IP المحاكي الافتراضي
    if (rawUrl.contains('localhost')) {
      return rawUrl.replaceAll('localhost', '10.0.2.2');
    } else if (rawUrl.contains('127.0.0.1')) {
      return rawUrl.replaceAll('127.0.0.1', '10.0.2.2');
    }
    
    return rawUrl;
  }

  @override
  Widget build(BuildContext context) {
    // مراقبة الـ LibraryProvider للاستماع لتحديثات القوائم والـ Loading حركياً
    final libraryProvider = context.watch<LibraryProvider>();

    // قراءة القوائم الثلاث المليئة بكائنات الكتب الحقيقية مباشرة من البروفايدر
    final List<Book> readingNowBooks = libraryProvider.readingBooks;
    final List<Book> wantToReadBooks = libraryProvider.wantToReadBooks;
    final List<Book> completedBooks = libraryProvider.completedBooks;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.creamBackground,
        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: AppColors.burgundy,
          toolbarHeight: 70,
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
            dividerColor: Colors.transparent,
            indicatorSize: TabBarIndicatorSize.label,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: const [
              Tab(text: "أقرأه الآن"),
              Tab(text: "أرغب بقراءته"),
              Tab(text: "أنهيتها"),
            ],
          ),
        ),
        body: libraryProvider.isLoading 
            ? const Center(child: CircularProgressIndicator(color: AppColors.burgundy))
            : TabBarView(
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

  // ويدجت بناء قائمة الكتب الحية بشكل بطاقات مستطيلة
  Widget _buildBookList(
    List<Book> booksList, {
    bool isReadingNow = false,
    bool isWantToRead = false,
    bool isCompleted = false,
  }) {
    if (booksList.isEmpty) {
      return _buildEmptyState();
    }

    int rowsCount = (booksList.length / 3).ceil();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      itemCount: booksList.length,
      itemBuilder: (context, index) {
        final Book book = booksList[index];
    final String? imageUrl = _getValidImageUrl(book);

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, BookDetailPage.id, arguments: book);
      },
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            height: 115,
                decoration: BoxDecoration(
                  color: Colors.white,
              borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    // ظل ناعم وضبابي جداً (Soft Glow) بدلاً من الظلال الحادة المزعجة
                    BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // 🟢 غلاف الكتاب المحدث لعرض الصور الحقيقية بدقة وسلاسة
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
                child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                            // في حال حدوث خطأ تام بالشبكة يُظهر شكلاً جمالياً بدلاً من التوقف
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                                child: Icon(Icons.broken_image_rounded, color: Colors.grey, size: 28),
                            );
                          },
                        )
                      : const Center(
                            child: Icon(Icons.book_rounded, size: 30, color: AppColors.burgundy),
                        ),
                ),
              ),

                // تفاصيل الكتاب في المنتصف
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                  book.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                ),
                        const SizedBox(height: 4),
                        Text(
                          "المؤلف: ${book.author}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.tajawal(fontSize: 12, color: Colors.grey[600]),
                ),
                        const SizedBox(height: 8),

                        if (isReadingNow) ...[
                          Row(
                            children: [
                              const Icon(Icons.trending_up_rounded, color: AppColors.burgundy, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                "جاري قراءته حالياً",
                                style: GoogleFonts.tajawal(fontSize: 11, color: AppColors.burgundy, fontWeight: FontWeight.bold),
              ),
            ],
          ),
                        ] else if (isWantToRead) ...[
                          Text(
                            "مضاف إلى الرف المفضّل",
                            style: GoogleFonts.tajawal(fontSize: 11, color: Colors.grey[500]),
                          ),
                        ] else if (isCompleted) ...[
                          Row(
                            children: [
                              const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                "تمت قراءته بنجاح",
                                style: GoogleFonts.tajawal(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                  ],
                ),
                  ),
                ),

                // زر الخيارات الأيسر للحذف
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                  onPressed: () => _confirmRemoveBook(context, book),
              ),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.import_contacts_rounded, size: 60, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 12),
          Text(
            "لا توجد كتب في هذه القائمة حالياً",
            style: GoogleFonts.tajawal(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _confirmRemoveBook(BuildContext context, Book book) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('إزالة من الرفوف', style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Text('هل أنتِ متأكدة من رغبتكِ في إزالة كتاب "${book.title}" من قوائمك؟', style: GoogleFonts.tajawal(fontSize: 14)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () async {
              final userProvider = Provider.of<UserProvider>(context, listen: false);
              Navigator.pop(ctx);
              if (userProvider.token != null) {
                await Provider.of<LibraryProvider>(context, listen: false).removeBook(bookId: book.id, token: userProvider.token!);
              }
            },
            child: const Text('تأكيد الحذف', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}