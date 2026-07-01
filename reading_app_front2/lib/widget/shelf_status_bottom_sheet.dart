import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reading_app_front2/conset_app.dart';
import 'package:reading_app_front2/models/book.dart';
import 'package:reading_app_front2/provider/LibraryProvider.dart';
import 'package:reading_app_front2/provider/user_provider.dart';

void showShelfStatusBottomSheet(BuildContext context, Book currentBook) {
  final scaffoldMessenger = ScaffoldMessenger.of(context);

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
            children: [
              _BottomSheetOption(
                statusKey: 'want_to_read',
                label: 'أريد قراءته',
                icon: Icons.bookmark_add_outlined,
                currentBook: currentBook,
                scaffoldMessenger: scaffoldMessenger,
              ),
              _BottomSheetOption(
                statusKey: 'reading',
                label: 'أقرأه الآن',
                icon: Icons.auto_stories,
                currentBook: currentBook,
                scaffoldMessenger: scaffoldMessenger,
              ),
              _BottomSheetOption(
                statusKey: 'completed',
                label: 'تمت قراءته',
                icon: Icons.check_circle_outline,
                currentBook: currentBook,
                scaffoldMessenger: scaffoldMessenger,
              ),
              _BottomSheetOption(
                statusKey: 'none',
                label: 'إزالة من الرفوف',
                icon: Icons.delete_outline,
                currentBook: currentBook,
                isDelete: true,
                scaffoldMessenger: scaffoldMessenger,
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
  final ScaffoldMessengerState scaffoldMessenger;

  const _BottomSheetOption({
    required this.statusKey,
    required this.label,
    required this.icon,
    required this.currentBook,
    required this.scaffoldMessenger,
    this.isDelete = false,
  });

  @override
  Widget build(BuildContext context) {
    final libraryProvider = context.read<LibraryProvider>();
    final userProvider = context.read<UserProvider>();
    final currentStatus = context.watch<LibraryProvider>().getBookStatus(currentBook.id);
    final bool isSelected = currentStatus == statusKey;

    return ListTile(
      onTap: () async {
        if (userProvider.token == null || userProvider.token!.isEmpty) {
          Navigator.pop(context);
          _showCustomSnackBar(scaffoldMessenger, 'الرجاء تسجيل الدخول أولاً.');
          return;
        }

        Navigator.pop(context);

        bool success = false;
        String defaultSuccessMessage = isDelete ? 'تمت الإزالة بنجاح' : 'تمت العملية بنجاح';

        // تنفيذ العملية
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
              userProvider: userProvider,
            );
          } else {
            success = await libraryProvider.updateBookStatus(
              bookId: currentBook.id,
              status: statusKey,
              token: userProvider.token!,
            );
          }
        }

        if (success) {
          userProvider.setNotificationStatus(true);
        }

        // عرض الرسالة: نستخدم رسالة السيرفر إذا وُجدت، وإلا نستخدم الرسالة الافتراضية للنجاح
        String finalMessage = libraryProvider.message.isNotEmpty 
            ? libraryProvider.message 
            : (success ? defaultSuccessMessage : 'حدث خطأ غير متوقع');
            
        _showCustomSnackBar(scaffoldMessenger, finalMessage);
      },
      leading: Icon(
        icon,
        color: isSelected || isDelete ? AppColors.burgundy : Colors.grey,
      ),
      title: Text(label),
    );
  }

  void _showCustomSnackBar(ScaffoldMessengerState messenger, String text) {
    messenger.hideCurrentSnackBar();
    
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          text,
          style: const TextStyle(
            color: AppColors.burgundy,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.burgundy, width: 1),
        ),
      ),
    );
  }
}