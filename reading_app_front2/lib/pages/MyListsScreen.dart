import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:reading_app_front2/conset_app.dart';
import 'package:reading_app_front2/models/book.dart';
import 'package:reading_app_front2/provider/LibraryProvider.dart';
import 'package:reading_app_front2/provider/user_provider.dart';
import 'package:reading_app_front2/widget/book_card.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.token != null) {
        Provider.of<LibraryProvider>(
          context,
          listen: false,
        ).fetchUserLibrary(token: userProvider.token!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final libraryProvider = context.watch<LibraryProvider>();

    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.burgundy,
        toolbarHeight: 70,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "قوائمي",
          style: GoogleFonts.katibeh(fontSize: 30, color: Colors.white),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white, // لون النص للتبويب النشط
          unselectedLabelColor: Colors.white70, // لون النص للتبويبات غير النشطة
          labelStyle: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: "اريد قراءته"),
            Tab(text: "اقرأه الان"),
            Tab(text: "تمت قراءته"),
          ],
        ),
      ),
      body: libraryProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.burgundy),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildList(libraryProvider.readingBooks),
                _buildList(libraryProvider.wantToReadBooks),
                _buildList(libraryProvider.completedBooks),
              ],
            ),
    );
  }

  Widget _buildList(List<Book> books) {
    if (books.isEmpty) return _buildEmptyState();

    return ListView.builder(
      padding: const EdgeInsets.only(top: 14, bottom: 20),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];

        return Stack(
          children: [
            BookCard(book: book),
            Positioned(
              left: 26.7,
              top: 10,
              child: GestureDetector(
                onTap: () => _showDeleteDialog(context, book),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color:AppColors.burgundy,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, Book book) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.creamBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: const Text(
            'حذف من القائمة',
            style: TextStyle(
              color: AppColors.burgundy,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: Text(
            'هل أنتِ متأكدة من رغبتك في إزالة "${book.title}" من القائمة؟',
            style: const TextStyle(
              color: AppColors.burgundy,
              fontSize: 14.5,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              style: TextButton.styleFrom(
                side: const BorderSide(color: AppColors.burgundy),
              ),
              child: const Text(
                'إلغاء',
                style: TextStyle(
                  color: AppColors.burgundy,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final userProvider = Provider.of<UserProvider>(
                  context,
                  listen: false,
                );
                Provider.of<LibraryProvider>(
                  context,
                  listen: false,
                ).removeBook(bookId: book.id, token: userProvider.token!);
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.burgundy,
                foregroundColor: AppColors.creamBackground,
              ),
              child: const Text(
                'حذف',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        "لا توجد كتب",
        style: GoogleFonts.tajawal(color: Colors.grey),
      ),
    );
  }
}
