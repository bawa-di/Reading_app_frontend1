import 'package:flutter/material.dart';
import 'package:reading_app_front2/conset_app.dart';
 
import 'package:reading_app_front2/pages/SettingsScreen.dart';
import 'package:reading_app_front2/pages/home.dart';

class MainWrapper extends StatefulWidget {
  static String id = 'MainWrapper';
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 3; // افتراضياً نبدأ من الهوم (أقصى اليمين)

  // قائمة الصفحات (تأكدي من استيراد الملفات بشكل صحيح)
  final List<Widget> _screens = [
    const SettingsScreen(), 
    const Center(child: Text("المفضلة")), 
    const Center(child: Text("المكتبة")), 
    const HomeScreen(),     
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      // SafeArea هنا تحمي المحتوى من التداخل مع حواف الشاشة
      body: SafeArea(
        top: false, // لكي يمتد اللون البرغندي للهيدر للأعلى تماماً
        child: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 85,
      decoration: BoxDecoration(
        color: AppColors.burgundy,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          currentIndex: _selectedIndex,
          selectedItemColor: AppColors.pinkAccent,
          unselectedItemColor: AppColors.textFieldFill.withOpacity(0.6),
          showSelectedLabels: false,
          showUnselectedLabels: false,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.settings_outlined, size: 28), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.favorite_border, size: 28), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.menu_book, size: 28), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.home_filled, size: 28), label: ''),
          ],
        ),
      ),
    );
  }
}