import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reading_app_front2/conset_app.dart';
import 'package:reading_app_front2/models/book.dart';
import 'package:reading_app_front2/provider/favorites_provider.dart';
import 'package:reading_app_front2/provider/books_provider.dart';

class BookCard extends StatelessWidget {
  final Book book;

  const BookCard({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    // 1. مراقبة الـ BooksProvider ليتم إعادة بناء البطاقة عند تحديث التقييم
    final booksProvider = context.watch<BooksProvider>();
    
    // 2. الحصول على النسخة المحدثة من الكتاب من داخل البروفايدر (لضمان الحصول على أحدث تقييم)
    final currentBook = booksProvider.books.firstWhere(
      (b) => b.id == book.id,
      orElse: () => book,
    );

    // قراءة حالة المفضلة
    final isFavorite = context.watch<FavoritesProvider>().isFavorite(currentBook);

    final String cleanImageUrl = currentBook.coverImagePath ?? '';

    // دالة فحص وتأمين الرابط
    String getSecureImageUrl(String rawUrl) {
      if (rawUrl.contains('localhost')) {
        return rawUrl.replaceAll('localhost', '10.0.2.2');
      } else if (rawUrl.contains('127.0.0.1')) {
        return rawUrl.replaceAll('127.0.0.1', '10.0.2.2');
      }
      return rawUrl;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.textFieldFill,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.pushNamed(context, '/book-details', arguments: currentBook);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: currentBook.id,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      getSecureImageUrl(cleanImageUrl),
                      width: 84,
                      height: 126,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 84,
                          height: 126,
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.menu_book_rounded, size: 36, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 126,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                currentBook.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.burgundy),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.read<FavoritesProvider>().toggleFavorite(currentBook),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isFavorite ? AppColors.burgundy : AppColors.pinkAccent.withOpacity(0.6),
                                ),
                                child: Icon(
                                  isFavorite ? Icons.favorite : Icons.favorite_border,
                                  size: 16,
                                  color: isFavorite ? Colors.white : AppColors.burgundy,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currentBook.author,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 6),
                        
                        // 🟢 أولاً: سطر التصنيفات (يمتد لوحده بشكل مريح)
                        SizedBox(
                          height: 24,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Row(
                              children: [
                                if (currentBook.geners == null || currentBook.geners!.isEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.pinkAccent.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      currentBook.category ?? 'عام',
                                      style: const TextStyle(color: AppColors.burgundy, fontSize: 10, fontWeight: FontWeight.w600),
                                    ),
                                  )
                                else
                                  ...currentBook.geners!.map((genre) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      margin: const EdgeInsets.only(left: 6),
                                      decoration: BoxDecoration(
                                        color: AppColors.pinkAccent.withOpacity(0.6),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppColors.burgundy.withOpacity(0.1),
                                          width: 0.5,
                                        ),
                                      ),
                                      child: Text(
                                        genre.name,
                                        style: const TextStyle(color: AppColors.burgundy, fontSize: 10, fontWeight: FontWeight.w600),
                                      ),
                                    );
                                  }).toList(),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 4),

                        // ✨ ثانياً: سطر التقييم المستقل (المتوسط الحسابي) تحت التصنيفات
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, color: Colors.orangeAccent, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              currentBook.rating > 0 ? currentBook.rating.toStringAsFixed(1) : "0.0",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87),
                            ),
                          ],
                        ),

                        const Spacer(),
                        Row(
                          children: [
                            Icon(Icons.menu_book_rounded, size: 16, color: Colors.grey.shade700),
                            const SizedBox(width: 6),
                            Text(
                              '${currentBook.pages ?? 0} صفحة',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/book-details', arguments: currentBook),
                icon: const Icon(Icons.menu_book_rounded, size: 16),
                label: const Text('عرض الكتاب'),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: AppColors.burgundy,
                  foregroundColor: AppColors.textFieldFill,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}