import 'package:flutter/material.dart';
import 'package:reading_app_front2/conset_app.dart';

// حقل نصي مخصص وموحد التصميم
// داخل ملف Custom Components.dart

class CustomTextField extends StatefulWidget {
  // حولناه لـ StatefulWidget
  final String hintText;
  final IconData icon;
  final bool isPassword;
  final TextEditingController? controller;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.icon,
    this.isPassword = false,
    this.controller,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText; // متغير محلي للتحكم في الرؤية

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword; // نبدأ بالإخفاء إذا كان الحقل كلمة سر
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: TextField(
          controller: widget.controller,
          obscureText: _obscureText, // نستخدم المتغير المحلي هنا
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: Icon(widget.icon, color: AppColors.burgundy),

            // إضافة أيقونة العين في نهاية الحقل إذا كان نوع الحقل كلمة سر
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText; // عكس الحالة عند الضغط
                      });
                    },
                  )
                : null,

            filled: true,
            fillColor: AppColors.textFieldFill,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }
}

// زر مخصص وموحد التصميم
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const CustomButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.burgundy,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(text, style: TextStyle(color: Colors.white, fontSize: 18)),
      ),
    );
  }
}
