import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reading_app_front2/conset_app.dart';
import 'package:reading_app_front2/models/book.dart';
import 'package:reading_app_front2/pages/PaymentScreen.dart';
import 'package:reading_app_front2/pages/book_pdf_viewer_page.dart';
import 'package:reading_app_front2/provider/LibraryProvider.dart';

class BookActionButtons extends StatelessWidget {
  final Book currentBook;
  final VoidCallback onShowBottomSheet;
  final VoidCallback onShowSuggestionSheet;

  const BookActionButtons({
    super.key,
    required this.currentBook,
    required this.onShowBottomSheet,
    required this.onShowSuggestionSheet,
  });

  @override
  Widget build(BuildContext context) {
    final libraryProvider = context.watch<LibraryProvider>();
    String currentReadingStatus = libraryProvider.getBookStatus(currentBook.id);
    Map<String, dynamic> statusData = _getStatusButtonData(currentReadingStatus);

    // التحقق من حالة القفل
    bool isPurchased = libraryProvider.isBookPurchased(currentBook.id) || 
                       (currentBook.hasPaid == true);
    
    bool isLocked = false;
    if (currentBook.accessType == 'paid') {
      isLocked = !isPurchased;
    } else if (currentBook.accessType == 'conditional') {
      isLocked = (libraryProvider.completedBooksCount < (currentBook.requiredBooksRead ?? 0));
    }

    return Column(
      children: [
        // زر القراءة الرئيسي أو الدفع
        _buildActionButton(
          onPressed: () {
            if (currentBook.accessType == 'paid' && isLocked) {
              // الانتقال لصفحة الدفع
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PaymentScreen(book: currentBook),
                ),
              );
            } else if (isLocked) {
              // رسالة القفل للحالات المشروطة
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(currentBook.lockMessage ?? 'عذراً، هذا الكتاب مقفل حالياً.'),
                  backgroundColor: AppColors.burgundy,
                ),
              );
            } else {
              // فتح الكتاب
              if (currentBook.pdfPath != null && currentBook.pdfPath!.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookPdfViewerPage(
                      pdfUrl: currentBook.pdfPath!,
                      bookTitle: currentBook.title,
                    ),
                  ),
                );
              }
            }
          },
          icon: Icon(
            isLocked ? (currentBook.accessType == 'paid' ? Icons.payment : Icons.lock_outline) : Icons.play_arrow_rounded,
            size: 22,
          ),
          label: Text(
            isLocked 
                ? (currentBook.accessType == 'paid' ? 'ادفع لفتح الكتاب' : 'الكتاب مقفل') 
                : 'ابدأ قراءة الكتاب الآن',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: isLocked ? AppColors.burgundy.withOpacity(0.8) : AppColors.burgundy,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          isElevated: true,
        ),

        // رسالة القفل الإضافية
        if (isLocked && currentBook.lockMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              currentBook.lockMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.burgundy,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

        const SizedBox(height: 10),

        // زر حالة الرفوف
        _buildActionButton(
          onPressed: onShowBottomSheet,
          icon: Icon(statusData['icon'], size: 18),
          label: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                statusData['label'],
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const Icon(Icons.arrow_drop_down, size: 18),
            ],
          ),
          style: OutlinedButton.styleFrom(
            backgroundColor: AppColors.textFieldFill,
            foregroundColor: AppColors.burgundy,
            side: BorderSide(color: Colors.grey.shade300),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          isElevated: false,
        ),

        const SizedBox(height: 10),

        // زر الاقتراحات للمدير
        _buildActionButton(
          onPressed: onShowSuggestionSheet,
          icon: const Icon(Icons.lightbulb_outline_rounded, size: 18),
          label: const Align(
            alignment: Alignment.centerRight,
            child: Text(
              'اقتراح كتاب مشابه للمدير',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          style: OutlinedButton.styleFrom(
            backgroundColor: AppColors.creamBackground,
            foregroundColor: AppColors.burgundy,
            side: const BorderSide(color: AppColors.burgundy, width: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          isElevated: false,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required Widget icon,
    required Widget label,
    required ButtonStyle style,
    required bool isElevated,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 42,
      child: isElevated
          ? ElevatedButton.icon(
              onPressed: onPressed,
              icon: icon,
              label: label,
              style: style,
            )
          : OutlinedButton.icon(
              onPressed: onPressed,
              icon: icon,
              label: label,
              style: style,
            ),
    );
  }

  Map<String, dynamic> _getStatusButtonData(String readingStatus) {
    switch (readingStatus) {
      case 'reading':
        return {'label': 'أقرأه الآن', 'icon': Icons.auto_stories};
      case 'want_to_read':
        return {'label': 'أريد قراءته', 'icon': Icons.bookmark_add};
      case 'completed':
        return {'label': 'تمت قراءته', 'icon': Icons.check_circle};
      default:
        return {
          'label': 'إضافة إلى رفوف القراءة',
          'icon': Icons.library_add_outlined,
        };
    }
  }
}