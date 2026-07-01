import 'package:flutter/material.dart';
import 'package:reading_app_front2/models/book.dart';
import 'package:reading_app_front2/services/library_service.dart';
import 'package:reading_app_front2/provider/user_provider.dart';

class LibraryProvider with ChangeNotifier {
  final LibraryService _libraryService = LibraryService();

  final Map<int, String> _booksStatuses = {};
  final List<Book> _readingBooks = [];
  final List<Book> _wantToReadBooks = [];
  final List<Book> _completedBooks = [];
  
  final Set<int> _purchasedBookIds = {};

  String _message = '';
  bool _isLoading = false;

  String get message => _message;
  bool get isLoading => _isLoading;
  Map<int, String> get booksStatuses => _booksStatuses;
  List<Book> get readingBooks => _readingBooks;
  List<Book> get wantToReadBooks => _wantToReadBooks;
  List<Book> get completedBooks => _completedBooks;
  int get completedBooksCount => _completedBooks.length;
  Set<int> get purchasedBookIds => _purchasedBookIds;

  bool isBookPurchased(int bookId) => _purchasedBookIds.contains(bookId);

  void markBookAsPurchased(int bookId) {
    print("--- [LibraryProvider] تحديث الحالة محلياً للكتاب ID: $bookId ---");
    if (!_purchasedBookIds.contains(bookId)) {
      _purchasedBookIds.add(bookId);
      notifyListeners();
    }
  }

  String getBookStatus(int bookId) => _booksStatuses[bookId] ?? 'none';

  void clearLibraryData() {
    print("--- [LibraryProvider] مسح بيانات المكتبة ---");
    _booksStatuses.clear();
    _readingBooks.clear();
    _wantToReadBooks.clear();
    _completedBooks.clear();
    _purchasedBookIds.clear();
    _message = '';
    notifyListeners();
  }

  Future<void> fetchUserLibrary({required String token}) async {
    print("--- [LibraryProvider] بدأ طلب جلب المكتبة من السيرفر ---");
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _libraryService.getAllLibraryBooks(token);
      
      // طباعة الـ Response الخام للتأكد من بيانات السيرفر
      print("--- [LibraryProvider] استلام استجابة السيرفر: $response ---");

      if (response['success'] == true) {
        _booksStatuses.clear();
        _readingBooks.clear();
        _wantToReadBooks.clear();
        _completedBooks.clear();
        
        final Map<String, dynamic> data = response['data'] ?? {};
        _parseCategory(data['أقرأها الآن'], 'reading', _readingBooks);
        _parseCategory(data['أرغب بقراءتها'], 'want_to_read', _wantToReadBooks);
        _parseCategory(data['أنهيتها'], 'completed', _completedBooks);
        
        print("--- [LibraryProvider] انتهاء المعالجة، عدد المشتريات الحالي: ${_purchasedBookIds.length} ---");
      } else {
        print("--- [LibraryProvider] فشل في جلب البيانات: ${response['message']} ---");
      }
    } catch (e) {
      print("--- [LibraryProvider] خطأ في جلب المكتبة: $e ---");
      _message = 'حدث خطأ أثناء جلب المكتبة.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _parseCategory(dynamic list, String status, List<Book> targetList) {
    if (list is List) {
      for (var item in list) {
        if (item['book'] != null) {
          // طباعة حالة الكتاب كما وردت في الـ JSON الخام قبل التحويل
          print("--- [LibraryProvider] معالجة كتاب ID: ${item['book']['id']}, has_paid من السيرفر: ${item['book']['has_paid']} ---");
          
          Book book = Book.fromJson(item['book']);
          
          if (book.hasPaid || _purchasedBookIds.contains(book.id)) {
             print("--- [LibraryProvider] الكتاب ${book.id} تم اعتباره مدفوعاً ---");
             book = book.copyWith(hasPaid: true);
             _purchasedBookIds.add(book.id);
          }
          
          targetList.add(book);
          _booksStatuses[book.id] = status;
        }
      }
    }
  }

  Future<bool> addBook({required int bookId, required String status, required String token, required UserProvider userProvider}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _libraryService.addBookToShelf(bookId, _mapToBackendStatus(status), token);
      if (response['success'] == true) {
        await fetchUserLibrary(token: token);
        return true;
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateBookStatus({required int bookId, required String status, required String token}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _libraryService.updateBookStatus(bookId, _mapToBackendStatus(status), token);
      if (response['success'] == true) {
        await fetchUserLibrary(token: token);
        return true;
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> removeBook({required int bookId, required String token}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _libraryService.removeBookFromShelf(bookId, token);
      if (response['success'] == true) {
        await fetchUserLibrary(token: token);
        return true;
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _mapToBackendStatus(String status) {
    if (status == 'reading') return 'أقرأها الآن';
    if (status == 'completed') return 'أنهيتها';
    return 'أرغب بقراءتها';
  }
}