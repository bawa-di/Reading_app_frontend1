import 'package:flutter/material.dart';
import 'package:reading_app_front2/models/book.dart';
import 'package:reading_app_front2/services/favorite_service.dart';

class FavoritesProvider extends ChangeNotifier {
  final FavoriteService _favoriteService = FavoriteService();
  
  // 1. قائمة الكتب المفضلة الكاملة لعرض تفاصيلها في الشاشة
  List<Book> _favoriteBooks = [];
  
  // 2. مجموعة الـ IDs للفحص السريع الفوري لشكل القلب (أحمر أم فارغ)
  final Set<int> _favoriteBookIds = {};
  
  bool _isLoading = false;

  // Getters للمتغيرات لحمايتها والوصول إليها من الشاشات
  List<Book> get favoriteBooks => _favoriteBooks;
  bool get isLoading => _isLoading;

  // الـ Constructor يستدعي جلب البيانات فور بناء البروفايدر عند إقلاع التطبيق
  FavoritesProvider() {
    loadFavoritesFromServer();
  }

  // دالة الفحص السريع بحسب الـ ID (تُستدعى في شاشة التفاصيل أو الكروت)
  bool isFavorite(Book book) {
    return _favoriteBookIds.contains(book.id);
  }

  // 🟢 جلب البيانات من السيرفر عند الإقلاع مع فحص تفصيلي للخطوات وكشف أين تختفي البيانات
  Future<void> loadFavoritesFromServer() async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('📢 [FavoritesProvider]: جاري محاولة جلب المفضلة من السيرفر بعد إعادة التشغيل...');
      
      // جلب الكائنات من السيرفس
      final List<Book> serverBooks = await _favoriteService.fetchFavorites();
      
      debugPrint('📢 [FavoritesProvider]: عدد الكتب المرجعة من السيرفر حالياً هو = ${serverBooks.length}');
      
      _favoriteBooks = serverBooks;
      
      _favoriteBookIds.clear();
      for (var book in serverBooks) {
        if (book.id != null) {
          _favoriteBookIds.add(book.id!);
          debugPrint('🟢 تم تثبيت الكتاب رقم (${book.id}) كمفضل محلياً في الـ Set');
        } else {
          debugPrint('⚠️ تحذير: تم استقبال كتاب من السيرفر ولكن الـ id الخاص به null!');
        }
      }
    } catch (e) {
      debugPrint('❌ [FavoritesProvider Error]: حدث خطأ أثناء معالجة بيانات المفضلة عند الإقلاع: $e');
    } finally {
      _isLoading = false;
      notifyListeners(); // تحديث فوري وشامل لجميع الواجهات لإعادة تلوين القلوب
    }
  }

  // 🟢 التابع المسؤول عن ضغطة زر القلب (إضافة / حذف فوري تفاعلي)
  Future<void> toggleFavorite(Book book) async {
    if (book.id == null) {
      debugPrint('❌ لا يمكن تعديل المفضلة لأن id الكتاب null');
      return;
    }

    final int bookId = book.id!;

    if (_favoriteBookIds.contains(bookId)) {
      // [حالة إلغاء المفضلة]:
      // أولاً: الحذف المحلي الفوري لسرعة استجابة الواجهة أمام المستخدم
      _favoriteBookIds.remove(bookId);
      _favoriteBooks.removeWhere((item) => item.id == bookId);
      notifyListeners();
      debugPrint('🗑️ تم الحذف محلياً، جاري الإرسال للسيرفر لحذفه نهائياً...');

      // ثانياً: إرسال طلب الحذف الحقيقي للباك إند (لارافيل)
      bool success = await _favoriteService.removeFromFavorites(bookId);
      
      // إذا فشل الطلب في السيرفر، نتراجع ونعيد الكتاب حماية للبيانات
      if (!success) {
        debugPrint('❌ فشل الحذف في السيرفر، يتم التراجع وإعادة الكتاب للمفضلة...');
        _favoriteBookIds.add(bookId);
        _favoriteBooks.add(book);
        notifyListeners();
      } else {
        debugPrint('✅ تم الحذف من السيرفر بنجاح');
      }
    } else {
      // [حالة إضافة كتاب جديد للمفضلة]:
      // أولاً: الإضافة المحلية الفورية ليتغير القلب للأحمر فوراً
      _favoriteBookIds.add(bookId);
      _favoriteBooks.add(book);
      notifyListeners();
      debugPrint('❤️ تمت الإضافة محلياً، جاري الإرسال للتثبيت في السيرفر...');

      // ثانياً: إرسال طلب التثبيت بقاعدة البيانات لارافيل
      bool success = await _favoriteService.addToFavorites(bookId);
      
      // إذا حدث خطأ (مثلاً لا يوجد إنترنت أو توكن منتهي)، نتراجع ونحذف الكتاب محلياً
      if (!success) {
        debugPrint('❌ فشلت الإضافة في السيرفر، يتم التراجع وحذف الكتاب من المفضلة...');
        _favoriteBookIds.remove(bookId);
        _favoriteBooks.removeWhere((item) => item.id == bookId);
        notifyListeners();
      } else {
        debugPrint('✅ تمت الإضافة في السيرفر بنجاح');
      }
    }
  }
}