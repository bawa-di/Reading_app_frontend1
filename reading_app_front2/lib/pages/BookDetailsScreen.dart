import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reading_app_front2/conset_app.dart';
import 'package:reading_app_front2/models/book.dart';
import 'package:reading_app_front2/provider/LibraryProvider.dart';
import 'package:reading_app_front2/provider/RatingProvider.dart';
import 'package:reading_app_front2/provider/user_provider.dart';
import 'package:reading_app_front2/services/Bookserves.dart';
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
  bool isLoadingBook = true;
  String errorMessage = '';
  final BookService _bookService = BookService();
  Book? _detailedBook;
  
  // القائمة المسؤولة عن حفظ الكتب المشابهة
  List<Book> _similarBooks = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final Book initialBook = ModalRoute.of(context)!.settings.arguments as Book;
        final userProvider = Provider.of<UserProvider>(context, listen: false);

        if (_detailedBook == null) _detailedBook = initialBook;

        Provider.of<RatingProvider>(context, listen: false)
            .loadBookRatingData(bookId: initialBook.id, token: userProvider.token);
        _loadFullBookDetails(initialBook.id);
      }
    });
  }

  // 🟢 الدالة المصححة للوصول إلى الحقل المستهدف داخل 'data' بالتوافق مع كود لارافل
  Future<void> _loadFullBookDetails(int bookId) async {
    try {
      if (!mounted) return;
      setState(() {
        isLoadingBook = true;
        errorMessage = '';
      });

      // 1. جلب الـ Map الخام من السيرفر
      final rawData = await _bookService.getBookDetailsRaw(bookId);

      print('================= 🔍 فحص استجابة السيرفر لشاشة التفاصيل 🔍 =================');
      
      if (rawData != null && rawData['success'] == true && rawData['data'] != null) {
        // الوصول لكائن الـ data الداخلي لأن لارافل يضع كل شيء بداخله
        final bookData = rawData['data']; 
        
        print('📌 [DEBUG] نجح الاتصال. حقل البيانات الداخلي متوفر.');
        print('📚 [DEBUG] الكتب المشابهة المستخرجة: ${bookData['similar_books']}');

        if (!mounted) return;
        setState(() {
          // تفكيك الكائن الرئيسي للكتاب من الـ data مباشرة
          _detailedBook = Book.fromJson(bookData);
          
          // 2. تفكيك وفحص قائمة الكتب المشابهة (الآن من داخل bookData)
          if (bookData['similar_books'] != null) {
            final List<dynamic> similarList = bookData['similar_books'];
            _similarBooks = similarList.map((item) => Book.fromJson(item)).toList();
            
            print('✅ [DEBUG] تم تحويل وتخزين (${_similarBooks.length}) كتب مشابهة بنجاح.');
          } else {
            print('⚠️ [DEBUG] تنبيه: حقل similar_books غير موجود داخل data بالرد!');
            _similarBooks = [];
          }
          isLoadingBook = false;
        });
      } else {
        print('🛑 [DEBUG] فشل استخراج البيانات؛ الرد فارغ أو success تعيد false');
        if (!mounted) return;
        setState(() {
          errorMessage = 'تعذر استخراج تفاصيل الكتاب.';
          isLoadingBook = false;
          _similarBooks = [];
        });
      }
      print('========================================================================');
    } catch (e) {
      print('❌ [DEBUG] حدث خطأ أثناء معالجة تفاصيل الكتاب أو تفكيك الجيسون: $e');
      if (!mounted) return;
      setState(() {
        errorMessage = 'تعذر تحميل بيانات الكتاب الكاملة.';
        isLoadingBook = false;
        _similarBooks = []; 
      });
    }
  }

  void _switchToAnotherBook(Book newBook) {
    setState(() {
      _detailedBook = newBook;
      isDescriptionExpanded = false;
      _similarBooks = []; 
    });
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    Provider.of<RatingProvider>(context, listen: false)
        .loadBookRatingData(bookId: newBook.id, token: userProvider.token);
    _loadFullBookDetails(newBook.id);
  }

  @override
  Widget build(BuildContext context) {
    final Book initialBook = ModalRoute.of(context)!.settings.arguments as Book;
    final currentBook = _detailedBook ?? initialBook;

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
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BookActionButtons(
                          currentBook: currentBook,
                          onShowBottomSheet: () => showShelfStatusBottomSheet(context, currentBook),
                          onShowSuggestionSheet: () => showBookSuggestionBottomSheet(context, currentBook.id),
                        ),
                        const SizedBox(height: 24),
                        BookDescriptionSection(
                          isLoading: isLoadingBook,
                          errorMessage: errorMessage,
                          description: currentBook.description,
                          isExpanded: isDescriptionExpanded,
                          onToggle: () => setState(() => isDescriptionExpanded = !isDescriptionExpanded),
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          'تقييمك الشخصي (اضغط مطولاً للحذف)',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.burgundy),
                        ),
                        const SizedBox(height: 8),
                        PersonalRatingStars(currentBook: currentBook),
                        const SizedBox(height: 36),
                        const Text(
                          'قد يعجبك أيضاً',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.burgundy),
                        ),
                        const SizedBox(height: 16),
                        
                        // التمرير الآمن والمنظف للقائمة القادمة من الباكيند
                        SuggestedBooksList(
                          suggestedBooks: _similarBooks, 
                          onBookSelected: _switchToAnotherBook,
                        ),
                        
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0, left: 0, right: 0,
              child: Consumer2<LibraryProvider, RatingProvider>(
                builder: (context, lib, rate, child) {
                  return (lib.isLoading || rate.isLoading)
                      ? const LinearProgressIndicator(
                          color: AppColors.burgundy,
                          backgroundColor: Colors.transparent,
                        )
                      : const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}