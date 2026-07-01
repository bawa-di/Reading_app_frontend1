import 'package:flutter/material.dart';
import 'package:reading_app_front2/services/Bookserves.dart';
import '../models/book.dart';

class BooksProvider with ChangeNotifier {
  final BookService _bookService = BookService();

  List<Book> _books = [];
  bool _isLoading = false;
  String? _errorMessage;

  Book? _currentBookDetails;
  List<Book> _similarBooks = [];

  List<Book> get books => _books;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Book? get currentBookDetails => _currentBookDetails;
  List<Book> get similarBooks => _similarBooks;

  // جلب الكتب كما تأتي من السيرفر مباشرة
  Future<void> fetchBooks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _books = await _bookService.getAllBooks();
    } catch (error) {
      _errorMessage = 'حدث خطأ أثناء تحميل الكتب';
      debugPrint('خطأ (fetchBooks): $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // تم تحديث هذه الدالة لتكتفي بتحديث الواجهة فقط دون الحفظ في SharedPreferences
  void markBookAsPaid(int bookId) {
    final index = _books.indexWhere((b) => b.id == bookId);
    if (index != -1) {
      _books[index] = _books[index].copyWith(hasPaid: true);
      notifyListeners();
    }
  }

  // جلب تفاصيل كتاب واحد
  Future<void> fetchBookDetails(int bookId, String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _bookService.getBookDetailsRaw(bookId, token);
      if (response != null && response['success'] == true && response['data'] != null) {
        final Map<String, dynamic> data = response['data'];
        
        _currentBookDetails = Book.fromJson(data);

        if (data['similar_books'] != null) {
          final List<dynamic> similarList = data['similar_books'];
          _similarBooks = similarList.map((item) => Book.fromJson(item)).toList();
        }
      }
    } catch (error) {
      _errorMessage = 'حدث خطأ أثناء تحميل التفاصيل';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchBooks({String title = '', String author = '', String gener = '', String accessType = ''}) async {
    _isLoading = true;
    notifyListeners();
    try {
      Map<String, String> filters = {'title': title, 'author': author, 'gener': gener, 'access_type': accessType};
      _books = await _bookService.searchBooksFromServer(filters);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateBookRating(int bookId, double newRating) {
    final index = _books.indexWhere((b) => b.id == bookId);
    if (index != -1) {
       _books[index].rating = newRating;
       notifyListeners();
    }
  }
}