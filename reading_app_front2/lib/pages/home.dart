import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:reading_app_front2/conset_app.dart';
import 'package:reading_app_front2/models/book.dart';
import 'package:reading_app_front2/pages/FavoritesScreen.dart';
import 'package:reading_app_front2/pages/LeaderboardScreen.dart';
import 'package:reading_app_front2/pages/MyListsScreen.dart';
import 'package:reading_app_front2/pages/MySuggestionsScreen.dart';
import 'package:reading_app_front2/pages/NotificationsScreen.dart';
import 'package:reading_app_front2/pages/ProfileScreen.dart';
import 'package:reading_app_front2/pages/SettingsScreen.dart';
import 'package:reading_app_front2/provider/user_provider.dart';
import 'package:reading_app_front2/provider/books_provider.dart';
import 'package:reading_app_front2/widget/book_card.dart';

class HomeScreen extends StatefulWidget {
  static String id = 'HomeScreen';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).fetchUserData();
      Provider.of<BooksProvider>(context, listen: false).fetchBooks();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // نستخدم Consumer لجعل الصفحة تستمع لتحديثات المستخدم والكتب
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      bottomNavigationBar: _buildBottomNav(),
      body: Consumer2<UserProvider, BooksProvider>(
        builder: (context, userProvider, booksProvider, child) {
          final user = userProvider.user;
          final List<Book> dynamicBooks = booksProvider.books;

          return Column(
            children: [
              _buildHeader(context, user, userProvider.isLoading),
              _buildSearchBarWithNotifications(context, userProvider),
              Expanded(
                child: booksProvider.isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.burgundy))
                    : _buildBookSection(dynamicBooks),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, var user, bool isLoading) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
      decoration: const BoxDecoration(
        color: AppColors.burgundy,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                isLoading ? "جاري التحميل..." : "أهلاً ${user?.name ?? 'زائر'}",
                style: GoogleFonts.katibeh(color: AppColors.textFieldFill, fontSize: 24),
              ),
              const Text("ماذا سنقرأ اليوم؟", style: TextStyle(color: AppColors.textFieldFill, fontSize: 12)),
            ],
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, ProfileScreen.id),
            child: CircleAvatar(
              radius: 25,
              backgroundColor: AppColors.textFieldFill,
              backgroundImage: (user?.profileImg != null && user!.profileImg!.isNotEmpty) ? NetworkImage(user!.profileImg!) : null,
              child: (user?.profileImg == null || user!.profileImg!.isEmpty) ? const Icon(Icons.person, color: AppColors.pinkAccent) : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBarWithNotifications(BuildContext context, UserProvider userProvider) {
    return Transform.translate(
      offset: const Offset(0, -25),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Expanded(
              child: Material(
                elevation: 5,
                borderRadius: BorderRadius.circular(30),
                child: TextField(
                  controller: _searchController,
                  textAlign: TextAlign.right,
                  onChanged: (value) {
                    setState(() {});
                    final booksProvider = Provider.of<BooksProvider>(context, listen: false);
                    if (value.trim().isEmpty) {
                      booksProvider.fetchBooks();
                    } else {
                      booksProvider.searchBooks(queryText: value.trim());
                    }
                  },
                  decoration: InputDecoration(
                    hintText: "ابحث باسم الكتاب، الكاتب، أو التصنيف...",
                    prefixIcon: const Icon(Icons.search, color: AppColors.burgundy),
                    filled: true,
                    fillColor: AppColors.textFieldFill,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Material(
              elevation: 5,
              borderRadius: BorderRadius.circular(30),
              color: AppColors.textFieldFill,
              child: SizedBox(
                width: 50,
                height: 50,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_none_rounded, color: AppColors.burgundy, size: 26),
                      onPressed: () {
                        // عند الضغط، نقوم بإخفاء النقطة الحمراء
                        userProvider.setNotificationStatus(false);
                        Navigator.pushNamed(context, NotificationsScreen.id);
                      },
                    ),
                    if (userProvider.hasNewNotification)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookSection(List<Book> books) {
    if (books.isEmpty) {
      return Center(child: Text("لا توجد نتائج بحث مطابقة", style: GoogleFonts.tajawal(color: Colors.grey, fontSize: 16)));
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: books.length,
      itemBuilder: (context, index) => BookCard(book: books[index]),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(borderRadius: BorderRadius.vertical(top: Radius.circular(30)), color: AppColors.burgundy),
      child: BottomNavigationBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        selectedItemColor: AppColors.textFieldFill,
        unselectedItemColor: AppColors.textFieldFill,
        type: BottomNavigationBarType.fixed,
        currentIndex: 5,
        onTap: (index) {
          if (index == 0) Navigator.pushNamed(context, SettingsScreen.id);
          if (index == 1) Navigator.pushNamed(context, MySuggestionsScreen.id);
          if (index == 2) Navigator.pushNamed(context, FavoritesScreen.id);
          if (index == 3) Navigator.pushNamed(context, MyListsScreen.id);
          if (index == 4) Navigator.pushNamed(context, LeaderboardScreen.id);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'الإعدادات'),
          BottomNavigationBarItem(icon: Icon(Icons.lightbulb_outline_sharp), label: 'اقتراحات'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite, color: AppColors.pinkAccent), label: 'المفضلة'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'القوائم'),
          BottomNavigationBarItem(icon: Icon(Icons.people_alt_sharp), label: 'مجتمعي'),
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'الرئيسية'),
        ],
      ),
    );
  }
}