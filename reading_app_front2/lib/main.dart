import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:reading_app_front2/pages/Login%20Screen.dart';
import 'package:reading_app_front2/pages/RegisterScreen.dart';
import 'package:reading_app_front2/pages/welcom.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // هذه الطريقة تحل مشكلة الـ inherit والـ TextStyle lerp
        useMaterial3: true,
        textTheme: GoogleFonts.arimaTextTheme(
          ThemeData.light().textTheme, // نأخذ الثيم الأساسي ونطبق عليه خط كايرو
        ),
      ),
      // --- إضافة دعم اللغة العربية والاتجاه من اليمين لليسار ---
      localizationsDelegates: const [
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale("ar", "AE"), // اللغة العربية
      ],
      locale: const Locale("ar", "AE"), // إجبار التطبيق على الواجهة العربية
      // -------------------------------------------------------
      initialRoute: 'WelcomePage',
      routes: {
        'WelcomePage': (context) => const WelcomePage(),
        LoginScreen.titel: (context) => const LoginScreen(),
        RegisterScreen.id: (context) => const RegisterScreen(),
      },
    );
  }
}
