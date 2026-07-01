import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reading_app_front2/conset_app.dart';
import 'package:reading_app_front2/models/book.dart';
import 'package:reading_app_front2/pages/BookCommentsPage.dart';
import 'package:reading_app_front2/provider/RatingProvider.dart';
import 'package:reading_app_front2/provider/favorites_provider.dart';

class NewBookDetailsHeader extends StatelessWidget {
  final Book currentBook;
  const NewBookDetailsHeader({super.key, required this.currentBook});

  Widget _buildInfoBadge(Widget child) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: AppColors.textFieldFill.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.textFieldFill.withOpacity(0.25),
          width: 0.8,
        ),
      ),
      child: child,
    );
  }

  // ✨ إضافة دالة لبناء شارة نوع الوصول
  Widget _buildAccessBadge() {
    String label = '';
    Color color = AppColors.textFieldFill.withOpacity(0.2);

    switch (currentBook.accessType) {
      case 'free':
        label = 'مجاني';
        color = Colors.green.shade700;
        break;
      case 'paid':
        label = 'مدفوع';
        color = AppColors.pinkAccent;
        break;
      case 'conditional':
        label = 'مشروط';
        color = Colors.blue.shade700;
        break;
      default:
        label = 'عام';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFavorite = context.watch<FavoritesProvider>().isFavorite(
      currentBook,
    );
    final ratingProvider = context.watch<RatingProvider>();
    final double displayRating = ratingProvider.bookAverageRating > 0
        ? ratingProvider.bookAverageRating
        : currentBook.rating;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 310,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: AppColors.burgundy,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (currentBook.coverImagePath != null)
                  Image.network(currentBook.coverImagePath!, fit: BoxFit.cover),
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                  child: Container(color: Colors.black.withOpacity(0.1)),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.burgundy.withOpacity(0.3),
                        AppColors.burgundy.withOpacity(0.95),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 45,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.textFieldFill,
                  size: 22,
                ),
              ),
              IconButton(
                onPressed: () => context
                    .read<FavoritesProvider>()
                    .toggleFavorite(currentBook),
                icon: Icon(
                  isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: AppColors.pinkAccent,
                  size: 26,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 95,
          right: 24,
          left: 24,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBookCover(),
              const SizedBox(width: 18),
              Expanded(
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
                            style: const TextStyle(
                              color: AppColors.textFieldFill,
                              fontSize: 18.5,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildAccessBadge(), // الشارة الجديدة
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildInfoBadge(
                      Text(
                        currentBook.author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textFieldFill,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (currentBook.category != null &&
                        currentBook.category!.isNotEmpty)
                      _buildInfoBadge(
                        Text(
                          currentBook.category!,
                          style: const TextStyle(
                            color: AppColors.textFieldFill,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    _buildInfoBadge(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.auto_stories_outlined,
                            color: AppColors.textFieldFill.withOpacity(0.8),
                            size: 13,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${currentBook.pages ?? 0} صفحة',
                            style: const TextStyle(
                              color: AppColors.textFieldFill,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildInfoBadge(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            displayRating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: AppColors.textFieldFill,
                              fontWeight: FontWeight.bold,
                              fontSize: 11.5,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '/ 5.0',
                            style: TextStyle(
                              color: AppColors.textFieldFill.withOpacity(0.6),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: -24,
          left: 32,
          child: FloatingActionButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookCommentsPage(bookId: currentBook.id),
              ),
            ),
            backgroundColor: AppColors.textFieldFill,
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              Icons.mode_comment_outlined,
              color: AppColors.burgundy,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBookCover() {
    return Container(
      width: 115,
      height: 175,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: currentBook.coverImagePath != null
            ? Image.network(currentBook.coverImagePath!, fit: BoxFit.cover)
            : Container(
                color: Colors.grey.shade300,
                child: const Icon(Icons.book, size: 40),
              ),
      ),
    );
  }
}
