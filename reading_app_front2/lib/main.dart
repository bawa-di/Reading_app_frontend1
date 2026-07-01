import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:reading_app_front2/pages/FavoritesScreen.dart';
import 'package:reading_app_front2/pages/Login%20Screen.dart';
import 'package:reading_app_front2/pages/MyListsScreen.dart';
import 'package:reading_app_front2/pages/MySuggestionsScreen.dart';
import 'package:reading_app_front2/pages/NotificationsScreen.dart';
import 'package:reading_app_front2/pages/PaymentScreen.dart';
import 'package:reading_app_front2/pages/SuggestBookScreen.dart';
import 'package:reading_app_front2/provider/LibraryProvider.dart';
import 'package:reading_app_front2/provider/NotificationProvider.dart';
import 'package:reading_app_front2/provider/RatingProvider.dart';
import 'package:reading_app_front2/provider/SuggestionProvider.dart';
import 'package:reading_app_front2/provider/comment_provider.dart';
import 'package:reading_app_front2/provider/payment_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reading_app_front2/pages/EditProfilePage.dart';
import 'package:reading_app_front2/pages/LeaderboardScreen.dart';
import 'package:reading_app_front2/pages/ProfileScreen.dart';
import 'package:reading_app_front2/pages/RegisterScreen.dart';
import 'package:reading_app_front2/pages/BookDetailsScreen.dart';
import 'package:reading_app_front2/pages/SettingsScreen.dart';
import 'package:reading_app_front2/pages/home.dart';
import 'package:reading_app_front2/pages/welcom.dart';
import 'package:reading_app_front2/provider/books_provider.dart';
import 'package:reading_app_front2/provider/favorites_provider.dart';
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
        ChangeNotifierProvider(create: (_) => BooksProvider()),
        ChangeNotifierProvider(
          create: (_) {
            UserProvider provider = UserProvider();
            if (savedToken != null) {
              provider.setToken(savedToken);
            }
            return provider;
          },
        ),
        // تفعيل جلب المفضلة فوراً عند الإقلاع وإلغاء خاصية التحميل الكسول Lazy
        ChangeNotifierProvider(create: (_) => FavoritesProvider(), lazy: false),

        // 🟢 التعديل الذكي هنا: إلغاء الـ Lazy وجلب مكتبة ورفوف المستخدم فوراً عند الإقلاع
        ChangeNotifierProvider(
          create: (_) {
            LibraryProvider libraryProvider = LibraryProvider();
            if (savedToken != null && savedToken.isNotEmpty) {
              // استدعاء دالة الجلب الكاملة التي قمنا بتحديثها مسبقاً للاتصال بـ Laravel
              libraryProvider.fetchUserLibrary(token: savedToken);
              print(
                "🚀 [App Launch] جاري جلب رفوف وحالات الكتب لتثبيت الأزرار...",
              );
            }
            return libraryProvider;
          },
          lazy:
              false, // نجبر البروفايدر على العمل فوراً دون انتظار فتح شاشة معينة
        ),
        ChangeNotifierProvider(create: (_) => RatingProvider()),
        ChangeNotifierProvider(create: (_) => LeaderboardProvider()),
        ChangeNotifierProvider(create: (_) => SuggestionProvider()),
        ChangeNotifierProvider(create: (_) => CommentProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
      ],
      // تمرير الـ savedToken إلى الـ MyApp لعمل فحص التوجيه التلقائي
      child: MyApp(savedToken: savedToken),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String? savedToken;
  const MyApp({super.key, this.savedToken});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.arimaTextTheme(ThemeData.light().textTheme),
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
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

      // ميزة الـ Auto-Login الذكية لـ تطبيق دفة:
      // إذا كان المستخدم يمتلك توكن مسبق، يفتح التطبيق مباشرة على شاشة الـ Home
      // وإذا كان مستخدم جديد، يفتح على صفحة الـ WelcomePage
      initialRoute: savedToken != null ? HomeScreen.id : 'WelcomePage',

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
        NotificationsScreen.id: (context) => NotificationsScreen(),
        BookDetailPage.id: (context) => const BookDetailPage(),

      },
    );
  }
}
