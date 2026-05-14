import 'package:flutter/material.dart';
import 'package:reading_app_front2/models/LeaderboardUser.dart';
import 'package:reading_app_front2/services/leaderboard_service.dart';

class LeaderboardProvider with ChangeNotifier {
  final LeaderboardService _service = LeaderboardService();
  
  List<LeaderboardUser> _allUsers = [];      
  List<LeaderboardUser> _followingUsers = []; 
  List<LeaderboardUser> _followersUsers = []; 

  bool _isLoading = false;
  String _error = "";

  List<LeaderboardUser> get users => _allUsers;
  List<LeaderboardUser> get followingUsers => _followingUsers;
  List<LeaderboardUser> get followersUsers => _followersUsers;
  bool get isLoading => _isLoading;
  String get error => _error;

  void _syncFollowStatus(List<LeaderboardUser> targetList) {
    for (var user in targetList) {
      user.isFollowing = _followingUsers.any((followed) => followed.id == user.id);
    }
  }

  // --- جلب تفاصيل مستخدم محدد ---
  Future<Map<String, dynamic>?> fetchUserDetails(String token, int userId) async {
    // نطلب البيانات من السيرفر (ستحتوي على العدادات المحدثة stats)
    return await _service.getFollowedUserDetails(token, userId);
  }

  // --- دالة جديدة لتحديث العدادات بعد إضافة كتاب ---
  Future<void> refreshStatsAfterAction(String token, int userId) async {
    // هذه الدالة تجبر الواجهة على إعادة طلب البيانات
    notifyListeners(); 
  }

  // --- جلب الكل ---
  Future<void> fetchLeaderboard(String token) async {
    _isLoading = true;
    _error = "";
    notifyListeners();
    try {
      final List<Map<String, dynamic>> rawAll = await _service.getUsersProgress(token);
      final List<Map<String, dynamic>> rawFollowing = await _service.getFollowing(token);

      _allUsers = rawAll.map((json) => LeaderboardUser.fromJson(json)).toList();
      _followingUsers = rawFollowing.map((json) => LeaderboardUser.fromJson(json)).toList();

      _syncFollowStatus(_allUsers); 
      _syncFollowStatus(_followingUsers); 
      
      if (_allUsers.isEmpty) _error = "لا توجد بيانات حالياً";
    } catch (e) {
      _error = "حدث خطأ في جلب البيانات";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- جلب أتابعهم ---
  Future<void> fetchFollowing(String token) async {
    try {
      final List<Map<String, dynamic>> rawData = await _service.getFollowing(token);
      _followingUsers = rawData.map((json) => LeaderboardUser.fromJson(json)).toList();
      for (var u in _followingUsers) { u.isFollowing = true; }
      _syncFollowStatus(_allUsers);
      _syncFollowStatus(_followersUsers);
    } catch (e) {
      print("Error in fetchFollowing: $e");
    }
    notifyListeners();
  }

  // --- جلب المتابعون ---
  Future<void> fetchFollowers(String token) async {
    try {
      final List<Map<String, dynamic>> rawData = await _service.getFollowers(token);
      _followersUsers = rawData.map((json) => LeaderboardUser.fromJson(json)).toList();
      _syncFollowStatus(_followersUsers);
    } catch (e) {
      print("Error in fetchFollowers: $e");
    }
    notifyListeners();
  }

  // --- دالة التبديل (Toggle) ---
  Future<void> toggleFollow(String token, LeaderboardUser user) async {
    final bool wasFollowing = user.isFollowing ?? false;
    user.isFollowing = !wasFollowing;
    notifyListeners();

    try {
      Map<String, dynamic> result;
      if (user.isFollowing == true) {
        result = await _service.followUser(token, user.id);
      } else {
        result = await _service.unfollowUser(token, user.id);
      }

      if (result['success'] == true) {
        await fetchFollowing(token); 
      } else {
        user.isFollowing = wasFollowing;
        notifyListeners();
      }
    } catch (e) {
      user.isFollowing = wasFollowing;
      notifyListeners();
    }
  }
}