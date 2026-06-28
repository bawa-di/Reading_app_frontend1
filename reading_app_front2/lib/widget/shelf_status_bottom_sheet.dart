import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reading_app_front2/conset_app.dart';
import 'package:reading_app_front2/models/book.dart';
import 'package:reading_app_front2/provider/LibraryProvider.dart';
import 'package:reading_app_front2/provider/user_provider.dart';

void showShelfStatusBottomSheet(BuildContext context, Book currentBook) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.textFieldFill,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'نقل الكتاب إلى رف...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.burgundy,
                ),
              ),
              const SizedBox(height: 16),
              _BottomSheetOption(
                statusKey: 'reading',
                label: 'أقرأه الآن',
                icon: Icons.auto_stories,
                currentBook: currentBook,
              ),
              _BottomSheetOption(
                statusKey: 'want_to_read',
                label: 'أريد قراءته',
                icon: Icons.bookmark_add_outlined,
                currentBook: currentBook,
              ),
              _BottomSheetOption(
                statusKey: 'completed',
                label: 'تمت قراءته',
                icon: Icons.check_circle_outline,
                currentBook: currentBook,
              ),
              _BottomSheetOption(
                statusKey: 'none',
                label: 'إزالة من الرفوف',
                icon: Icons.delete_outline,
                currentBook: currentBook,
                isDelete: true,
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _BottomSheetOption extends StatelessWidget {
  final String statusKey, label;
  final IconData icon;
  final Book currentBook;
  final bool isDelete;

  const _BottomSheetOption({
    required this.statusKey,
    required this.label,
    required this.icon,
    required this.currentBook,
    this.isDelete = false,
  });

  @override
  Widget build(BuildContext context) {
    // نستخدم watch هنا فقط لحالة الكتاب الحالية لتحديث واجهة الخيارات
    final currentStatus = context.watch<LibraryProvider>().getBookStatus(
      currentBook.id,
    );
    final bool isSelected = currentStatus == statusKey;
    final color = isDelete
        ? AppColors.burgundy
        : (isSelected ? AppColors.burgundy : Colors.grey.shade600);

    return ListTile(
      onTap: () async {
        // نأخذ الـ Providers قبل الـ pop لتجنب مشاكل الـ context
        final libraryProvider = context.read<LibraryProvider>();
        final userProvider = context.read<UserProvider>();
        final scaffoldMessenger = ScaffoldMessenger.of(context);

        if (userProvider.token == null || userProvider.token!.isEmpty) {
          Navigator.pop(context);
          scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('الرجاء تسجيل الدخول أولاً.')),
          );
          return;
        }

        Navigator.pop(context); // إغلاق الـ BottomSheet أولاً

        bool success = false;
        if (isDelete) {
          success = await libraryProvider.removeBook(
            token: userProvider.token!,
            bookId: currentBook.id,
          );
        } else {
          if (currentStatus == 'none') {
            success = await libraryProvider.addBook(
              bookId: currentBook.id,
              status: statusKey,
              token: userProvider.token!,
            );
          } else {
            success = await libraryProvider.updateBookStatus(
              bookId: currentBook.id,
              status: statusKey,
              token: userProvider.token!,
            );
          }
        }

        // استخدام mounted للتأكد أن الشاشة لا تزال موجودة بعد عملية الـ await
        if (context.mounted && success) {
          // تفعيل النقطة الحمراء
          context.read<UserProvider>().setNotificationStatus(true);

          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(
                isDelete ? 'تمت الإزالة بنجاح' : 'تم تحديث الرف بنجاح.',
              ),
              backgroundColor: AppColors.burgundy,
            ),
          );
        }
      },
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isDelete
              ? AppColors.burgundy
              : (isSelected ? AppColors.burgundy : Colors.black87),
        ),
      ),
      trailing: isSelected && !isDelete
          ? const Icon(Icons.check_rounded, color: AppColors.burgundy, size: 20)
          : null,
    );
  }
}
