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
import 'package:reading_app_front2/provider/NotificationProvider.dart';
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
      // 1. جلب بيانات المستخدم والكتب
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.fetchUserData();
      Provider.of<BooksProvider>(context, listen: false).fetchBooks();
      
      // 2. جلب الإشعارات فوراً بعد تحميل الشاشة إذا كان التوكن متاحاً
      final token = userProvider.token;
      if (token != null) {
        Provider.of<NotificationProvider>(context, listen: false).loadNotifications(token);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              _buildSearchBarEntry(context),
              Expanded(
                child: booksProvider.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.burgundy,
                        ),
                      )
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
                style: GoogleFonts.katibeh(
                  color: AppColors.textFieldFill,
                  fontSize: 24,
                ),
              ),
              const Text(
                "ماذا سنقرأ اليوم؟",
                style: TextStyle(color: AppColors.textFieldFill, fontSize: 12),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, ProfileScreen.id),
            child: CircleAvatar(
              radius: 25,
              backgroundColor: AppColors.textFieldFill,
              backgroundImage:
                  (user?.profileImg != null && user!.profileImg!.isNotEmpty)
                  ? NetworkImage(user!.profileImg!)
                  : null,
              child: (user?.profileImg == null || user!.profileImg!.isEmpty)
                  ? const Icon(Icons.person, color: AppColors.pinkAccent)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBarEntry(BuildContext context) {
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
                color: AppColors.textFieldFill,
                child: TextField(
                  controller: _searchController,
                  readOnly: true,
                  onTap: () => _showAdvancedSearchModal(context),
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    hintText: "ابحث عن كتابك المفضل",
                    prefixIcon: Icon(Icons.search, color: AppColors.burgundy),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            _buildNotificationButton(),
          ],
        ),
      ),
    );
  }

  void _showAdvancedSearchModal(BuildContext context) {
    final TextEditingController titleCtrl = TextEditingController(
      text: _searchController.text,
    );
    final TextEditingController authorCtrl = TextEditingController();
    final TextEditingController generCtrl = TextEditingController();
    final TextEditingController accessCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.creamBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "ابحث عن كتابك المفضل",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.burgundy,
              ),
            ),
            const SizedBox(height: 15),
            _buildSearchField(titleCtrl, "اسم الكتاب"),
            _buildSearchField(authorCtrl, "اسم المؤلف"),
            _buildSearchField(generCtrl, "التصنيف"),
            _buildSearchField(accessCtrl, "نوع الوصول"),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.burgundy,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                setState(() {
                  _searchController.text = titleCtrl.text;
                });
                Provider.of<BooksProvider>(context, listen: false).searchBooks(
                  title: titleCtrl.text,
                  author: authorCtrl.text,
                  gener: generCtrl.text,
                  accessType: accessCtrl.text,
                );
                Navigator.pop(context);
              },
              child: const Text(
                "بحث",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(TextEditingController controller, String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationButton() {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        int unreadCount = notificationProvider.unreadCount;

        return Material(
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
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: AppColors.burgundy,
                    size: 26,
                  ),
                  onPressed: () =>
                      Navigator.pushNamed(context, NotificationsScreen.id),
                ),
                if (unreadCount > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.pinkAccent,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        unreadCount > 9 ? '9+' : '$unreadCount',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.burgundy,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBookSection(List<Book> books) {
    if (books.isEmpty)
      return const Center(
        child: Text(
          "لا توجد نتائج بحث مطابقة",
          style: TextStyle(color: Colors.grey),
        ),
      );
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: books.length,
      itemBuilder: (context, index) => BookCard(book: books[index]),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        color: AppColors.burgundy,
      ),
      child: BottomNavigationBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        selectedItemColor: AppColors.textFieldFill,
        unselectedItemColor: AppColors.textFieldFill,
        type: BottomNavigationBarType.fixed,
        currentIndex: 5,
        onTap: (index) {
          if (index == 5) {
            setState(() {
              _searchController.clear();
            });
            Provider.of<BooksProvider>(context, listen: false).fetchBooks();
            return;
          }
          if (index == 0) Navigator.pushNamed(context, SettingsScreen.id);
          if (index == 1) Navigator.pushNamed(context, MySuggestionsScreen.id);
          if (index == 2) Navigator.pushNamed(context, FavoritesScreen.id);
          if (index == 3) Navigator.pushNamed(context, MyListsScreen.id);
          if (index == 4) Navigator.pushNamed(context, LeaderboardScreen.id);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'الإعدادات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb_outline_sharp),
            label: 'اقتراحات',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'المفضلة'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'القوائم'),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_sharp),
            label: 'مجتمعي',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'الرئيسية',
          ),
        ],
      ),
    );
  }
}