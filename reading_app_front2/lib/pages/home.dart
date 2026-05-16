import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // أضفنا استيراد البروفايدر
import 'package:reading_app_front2/conset_app.dart';
import 'package:reading_app_front2/pages/FavoritesScreen.dart';
import 'package:reading_app_front2/pages/LeaderboardScreen.dart';
import 'package:reading_app_front2/pages/MyListsScreen.dart';
import 'package:reading_app_front2/pages/MySuggestionsScreen.dart';
import 'package:reading_app_front2/pages/NotificationsScreen.dart';
import 'package:reading_app_front2/pages/ProfileScreen.dart';
import 'package:reading_app_front2/pages/SettingsScreen.dart';
import 'package:reading_app_front2/pages/SuggestBookScreen.dart';
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

            // 🟢 التعديل الجديد: استدعاء الودجت العائم الذي يجمع البحث والاشعارات
            _buildSearchBarWithNotifications(context),

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

  // الهيدر رجع كما هو تماماً يا هندسة، نظيف بدون أيقونات إشعارات
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

  // 🟢 ويدجت جديدة تماماً: تجمع حقل البحث مع جرس الإشعارات في دائرة صغيرة عائمة بجانبه
  Widget _buildSearchBarWithNotifications(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -25), // نفس الإزاحة السابقة لتبقى عائمة
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            // 1. حقل البحث (أخذ المساحة الأكبر)
            Expanded(
              child: Material(
                elevation: 5,
                borderRadius: BorderRadius.circular(30),
                child: TextField(
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: "البحث",
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.pinkAccent,
                    ),
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

            const SizedBox(width: 12), // مسافة تفصل البحث عن الجرس العائم
            // 2. 🟢 جرس الإشعارات في دائرة صغيرة عائمة وأنيقة جداً
            Material(
              elevation: 5, // نفس قوة ظل البحث لتناسق المظهر
              borderRadius: BorderRadius.circular(30),
              color: AppColors
                  .textFieldFill, // لون الخلفية (كريمي فاتح) ليتناسق مع حقل البحث
              child: Container(
                width: 50, // قطر الدائرة الصغيرة
                height: 50,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.notifications_none_rounded,
                        color: AppColors
                            .pinkAccent, // استخدمنا لون الـ pink لتأكيد أهمية الجرس
                        size: 26,
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, NotificationsScreen.id);
                      },
                    ),
                    // نقطة التنبيه الحمراء فوق الجرس العائم
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.pinkAccent,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 8,
                          minHeight: 8,
                        ),
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

  // --- باقي الـ Widgets (Continue Reading, Bottom Nav) تبقى كما هي تماماً ---

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

          if (index == 1) {
            Navigator.pushNamed(context, MySuggestionsScreen.id);
          }
          if (index == 2) {
            Navigator.pushNamed(context, FavoritesScreen.id);
          }
          if (index == 3) {
            Navigator.pushNamed(context, MyListsScreen.id);
          }
          if (index == 4) {
            Navigator.pushNamed(context, LeaderboardScreen.id);
          }
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
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite, color: AppColors.pinkAccent),
            label: 'المفضلة',
          ),

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
