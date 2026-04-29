import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reading_app_front2/conset_app.dart';
import 'package:reading_app_front2/services/AuthService.dart';
import 'package:reading_app_front2/widget/Custom%20Components.dart';

class RegisterScreen extends StatefulWidget {
  static String id = 'register';
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  File? _pickedImage;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );
      if (image != null) setState(() => _pickedImage = File(image.path));
    } catch (e) {
      debugPrint("خطأ: $e");
    }
  }

  void _handleRegister() async {
    // 1. التحقق من الحقول الفارغة
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.textFieldFill,
          content: Text(
            "الرجاء إدخال البيانات الأساسية",
            style: TextStyle(color: AppColors.burgundy),
          ),
        ),
      );
      return;
    }

    // 2. التحقق من تطابق كلمة المرور
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("كلمة المرور غير متطابقة"),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await AuthService().registerUser(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        imagePath: _pickedImage?.path,
      );

      // 3. معالجة الرد من السيرفر (Laravel)
      if (result['status'] == 201 || result['status'] == 200) {
        if (mounted) {
          // إظهار رسالة النجاح التي كانت محذوفة
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor:AppColors.textFieldFill,
              content: Text(
                style: TextStyle(color: AppColors.burgundy),
                "تم إنشاء الحساب بنجاح!"),
            ),
          );

          // تأخير بسيط ليتمكن المستخدم من قراءة الرسالة قبل العودة
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) Navigator.pop(context);
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['body']['message'] ?? "فشل التسجيل")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("خطأ في الاتصال: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.burgundy,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Container(
          // الحفاظ على ارتفاع الشاشة لضمان تحرك الخلفية والمحتوى معاً
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              _buildBackgroundShapes(),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildProfileImagePicker(),
                      const SizedBox(height: 20),
                      const Text(
                        "إنشاء حساب",
                        style: AppTextStyles.headerStyle,
                      ),
                      const SizedBox(height: 30),
                      CustomTextField(
                        controller: _nameController,
                        hintText: "الاسم الكامل",
                        icon: Icons.person_outline,
                      ),
                      CustomTextField(
                        controller: _emailController,
                        hintText: "عنوان البريد الإلكتروني",
                        icon: Icons.email_outlined,
                      ),
                      CustomTextField(
                        controller: _passwordController,
                        hintText: "كلمة المرور",
                        icon: Icons.lock_outline,
                        isPassword: true,
                      ),
                      CustomTextField(
                        controller: _confirmPasswordController,
                        hintText: "تأكيد كلمة المرور",
                        icon: Icons.lock_reset_outlined,
                        isPassword: true,
                      ),
                      const SizedBox(height: 30),
                      _isLoading
                          ? const CircularProgressIndicator(
                              color: AppColors.creamBackground,
                            )
                          : CustomButton(
                              text: "إنشاء حساب",
                              onPressed: _handleRegister,
                            ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "لديك حساب بالفعل؟ تسجيل الدخول",
                          style: TextStyle(
                            color: AppColors.burgundy,
                            fontWeight: FontWeight.bold,
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
            backgroundColor: AppColors.pinkAccent.withOpacity(0.5),
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

  Widget _buildProfileImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: CircleAvatar(
              radius: 55,
              backgroundColor: Colors.white.withOpacity(0.3),
              backgroundImage: _pickedImage != null
                  ? FileImage(_pickedImage!)
                  : null,
              child: _pickedImage == null
                  ? const Icon(
                      Icons.person,
                      size: 60,
                      color: AppColors.burgundy,
                    )
                  : null,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 5,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.burgundy,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
