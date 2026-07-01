import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reading_app_front2/conset_app.dart';
import 'package:reading_app_front2/models/book.dart';
import 'package:reading_app_front2/provider/RatingProvider.dart';
import 'package:reading_app_front2/provider/user_provider.dart';

class PersonalRatingStars extends StatelessWidget {
  final Book currentBook;
  const PersonalRatingStars({super.key, required this.currentBook});

  // دالة الـ SnackBar بتصميم البرغندي والأبيض
  void _showCustomSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        backgroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(color: AppColors.burgundy, width: 2.0),
        ),
        content: Text(
          message,
          textAlign: TextAlign.right,
          style: const TextStyle(
            color: AppColors.burgundy,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ratingProvider = context.watch<RatingProvider>();
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // الحصول على تقييم هذا الكتاب تحديداً من الـ Provider
    int currentUserRatingForThisBook = ratingProvider.getRatingForBook(currentBook.id);

    return Row(
      children: List.generate(5, (index) {
        int starValue = index + 1;
        return GestureDetector(
          onTap: () async {
            if (userProvider.token == null || userProvider.token!.isEmpty) {
              _showCustomSnackBar(context, 'الرجاء تسجيل الدخول أولاً');
              return;
            }
            
            await ratingProvider.rateBook(
                context: context, 
                currentBook: currentBook, 
                stars: starValue, 
                token: userProvider.token!
            );
            
            if (context.mounted) {
              _showCustomSnackBar(context, ratingProvider.message);
            }
          },
          onLongPress: () => _showDeleteRatingDialog(context, ratingProvider, userProvider),
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Icon(
              // استخدام القيمة المخصصة لهذا الكتاب فقط
              starValue <= currentUserRatingForThisBook ? Icons.star_rounded : Icons.star_outline_rounded,
              color: Colors.amber, 
              size: 34,
            ),
          ),
        );
      }),
    );
  }

  void _showDeleteRatingDialog(BuildContext context, RatingProvider ratingProvider, UserProvider userProvider) async {
    bool confirmed = await showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.creamBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: const Text('حذف التقييم', style: TextStyle(color: AppColors.burgundy, fontWeight: FontWeight.bold, fontSize: 18)),
          content: const Text('هل أنت متأكد من رغبتك في حذف تقييمك لهذا الكتاب؟', style: TextStyle(color: AppColors.burgundy, fontSize: 14.5, height: 1.4)),
          actions: [
            // زر الإلغاء بإطار برغندي
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              style: TextButton.styleFrom(
                side: const BorderSide(color: AppColors.burgundy),
              ),
              child: const Text('إلغاء', style: TextStyle(color: AppColors.burgundy, fontWeight: FontWeight.w600)),
            ),
            // زر الحذف بخلفية برغندية ونص كريمي
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.burgundy,
                foregroundColor: AppColors.textFieldFill, 
              ),
              child: const Text('حذف', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    ) ?? false;

    if (confirmed && userProvider.token != null) {
      await ratingProvider.removeRating(context: context, currentBook: currentBook, token: userProvider.token!);
      if (context.mounted) {
        _showCustomSnackBar(context, ratingProvider.message);
      }
    }
  }
}