import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reading_app_front2/conset_app.dart';
import 'package:reading_app_front2/models/book.dart';
// تأكدي من استيراد البروفايدر الجديد
import 'package:reading_app_front2/provider/books_provider.dart';
import 'package:reading_app_front2/provider/user_provider.dart';
import 'package:reading_app_front2/widget/book_action_buttons.dart';
import 'package:reading_app_front2/widget/book_description_section.dart';
import 'package:reading_app_front2/widget/book_details_header.dart';
import 'package:reading_app_front2/widget/book_suggestion_sheet.dart';
import 'package:reading_app_front2/widget/personal_rating_stars.dart';
import 'package:reading_app_front2/widget/shelf_status_bottom_sheet.dart';
import 'package:reading_app_front2/widget/suggested_books_list.dart';

class BookDetailPage extends StatefulWidget {
  static const String id = '/book-details';
  const BookDetailPage({super.key});

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  bool isDescriptionExpanded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final Book initialBook =
          ModalRoute.of(context)!.settings.arguments as Book;
      // استدعاء البيانات من البروفايدر مع تمرير التوكن
      _loadData(initialBook.id);
    });
  }

  Future<void> _loadData(int bookId) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final booksProvider = Provider.of<BooksProvider>(context, listen: false);

    // تمرير الـ token للبروفايدر ليقوم هو بدوره بتمريره للـ Service
    await booksProvider.fetchBookDetails(bookId, userProvider.token!);
  }

  void _switchToAnotherBook(Book newBook) {
    setState(() {
      isDescriptionExpanded = false;
    });
    _loadData(newBook.id);
  }

  @override
  Widget build(BuildContext context) {
    final Book initialBook = ModalRoute.of(context)!.settings.arguments as Book;

    // الاستماع للبروفايدر لجلب أحدث حالة
    return Consumer<BooksProvider>(
      builder: (context, booksProvider, child) {
        final currentBook = booksProvider.currentBookDetails ?? initialBook;
        final isLoading = booksProvider.isLoading;
        final errorMessage = booksProvider.errorMessage;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: AppColors.creamBackground,
            body: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      

                      NewBookDetailsHeader(currentBook: currentBook),
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BookActionButtons(
                              currentBook: currentBook,
                              onShowBottomSheet: () =>
                                  showShelfStatusBottomSheet(
                                    context,
                                    currentBook,
                                  ),
                              onShowSuggestionSheet: () =>
                                  showBookSuggestionBottomSheet(
                                    context,
                                    currentBook.id,
                                  ),
                            ),
                            const SizedBox(height: 24),
                            BookDescriptionSection(
                              isLoading: isLoading,
                              errorMessage: errorMessage ?? '',
                              description: currentBook.description,
                              isExpanded: isDescriptionExpanded,
                              onToggle: () => setState(
                                () => isDescriptionExpanded =
                                    !isDescriptionExpanded,
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'تقييمك الشخصي',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.burgundy,
                              ),
                            ),
                            PersonalRatingStars(currentBook: currentBook),
                            const SizedBox(height: 30),
                            const Text(
                              'قد يعجبك أيضاً',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.burgundy,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SuggestedBooksList(
                              suggestedBooks: booksProvider.similarBooks,
                              onBookSelected: _switchToAnotherBook,
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isLoading)
                  const Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(color: AppColors.burgundy),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
