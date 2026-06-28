import 'package:flutter/material.dart';
import 'package:reading_app_front2/services/Bookserves.dart';
import '../models/book.dart';

class BooksProvider with ChangeNotifier {
  // استدعاء الـ Service للتعامل مع البيانات
  final BookService _bookService = BookService();

  List<Book> _books = [];
  bool _isLoading = false;
  String? _errorMessage;

  // ✨ حقول جديدة لتخزين بيانات صفحة تفاصيل الكتاب الحالية والكتب المشابهة
  Book? _currentBookDetails;
  List<Book> _similarBooks = [];

  // Getters لتأمين البيانات ومنع تعديلها من خارج البروفايدر
  List<Book> get books => _books;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // ✨ Getters للحقول الجديدة
  Book? get currentBookDetails => _currentBookDetails;
  List<Book> get similarBooks => _similarBooks;

  /// ميثود جلب كل الكتب وتنبيه الواجهات
  Future<void> fetchBooks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _books = await _bookService.getAllBooks();
      print(
        "🔥 [DEBUG - BooksProvider] تم جلب عدد ${_books.length} كتاب من السيرفر.",
      );
    } catch (error) {
      _errorMessage = 'حدث خطأ أثناء تحميل المكتبة، يرجى المحاولة لاحقاً';
      debugPrint('خطأ في البروفايدر (fetchBooks): $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ✨ ميثود جديدة ومحورية لجلب تفاصيل الكتاب والكتب المشابهة معاً من السيرفر
  Future<void> fetchBookDetails(int bookId) async {
    _isLoading = true;
    _errorMessage = null;
    _currentBookDetails = null; // تصفير الكتاب السابق لضمان نظافة البيانات بالواجهة
    _similarBooks = [];        // تصفير القائمة السابقة
    notifyListeners();

    try {
      // استدعاء الدالة الـ Raw التي ترجع الماب كاملة
      final response = await _bookService.getBookDetailsRaw(bookId);

      if (response != null && response['success'] == true && response['data'] != null) {
        final Map<String, dynamic> data = response['data'];

        // 1. تحويل الـ Object الخاص بالكتاب الرئيسي
        _currentBookDetails = Book.fromJson(data);

        // 2. تحويل قائمة الكتب المشابهة بشكل آمن وبالموديل المحدث
        if (data['similar_books'] != null) {
          final List<dynamic> similarList = data['similar_books'];
          _similarBooks = similarList.map((item) => Book.fromJson(item)).toList();
        }

        print("🔥 [DEBUG - BooksProvider] تم جلب تفاصيل الكتاب بنجاح مع عدد ${_similarBooks.length} كتب مشابهة.");
      } else {
        _errorMessage = 'فشل جلب تفاصيل الكتاب من السيرفر';
      }
    } catch (error) {
      _errorMessage = 'حدث خطأ أثناء تحميل تفاصيل الكتاب';
      debugPrint('🛑 [خطأ في الـ Provider أثناء جلب التفاصيل والكتب المشابهة]: $error');
    } finally {
      _isLoading = false;
      notifyListeners(); // تنبيه صفحة تفاصيل الكتاب لتعرض الغلاف، الوصف، والكتب المشابهة فوراً
    }
  }

  /// ميثود البحث الذكية والموحدة
  Future<void> searchBooks({required String queryText}) async {
    if (queryText.trim().isEmpty) {
      await fetchBooks();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final List<Book> searchResults = await _bookService.searchBooksFromServer(
        queryText,
      );
      _books = searchResults;
      print(
        "🔥 [DEBUG - BooksProvider] نتائج البحث: ${searchResults.length} كتاب.",
      );
    } catch (error, stackTrace) {
      _errorMessage = 'حدث خطأ أثناء البحث، يرجى المحاولة لاحقاً';
      debugPrint('🛑 [خطأ في الـ Provider أثناء البحث]: $error');
      _books = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 🟢 الميثود المسؤولة عن تحديث التقييم في الذاكرة فوراً وإشعار الواجهات
  void updateBookRating(int bookId, double newRating) {
    print(
      "🔥 [DEBUG 2 - BooksProvider] محاولة تحديث الكتاب ID: $bookId بالقيمة الجديدة: $newRating",
    );

    // تحديث في القائمة العامة للكتب
    final index = _books.indexWhere((b) => b.id == bookId);
    if (index != -1) {
      _books[index].rating = newRating;
      print("🔥 [DEBUG 2] تم تحديث الكتاب في قائمة الكتب العامة.");
    }

    // ✨ تحسين برمي ذكي: تحديث التقييم داخل كتاب التفاصيل الحالي أيضاً إذا كان مفتوحاً
    if (_currentBookDetails != null && _currentBookDetails!.id == bookId) {
      _currentBookDetails!.rating = newRating;
      print("🔥 [DEBUG 2] تم تحديث التقييم داخل صفحة التفاصيل الحالية أيضاً حياً.");
    }

    notifyListeners();
    print("🔥 [DEBUG 2] تم استدعاء notifyListeners() بنجاح.");
  }
}