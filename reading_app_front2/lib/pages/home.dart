import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // أضفنا استيراد البروفايدر
import 'package:reading_app_front2/conset_app.dart';
import 'package:reading_app_front2/pages/ProfileScreen.dart';
import 'package:reading_app_front2/pages/SettingsScreen.dart';
import 'package:reading_app_front2/provider/user_provider.dart';

class HomeScreen extends StatefulWidget {
  static String id = 'HomeScreen';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // هندسياً: نطلب من الخزان جلب البيانات مرة واحدة عند تشغيل التطبيق
    // استخدمنا listen: false لأننا داخل initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).fetchUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    // مراقبة الخزان: أي تغيير في بيانات المستخدم سيحدث الواجهة هنا تلقائياً
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;

    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      bottomNavigationBar: _buildBottomNav(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // مررنا بيانات المستخدم للهيدر
            _buildHeader(context, user, userProvider.isLoading),
            _buildSearchBar(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "Continue Reading",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            _buildContinueReading(),
          ],
        ),
      ),
    );
  }

  // أضفنا البراميترز هنا لنعرض البيانات المستلمة من البروفايدر
  Widget _buildHeader(BuildContext context, var user, bool isLoading) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 40),
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
                // استخدام البيانات من البروفايدر
                isLoading ? "جاري التحميل..." : "أهلاً${user?.name ?? 'زائر'}",
                style: GoogleFonts.katibeh(
                  color: AppColors.textFieldFill,
                  fontSize: 28,
                ),
              ),
              const Text(
                "ماذا سنقرأ اليوم؟",
                style: TextStyle(color: AppColors.textFieldFill, fontSize: 14),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, ProfileScreen.id);
            },
            child: CircleAvatar(
              radius: 25,
              backgroundColor: AppColors.textFieldFill,
              // عرض الصورة من البروفايدر
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

  // --- باقي الـ Widgets (Search Bar, Continue Reading, Nav) تبقى كما هي تماماً ---

  Widget _buildSearchBar() {
    return Transform.translate(
      offset: const Offset(0, -25),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Material(
          elevation: 5,
          borderRadius: BorderRadius.circular(30),
          child: TextField(
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              hintText: "...ابحث عن كتاب، مؤلف، أو تصنيف",
              prefixIcon: const Icon(Icons.search, color: AppColors.pinkAccent),
              filled: true,
              fillColor: AppColors.textFieldFill,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContinueReading() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.textFieldFill,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.creamBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.book),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  "رواية أنت لي",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: 0.65,
                  backgroundColor: AppColors.creamBackground,
                  color: AppColors.burgundy,
                ),
                const SizedBox(height: 4),
                const Text("65%", style: TextStyle(fontSize: 12)),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pinkAccent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "أكمل الآن",
                    style: TextStyle(color: AppColors.textFieldFill),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
        currentIndex: 3,
        onTap: (index) {
          if (index == 0) {
            // رقم 0 هو موقع أيقونة الإعدادات في القائمة لديكِ
            Navigator.pushNamed(context, SettingsScreen.id);
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite, color: AppColors.pinkAccent),
            label: '',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: ''),
        ],
      ),
    );
  }
}
