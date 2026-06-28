import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reading_app_front2/conset_app.dart';
import 'package:reading_app_front2/models/book.dart';
import 'package:reading_app_front2/provider/RatingProvider.dart';
import 'package:reading_app_front2/provider/user_provider.dart';

class PersonalRatingStars extends StatelessWidget {
  final Book currentBook;
  const PersonalRatingStars({super.key, required this.currentBook});

  @override
  Widget build(BuildContext context) {
    final ratingProvider = context.watch<RatingProvider>();
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return Row(
      children: List.generate(5, (index) {
        int starValue = index + 1;
        return GestureDetector(
          onTap: () async {
            if (userProvider.token == null || userProvider.token!.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء تسجيل الدخول')));
              return;
            }
            await ratingProvider.rateBook(context: context, currentBook: currentBook, stars: starValue, token: userProvider.token!);
            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ratingProvider.message)));
          },
          onLongPress: () => _showDeleteRatingDialog(context, ratingProvider, userProvider),
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Icon(
              starValue <= ratingProvider.userRating ? Icons.star_rounded : Icons.star_outline_rounded,
              color: Colors.amber, size: 34,
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
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('حذف التقييم', style: TextStyle(color: AppColors.burgundy, fontWeight: FontWeight.bold, fontSize: 18)),
          content: const Text('هل أنت متأكد من رغبتك في حذف تقييمك لهذا الكتاب؟', style: TextStyle(color: AppColors.burgundy, fontSize: 14.5, height: 1.4)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء', style: TextStyle(color: AppColors.burgundy, fontWeight: FontWeight.w600))),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('حذف', style: TextStyle(color: AppColors.burgundy, fontWeight: FontWeight.bold))),
          ],
        ),
      ),
    ) ?? false;

    if (confirmed && userProvider.token != null) {
      await ratingProvider.removeRating(context: context, currentBook: currentBook, token: userProvider.token!);
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ratingProvider.message)));
    }
  }
}