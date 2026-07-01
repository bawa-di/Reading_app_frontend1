import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reading_app_front2/models/book.dart';
import 'package:reading_app_front2/provider/books_provider.dart';
import 'package:reading_app_front2/services/RatingService.dart';

class RatingProvider with ChangeNotifier {
  final RatingService _ratingService = RatingService();

  // المتغيرات القديمة (لن نحذفها لكي لا يظهر خطأ في باقي التطبيق)
  double _bookAverageRating = 0.0;
  int _userRating = 0;
  bool _isLoading = false;
  String _message = '';

  // التعديل: إضافة Map لعزل تقييم كل كتاب
  final Map<int, int> _userRatingsMap = {};

  double get bookAverageRating => _bookAverageRating;
  int get userRating => _userRating; // سيظل يعمل كما كان
  bool get isLoading => _isLoading;
  String get message => _message;

  // دالة جديدة لجلب تقييم الكتاب المخصص (استخدميها في الـ UI)
  int getRatingForBook(int bookId) {
    return _userRatingsMap[bookId] ?? 0;
  }

  // جلب البيانات الأولية عند فتح الصفحة
  Future<void> loadBookRatingData({required int bookId, String? token}) async {
    _isLoading = true;
    notifyListeners();

    _bookAverageRating = await _ratingService.getAverageRating(bookId);
    
    if (token != null && token.isNotEmpty) {
      _userRating = await _ratingService.getUserRatingForBook(bookId, token);
      _userRatingsMap[bookId] = _userRating; // تحديث الـ Map أيضاً
    } else {
      _userRating = 0;
    }

    _isLoading = false;
    notifyListeners();
  }

  // إضافة أو تحديث التقييم
  Future<void> rateBook({
    required BuildContext context, 
    required Book currentBook, 
    required int stars, 
    required String token
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await _ratingService.submitRating(currentBook.id, stars, token);
    _message = result['message'];
    
    if (result['success'] == true) {
      _userRating = stars;
      _userRatingsMap[currentBook.id] = stars; // تحديث الـ Map للكتاب
      
      await Future.delayed(const Duration(milliseconds: 1200));
      double newAverage = await _ratingService.getAverageRating(currentBook.id);
      _bookAverageRating = newAverage; // تحديث المتغير القديم
      
      print("🔥 [DEBUG - RatingProvider] القيمة المستلمة بعد التأخير: $newAverage");
      
      if (context.mounted) {
        if (newAverage <= 0.0) {
          await Provider.of<BooksProvider>(context, listen: false).fetchBooks();
        } else {
          Provider.of<BooksProvider>(context, listen: false)
              .updateBookRating(currentBook.id, newAverage);
        }
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  // حذف التقييم
  Future<void> removeRating({
    required BuildContext context, 
    required Book currentBook, 
    required String token
  }) async {
    _isLoading = true;
    notifyListeners();

    final success = await _ratingService.deleteRating(currentBook.id, token);
    if (success) {
      _userRating = 0;
      _userRatingsMap[currentBook.id] = 0; // تحديث الـ Map للكتاب
      _message = 'تم حذف التقييم بنجاح';
      
      await Future.delayed(const Duration(milliseconds: 1200));
      double newAverage = await _ratingService.getAverageRating(currentBook.id);
      _bookAverageRating = newAverage;
      
      if (context.mounted) {
        if (newAverage <= 0.0) {
          Provider.of<BooksProvider>(context, listen: false).fetchBooks();
        } else {
          Provider.of<BooksProvider>(context, listen: false)
              .updateBookRating(currentBook.id, newAverage);
        }
      }
    }

    _isLoading = false;
    notifyListeners();
  }
}