import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'package:reading_app_front2/conset_app.dart';
import 'package:reading_app_front2/pages/RegisterScreen.dart';
import 'package:reading_app_front2/pages/home.dart';
import 'package:reading_app_front2/provider/user_provider.dart';
import 'package:reading_app_front2/services/AuthService.dart';
import 'package:reading_app_front2/widget/AnimatedBookIcon.dart';
import 'package:reading_app_front2/widget/Custom%20Components.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:reading_app_front2/models/UserProfileModel.dart'; 

class LoginScreen extends StatefulWidget {
  static String id = 'login'; // تأكدي أن هذا المعرف مطابق لما في main.dart
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
      _showSnackBar("يرجى إدخال البريد وكلمة المرور");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await AuthService().loginUser(
        email: email,
        password: password,
      );

      // التحقق من النجاح بناءً على رد السيرفر في الكونسول (success: true)
      if (result['status'] == 200 || result['body']['success'] == true) {
        
        var responseData = result['body']['data'];
        String? token = responseData['token'];
        var userData = responseData['user']; // استخراج كائن المستخدم

        if (userData != null) {
          // 1. حفظ التوكن
          if (token != null) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('token', token);
          }

          if (mounted) {
            // 2. تحديث البروفايدر باستخدام الموديل الموحد
            // ملاحظة: userData هنا تحتوي مباشرة على (id, name, email...)
            context.read<UserProvider>().setUser(UserProfileModel.fromJson(userData));

            // 3. رسالة ترحيب
            _showSnackBar("أهلاً بكِ مجدداً");

            // 4. الانتقال النهائي للهوم وحذف صفحات المكدس
            Navigator.pushNamedAndRemoveUntil(
              context, 
              HomeScreen.id, 
              (route) => false
            );
          }
        } else {
          throw Exception("بيانات المستخدم غير موجودة في الرد");
        }
      } else {
        if (mounted) {
          _showSnackBar(result['body']['message'] ?? "خطأ في بيانات الدخول");
        }
      }
    } catch (e) {
      debugPrint("❌ Login Crash: $e");
      if (mounted) {
        _showSnackBar("حدث خطأ أثناء الربط: $e");
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.textFieldFill,
        content: Text(
          message,
          style: const TextStyle(color: AppColors.burgundy),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.burgundy,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              _buildBackgroundShapes(),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      _buildAnimatedLogo(),
                      const SizedBox(height: 20),
                      const Text("تسجيل الدخول", style: AppTextStyles.headerStyle),
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
                          ? const CircularProgressIndicator(color: AppColors.creamBackground)
                          : CustomButton(text: "تسجيل الدخول", onPressed: _handleLogin),
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

  // دوال التصميم تبقى كما هي لديكِ
  Widget _buildBackgroundShapes() {
    return Stack(
      children: [
        Positioned(
          bottom: -30, right: -50, top: 50,
          child: CircleAvatar(
            radius: 400,
            backgroundColor: AppColors.pinkAccent.withOpacity(0.4),
          ),
        ),
        Positioned(
          bottom: -30, right: -20, top: 50,
          child: const CircleAvatar(
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
          BoxShadow(color: Colors.white.withOpacity(0.8), blurRadius: 40, spreadRadius: 10),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(width: 100, height: 100, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white)),
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
        child: Text("نسيت كلمة المرور؟", style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
      ),
    );
  }

  Widget _buildGoToRegister() {
    return TextButton(
      onPressed: () => Navigator.pushNamed(context, RegisterScreen.id),
      child: const Text("ليس لديك حساب؟ إنشاء حساب", style: TextStyle(color: AppColors.burgundy, fontWeight: FontWeight.bold)),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}