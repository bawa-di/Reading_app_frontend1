import 'package:flutter/material.dart';
import 'package:reading_app_front2/conset_app.dart';


class AnimatedBookIcon extends StatefulWidget {
  @override
  _AnimatedBookIconState createState() => _AnimatedBookIconState();
}

class _AnimatedBookIconState extends State<AnimatedBookIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // إعداد وحدة التحكم بالحركة
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true); // تجعل الحركة تذهب وتعود باستمرار

    // تحديد نوع الحركة (تغيير الحجم قليلاً)
    _animation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // ضروري جداً لتجنب استهلاك الذاكرة
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.menu_book_rounded, // أو أي أيقونة كتاب تفضلينها
          size: 80,
          color: AppColors.burgundy,
        ),
      ),
    );
  }
}