import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 🟢 أضفنا هذا الاستيراد للتحكم بنظام شريط الساعة
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:reading_app_front2/pages/FavoritesScreen.dart';
import 'package:reading_app_front2/pages/Login%20Screen.dart';
import 'package:reading_app_front2/pages/MyListsScreen.dart';
import 'package:reading_app_front2/pages/MySuggestionsScreen.dart';
import 'package:reading_app_front2/pages/NotificationsScreen.dart';
import 'package:reading_app_front2/pages/SuggestBookScreen.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:reading_app_front2/pages/EditProfilePage.dart';
import 'package:reading_app_front2/pages/LeaderboardScreen.dart';
import 'package:reading_app_front2/pages/ProfileScreen.dart';
import 'package:reading_app_front2/pages/RegisterScreen.dart';
import 'package:reading_app_front2/pages/SettingsScreen.dart';
import 'package:reading_app_front2/pages/home.dart';
import 'package:reading_app_front2/pages/welcom.dart';
import 'package:reading_app_front2/provider/leaderboard_provider.dart';
import 'package:reading_app_front2/provider/user_provider.dart';

void main() async {
  // التأكد من تهيئة أدوات Flutter قبل قراءة الذاكرة
  WidgetsFlutterBinding.ensureInitialized();

  // قراءة التوكن المحفوظ من الذاكرة الدائمة للهاتف
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? savedToken = prefs.getString('token');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            UserProvider provider = UserProvider();
            // إذا وجدنا توكن محفوظ، نقوم بتعيينه في البروفايدر فوراً عند التشغيل
            if (savedToken != null) {
              provider.setToken(savedToken);
            }
            return provider;
          },
        ),
        ChangeNotifierProvider(create: (_) => LeaderboardProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.arimaTextTheme(ThemeData.light().textTheme),
        
        // 🟢 التعديل السحري: فصل وضبط شريط الساعة والبطارية (Status Bar) على مستوى التطبيق كامل
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent, // يجعل خلفية الساعة شفافة ومدمجة مع انسيابية الـ AppBar
            statusBarIconBrightness: Brightness.light, // أجهزة الأندرويد: يجعل أرقام الساعة والبطارية بيضاء لتظهر فوق لون تطبيقك الغامق
            statusBarBrightness: Brightness.dark, // أجهزة الآيفون: يجعل أرقام الساعة والبطارية بيضاء
          ),
        ),
      ),
      
      // إعدادات اللغة العربية
      localizationsDelegates: const [
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [Locale("ar", "AE")],
      locale: const Locale("ar", "AE"),

      // يمكنكِ تغيير initialRoute إلى HomeScreen.id إذا كان التوكن موجوداً لعمل Auto-Login
      initialRoute: 'WelcomePage',

      routes: {
        'WelcomePage': (context) => const WelcomePage(),
        LoginScreen.id: (context) => const LoginScreen(),
        RegisterScreen.id: (context) => const RegisterScreen(),
        HomeScreen.id: (context) => const HomeScreen(),
        ProfileScreen.id: (context) => const ProfileScreen(),
        SettingsScreen.id: (context) => const SettingsScreen(),
        EditProfilePage.id: (context) => EditProfilePage(),
        LeaderboardScreen.id: (context) => const LeaderboardScreen(),
        MySuggestionsScreen.id: (context) => const MySuggestionsScreen(),
        FavoritesScreen.id: (context) => const FavoritesScreen(),
        MyListsScreen.id: (context) => const MyListsScreen(),
        NotificationsScreen.id: (context) => const NotificationsScreen(),
      },
    );
  }
}