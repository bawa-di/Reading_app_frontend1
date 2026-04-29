import 'package:flutter/material.dart';
import 'package:reading_app_front2/conset_app.dart';
import 'package:reading_app_front2/pages/RegisterScreen.dart';
import 'package:reading_app_front2/services/AuthService.dart';
import 'package:reading_app_front2/widget/AnimatedBookIcon.dart';
import 'package:reading_app_front2/widget/Custom%20Components.dart';

class LoginScreen extends StatefulWidget {
  static String titel = 'login'; // تأكدي من تسميته id ليتوافق مع الـ Routes

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  void _handleLogin() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.textFieldFill,
          content: Text(
            style: TextStyle(color: AppColors.burgundy),
            "يرجى إدخال البريد وكلمة المرور",
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await AuthService().loginUser(
        email: email,
        password: password,
      );

      if (result['status'] == 200) {
        String userName = result['body']['data']['user']['name'];
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.textFieldFill,
              content: Text(
                "أهلاً بك يا $userName",
                style: const TextStyle(color: AppColors.burgundy),
              ),
            ),
          );
          // Navigator.pushReplacementNamed(context, '/home_page');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.textFieldFill,
              content: Text(
                style: TextStyle(color: AppColors.burgundy),
                result['body']['message'] ?? "خطأ في بيانات الدخول",
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.textFieldFill,
            content: Text(
              style: TextStyle(color: AppColors.burgundy),
              "خطأ في الشبكة: تأكد من اتصال السيرفر",
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.burgundy,
      // تفعيل الارتفاع عند ظهور الكيبورد
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Container(
          // إجبار الحاوية على أخذ طول الشاشة بالكامل لتتحرك كقطعة واحدة
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              // 1. الدوائر الخلفية (بنفس إحداثياتك الأصلية)
              _buildBackgroundShapes(),

              // 2. المحتوى فوق الخلفية
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      _buildAnimatedLogo(),
                      const SizedBox(height: 20),
                      const Text(
                        "تسجيل الدخول",
                        style: AppTextStyles.headerStyle,
                      ),
                      const SizedBox(height: 30),

                      CustomTextField(
                        controller: _emailController,
                        hintText: "عنوان البريد الإلكتروني",
                        icon: Icons.email_outlined,
                      ),
                      const SizedBox(height: 15),
                      CustomTextField(
                        controller: _passwordController,
                        hintText: "كلمة المرور",
                        icon: Icons.lock_outline,
                        isPassword: true,
                      ),

                      _buildForgotPassword(),
                      const SizedBox(height: 20),

                      _isLoading
                          ? const CircularProgressIndicator(
                              color: AppColors.creamBackground,
                            )
                          : CustomButton(
                              text: "تسجيل الدخول",
                              onPressed: _handleLogin,
                            ),

                      const SizedBox(height: 10),
                      _buildGoToRegister(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundShapes() {
    return Stack(
      children: [
        Positioned(
          bottom: -30,
          right: -50,
          top: 50,
          child: CircleAvatar(
            radius: 400,
            backgroundColor: AppColors.pinkAccent.withOpacity(0.4),
          ),
        ),
        Positioned(
          bottom: -30,
          right: -20,
          top: 50,
          child: CircleAvatar(
            radius: 400,
            backgroundColor: AppColors.creamBackground,
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedLogo() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.4),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 40,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
          AnimatedBookIcon(),
        ],
      ),
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {},
        child: Text(
          "نسيت كلمة المرور؟",
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildGoToRegister() {
    return TextButton(
      onPressed: () => Navigator.pushNamed(context, RegisterScreen.id),
      child: const Text(
        "ليس لديك حساب؟ إنشاء حساب",
        style: TextStyle(
          color: AppColors.burgundy,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
