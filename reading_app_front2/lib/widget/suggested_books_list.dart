import 'package:flutter/material.dart';
import 'package:reading_app_front2/conset_app.dart';
import 'package:reading_app_front2/models/book.dart';

class SuggestedBooksList extends StatelessWidget {
  // ✨ نغير الاعتماد ليكون على قائمة كتب قادمة من السيرفر مباشرة
  final List<Book> suggestedBooks; 
  final Function(Book) onBookSelected;

  const SuggestedBooksList({
    super.key, 
    required this.suggestedBooks, // نمرر القائمة هنا
    required this.onBookSelected,
  });

  @override
  Widget build(BuildContext context) {
    // 🗑️ قمنا بحذف الفلترة المحلية القديمة لأن البيانات جاهزة الآن

    if (suggestedBooks.isEmpty) {
      return const Text('لا توجد كتب مقترحة مشابهة حالياً.');
    }

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: suggestedBooks.length,
        itemBuilder: (context, index) {
          final book = suggestedBooks[index];
          return GestureDetector(
            onTap: () => onBookSelected(book),
            child: Container(
              width: 110, 
              margin: const EdgeInsets.only(left: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1), 
                            blurRadius: 6, 
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: book.coverImagePath != null
                            ? Image.network(book.coverImagePath!, fit: BoxFit.cover, width: 110)
                            : Container(color: Colors.grey.shade300, child: const Icon(Icons.book)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    book.title, 
                    maxLines: 1, 
                    overflow: TextOverflow.ellipsis, 
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.burgundy),
                  ),
                  Text(
                    book.author, 
                    maxLines: 1, 
                    overflow: TextOverflow.ellipsis, 
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}