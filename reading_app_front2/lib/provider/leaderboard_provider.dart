import 'package:flutter/material.dart';
import 'package:reading_app_front2/models/LeaderboardUser.dart'; // تأكدي من المسار الصحيح للموديل
import 'package:reading_app_front2/services/leaderboard_service.dart';

class LeaderboardProvider with ChangeNotifier {
  final LeaderboardService _service = LeaderboardService();
  
  // تغيير النوع من dynamic إلى LeaderboardUser لسهولة التعامل مع الصور والبيانات
  List<LeaderboardUser> _users = [];
  bool _isLoading = false;
  String _error = "";

  List<LeaderboardUser> get users => _users;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchLeaderboard(String token) async {
    _isLoading = true;
    _error = "";
    notifyListeners();

    try {
      // 1. جلب البيانات الخام من السيرفس
      final List<Map<String, dynamic>> rawData = await _service.getUsersProgress(token);
      
      // 2. تحويل البيانات من Map إلى كائنات LeaderboardUser (التي تحتوي على حقل الصورة)
      _users = rawData.map((json) => LeaderboardUser.fromJson(json)).toList();
      
      if (_users.isEmpty) {
        _error = "لا توجد بيانات حالياً";
      }
    } catch (e) {
      _error = "حدث خطأ أثناء جلب قائمة المتصدرين";
      print("❌ LeaderboardProvider Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}