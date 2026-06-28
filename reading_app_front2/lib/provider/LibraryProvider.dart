import 'package:flutter/material.dart';
import 'package:reading_app_front2/models/book.dart';
import 'package:reading_app_front2/services/library_service.dart';

class LibraryProvider with ChangeNotifier {
  final LibraryService _libraryService = LibraryService();
  
  final Map<int, String> _booksStatuses = {};
  final List<Book> _readingBooks = [];
  final List<Book> _wantToReadBooks = [];
  final List<Book> _completedBooks = [];

  String _message = '';
  bool _isLoading = false;

  String get message => _message;
  bool get isLoading => _isLoading;
  Map<int, String> get booksStatuses => _booksStatuses;
  List<Book> get readingBooks => _readingBooks;
  List<Book> get wantToReadBooks => _wantToReadBooks;
  List<Book> get completedBooks => _completedBooks;

  String getBookStatus(int bookId) => _booksStatuses[bookId] ?? 'none'; 

  // --- دالة تنظيف البيانات (يتم استدعاؤها عند تسجيل الخروج) ---
  void clearLibraryData() {
    _booksStatuses.clear();
    _readingBooks.clear();
    _wantToReadBooks.clear();
    _completedBooks.clear();
    _message = '';
    notifyListeners();
  }

  // 1. جلب المكتبة
  Future<void> fetchUserLibrary({required String token}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _libraryService.getAllLibraryBooks(token);
      if (response['success'] == true) {
        // تنظيف القوائم قبل إضافة البيانات الجديدة
        _booksStatuses.clear();
        _readingBooks.clear();
        _wantToReadBooks.clear();
        _completedBooks.clear();
        
        final Map<String, dynamic> data = response['data'] ?? {};
        
        _parseCategory(data['أقرأها الآن'], 'reading', _readingBooks);
        _parseCategory(data['أرغب بقراءتها'], 'want_to_read', _wantToReadBooks);
        _parseCategory(data['أنهيتها'], 'completed', _completedBooks);
      }
    } catch (e) {
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
          Book book = Book.fromJson(item['book']);
          targetList.add(book);
          _booksStatuses[book.id] = status;
        }
      }
    }
  }

  // 2. إضافة كتاب (POST)
  Future<bool> addBook({required int bookId, required String status, required String token}) async {
    _isLoading = true;
    notifyListeners();
    String serverStatus = _mapToBackendStatus(status);
    try {
      final response = await _libraryService.addBookToShelf(bookId, serverStatus, token);
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

  // 3. تحديث حالة كتاب (PATCH)
  Future<bool> updateBookStatus({
    required int bookId,
    required String status,
    required String token,
  }) async {
    _isLoading = true;
    notifyListeners();
    
    String serverStatus = _mapToBackendStatus(status);

    try {
      final response = await _libraryService.updateBookStatus(bookId, serverStatus, token);
      if (response['success'] == true) {
        _booksStatuses[bookId] = status;
        await fetchUserLibrary(token: token);
        return true;
      }
      _message = response['message'] ?? 'فشل التحديث';
      return false;
    } catch (e) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 4. حذف كتاب
  Future<bool> removeBook({required int bookId, required String token}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _libraryService.removeBookFromShelf(bookId, token);
      if (response['success'] == true) {
        _booksStatuses.remove(bookId);
        _readingBooks.removeWhere((b) => b.id == bookId);
        _wantToReadBooks.removeWhere((b) => b.id == bookId);
        _completedBooks.removeWhere((b) => b.id == bookId);
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