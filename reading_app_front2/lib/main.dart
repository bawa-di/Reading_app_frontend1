import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:reading_app_front2/pages/Login%20Screen.dart';
import 'package:reading_app_front2/pages/ProfileScreen.dart';
import 'package:reading_app_front2/pages/RegisterScreen.dart';
import 'package:reading_app_front2/pages/SettingsScreen.dart';
import 'package:reading_app_front2/pages/home.dart';
import 'package:reading_app_front2/pages/welcom.dart';
import 'package:reading_app_front2/provider/user_provider.dart';
import 'package:reading_app_front2/widget/MainWrapper.dart';

void main() {
  runApp(
    // تغليف التطبيق بالـ MultiProvider لجعله مهيئاً هندسياً لأي إضافات مستقبلية
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => UserProvider())],
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
      ),
      // --- الحفاظ على إعدادات اللغة العربية الخاصة بكِ ---
      localizationsDelegates: const [
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [Locale("ar", "AE")],
      locale: const Locale("ar", "AE"),
      // -------------------------------------------------------
      initialRoute: 'WelcomePage',
      routes: {
         MainWrapper.id: (context) => const MainWrapper(),
       
        'WelcomePage': (context) => const WelcomePage(),
        LoginScreen.id: (context) => const LoginScreen(),
        RegisterScreen.id: (context) => const RegisterScreen(),
        HomeScreen.id: (context) => const HomeScreen(),
        ProfileScreen.id: (context) => const ProfileScreen(),
         SettingsScreen.id: (context) => const SettingsScreen(),
      },
    );
  }
}
