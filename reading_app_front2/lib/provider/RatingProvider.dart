import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reading_app_front2/models/book.dart';
import 'package:reading_app_front2/provider/books_provider.dart';
import 'package:reading_app_front2/services/RatingService.dart';

class RatingProvider with ChangeNotifier {
  final RatingService _ratingService = RatingService();

  double _bookAverageRating = 0.0;
  int _userRating = 0;
  bool _isLoading = false;
  String _message = '';

  double get bookAverageRating => _bookAverageRating;
  int get userRating => _userRating;
  bool get isLoading => _isLoading;
  String get message => _message;

  // جلب البيانات الأولية عند فتح الصفحة
  Future<void> loadBookRatingData({required int bookId, String? token}) async {
    _isLoading = true;
    notifyListeners();

    _bookAverageRating = await _ratingService.getAverageRating(bookId);
    
    if (token != null && token.isNotEmpty) {
      _userRating = await _ratingService.getUserRatingForBook(bookId, token);
    } else {
      _userRating = 0;
    }

    _isLoading = false;
    notifyListeners();
  }

  // إضافة أو تحديث التقييم مع الربط المباشر بـ BooksProvider والتعامل مع تأخير السيرفر
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
      
      // 🟢 حل مشكلة تأخير السيرفر:
      // ننتظر 1.2 ثانية ليعطي فرصة لقاعدة البيانات لتحديث الحسابات
      await Future.delayed(const Duration(milliseconds: 1200));
      
      double newAverage = await _ratingService.getAverageRating(currentBook.id);
      
      print("🔥 [DEBUG - RatingProvider] القيمة المستلمة بعد التأخير: $newAverage");
      
      if (context.mounted) {
        // إذا استمر السيرفر في إرسال 0.0، نجبر التطبيق على إعادة تحميل القائمة كاملة
        if (newAverage <= 0.0) {
          print("⚠️ [DEBUG] السيرفر لا يزال يرسل 0.0، جاري إعادة تحميل المكتبة كاملة...");
          await Provider.of<BooksProvider>(context, listen: false).fetchBooks();
        } else {
          // تحديث التقييم في القوائم (BookCard)
          Provider.of<BooksProvider>(context, listen: false)
              .updateBookRating(currentBook.id, newAverage);
        }
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  // حذف التقييم مع الربط المباشر بـ BooksProvider
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
      _message = 'تم حذف التقييم بنجاح';
      
      await Future.delayed(const Duration(milliseconds: 1200));
      double newAverage = await _ratingService.getAverageRating(currentBook.id);
      
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