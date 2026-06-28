import 'package:flutter/material.dart';
import 'package:reading_app_front2/services/suggestion_service.dart';

class SuggestionProvider with ChangeNotifier {
  final SuggestionService _suggestionService = SuggestionService();
  
  // ⏳ حالة التحميل الخاصة بـ (إرسال اقتراح جديد)
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // ⏳ حالة التحميل الخاصة بـ (جلب وعرض الاقتراحات الحالية)
  bool _isFetching = false;
  bool get isFetching => _isFetching;

  // 📚 القائمة التي ستخزن الاقتراحات القادمة من الباك إند
  List<dynamic> _userSuggestions = [];
  List<dynamic> get userSuggestions => _userSuggestions;

  // 1️⃣ دالة إرسال اقتراح جديد (موجودة لديكِ وصحيحة)
  Future<Map<String, dynamic>> sendBookSuggestion({
    required String token,
    required String title,
    required String author,
    String? description,
    int? relatedBookId,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await _suggestionService.submitSuggestion(
      token: token,
      title: title,
      author: author,
      description: description,
      relatedBookId: relatedBookId,
    );

    print("🎯 [SuggestionProvider - إرسال] رد الباك إند: $result");

    _isLoading = false;
    notifyListeners();
    
    return result;
  }

  // 2️⃣ دالة جلب اقتراحات المستخدم الحالي وعرضها بالواجهة (مضافة وجاهزة)
  Future<void> getUserSuggestions({required String token}) async {
    _isFetching = true;
    _userSuggestions = []; // تصفية القائمة السابقة قبل الجلب الجديد
    notifyListeners();

    final result = await _suggestionService.fetchUserSuggestions(token: token);

    print("🎯 [SuggestionProvider - جلب] رد الباك إند: $result");

    if (result['success'] == true && result['data'] != null) {
      _userSuggestions = result['data']; // تخزين القائمة القادمة من Laravel
    } else {
      _userSuggestions = []; // في حال الفشل نضمن أنها فارغة ولا تسبب كراش
    }

    _isFetching = false;
    notifyListeners();
  }
}