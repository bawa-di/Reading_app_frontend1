import 'package:flutter/material.dart';
import 'package:reading_app_front2/conset_app.dart';
import 'package:reading_app_front2/pages/Login%20Screen.dart';
import 'package:reading_app_front2/pages/RegisterScreen.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 50),

            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.pinkAccent.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/book.jpg',
                      width: 250,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "جَليس",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.burgundy,
                        fontFamily: 'Serif',
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "دليلك الشامل لتنظيم وقت القراءة، متابعة تقدمك، وطرح الأسئلة",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                    const Spacer(),
                    _buildButton(
                      text: "إنشاء حساب جديد",
                      color: AppColors.burgundy,
                      textColor: Colors.white,
                      onPressed: () {
                        Navigator.pushNamed(context, RegisterScreen.id);
                      },
                    ),

                    const SizedBox(height: 15),

                    // زر تسجيل الدخول
                    _buildButton(
                      text: "تسجيل الدخول",
                      color: AppColors.textFieldFill,
                      textColor: AppColors.burgundy,
                      isBorder: true,
                      onPressed: () {
                        Navigator.pushNamed(context, LoginScreen.id);
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required Color color,
    required Color textColor,
    required VoidCallback onPressed,
    bool isBorder = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: isBorder ? 0 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: isBorder
                ? const BorderSide(color: AppColors.burgundy)
                : BorderSide.none,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
