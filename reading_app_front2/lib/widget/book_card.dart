import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reading_app_front2/conset_app.dart';
import 'package:reading_app_front2/models/book.dart';
import 'package:reading_app_front2/provider/favorites_provider.dart';
import 'package:reading_app_front2/provider/books_provider.dart';
import 'package:reading_app_front2/provider/LibraryProvider.dart';

class BookCard extends StatelessWidget {
  final Book book;
  const BookCard({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final booksProvider = context.watch<BooksProvider>();
    final libraryProvider = context.watch<LibraryProvider>();
    
    final currentBook = booksProvider.books.firstWhere(
      (b) => b.id == book.id,
      orElse: () => book,
    );

    final bool isPurchased = libraryProvider.isBookPurchased(currentBook.id) || 
                             (currentBook.hasPaid == true);
    
    final isFavorite = context.watch<FavoritesProvider>().isFavorite(currentBook);
    final String cleanImageUrl = currentBook.coverImagePath ?? '';

    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (currentBook.accessType) {
      case 'paid':
        statusColor = isPurchased ? Colors.green.shade700 : AppColors.burgundy;
        statusText = isPurchased ? 'تم شراؤه' : 'مدفوع';
        statusIcon = isPurchased ? Icons.check_circle : Icons.lock;
        break;
      case 'conditional':
        statusColor = AppColors.burgundy;
        statusText = 'مشروط (${currentBook.requiredBooksRead} كتب)';
        statusIcon = Icons.task_alt;
        break;
      default:
        statusColor = AppColors.burgundy;
        statusText = 'متاح مجاناً';
        statusIcon = Icons.lock_open;
    }

    String getSecureImageUrl(String rawUrl) {
      if (rawUrl.contains('localhost'))
        return rawUrl.replaceAll('localhost', '10.0.2.2');
      if (rawUrl.contains('127.0.0.1'))
        return rawUrl.replaceAll('127.0.0.1', '10.0.2.2');
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
        onTap: () => Navigator.pushNamed(
          context,
          '/book-details',
          arguments: currentBook,
        ),
        child: Column(
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
                      errorBuilder: (c, e, s) => Container(
                        width: 84,
                        height: 126,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.menu_book_rounded),
                      ),
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
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.burgundy,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context
                                  .read<FavoritesProvider>()
                                  .toggleFavorite(currentBook),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isFavorite
                                      ? AppColors.burgundy
                                      : AppColors.pinkAccent.withOpacity(0.6),
                                ),
                                child: Icon(
                                  isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  size: 16,
                                  color: isFavorite
                                      ? Colors.white
                                      : AppColors.burgundy,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          currentBook.author,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: (currentBook.geners ?? [])
                                .map(
                                  (g) => Container(
                                    margin: const EdgeInsets.only(left: 6),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.pinkAccent.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      g.name,
                                      style: const TextStyle(
                                        color: AppColors.burgundy,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Colors.orangeAccent,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              currentBook.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(statusIcon, size: 10, color: statusColor),
                              const SizedBox(width: 4),
                              Text(
                                statusText,
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/book-details',
                  arguments: currentBook,
                ),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: AppColors.burgundy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text("عرض الكتاب"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}