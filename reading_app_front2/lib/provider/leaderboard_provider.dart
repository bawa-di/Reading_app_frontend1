import 'package:flutter/material.dart';
import 'package:reading_app_front2/models/LeaderboardUser.dart';
import 'package:reading_app_front2/services/leaderboard_service.dart';

class LeaderboardProvider with ChangeNotifier {
  final LeaderboardService _service = LeaderboardService();

  int? _currentUserId;
  int? get currentUserId => _currentUserId;

  List<LeaderboardUser> _allUsers = [];
  List<LeaderboardUser> _followingUsers = [];
  List<LeaderboardUser> _followersUsers = [];

  bool _isLoading = false;
  bool _isFollowingLoading = false;
  String _error = "";

  List<LeaderboardUser> get users => _allUsers;
  List<LeaderboardUser> get followingUsers => _followingUsers;
  List<LeaderboardUser> get followersUsers => _followersUsers;
  bool get isLoading => _isLoading;
  bool get isFollowingLoading => _isFollowingLoading;
  String get error => _error;

  void setCurrentUserId(int id) {
    _currentUserId = id;
    notifyListeners();
  }

  // تحديث حالة المستخدم في جميع القوائم المحلية لضمان الاتساق
  void _updateLocalUserStatus(int userId, bool isFollowing) {
    for (var u in _allUsers) { if (u.id == userId) u.isFollowing = isFollowing; }
    for (var u in _followersUsers) { if (u.id == userId) u.isFollowing = isFollowing; }
    for (var u in _followingUsers) { if (u.id == userId) u.isFollowing = isFollowing; }
  }

  Future<void> fetchLeaderboard(String token) async {
    _isLoading = true;
    _error = "";
    notifyListeners();
    try {
      final rawAll = await _service.getUsersProgress(token);
      _allUsers = rawAll.map((json) => LeaderboardUser.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Error in fetchLeaderboard: $e");
      _error = "فشل في تحميل قائمة المتصدرين";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchFollowing(String token) async {
    _isFollowingLoading = true;
    notifyListeners();
    try {
      final rawFollowingList = await _service.getFollowing(token);
      _followingUsers = rawFollowingList.map((json) => LeaderboardUser.fromJson(json)).toList();
      
      // تحديث الحالة في القائمة الرئيسية بناءً على قائمة المتابعة الجديدة
      for (var user in _allUsers) {
        user.isFollowing = _followingUsers.any((followed) => followed.id == user.id);
      }
    } catch (e) {
      debugPrint("❌ Error in fetchFollowing: $e");
    } finally {
      _isFollowingLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchFollowers(String token) async {
    try {
      final rawData = await _service.getFollowers(token);
      _followersUsers = rawData.map((json) => LeaderboardUser.fromJson(json)).toList();
    } catch (e) {
      debugPrint("❌ Error in fetchFollowers: $e");
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>?> fetchUserDetails(String token, int userId) async {
    return await _service.getFollowedUserDetails(token, userId);
  }

  Future<void> toggleFollow(String token, LeaderboardUser user) async {
    // حفظ الحالة الأصلية للتراجع في حال الفشل
    final bool wasFollowing = user.isFollowing ?? false;
    final bool newStatus = !wasFollowing;

    // 1. تحديث الحالة فوراً (Optimistic UI Update)
    user.isFollowing = newStatus;
    _updateLocalUserStatus(user.id, newStatus);
    
    // إخطار الواجهة فوراً بالتغيير
    notifyListeners();

    try {
      final result = await (wasFollowing 
          ? _service.unfollowUser(token, user.id) 
          : _service.followUser(token, user.id));

      if (result['success'] == true) {
        // نجاح العملية: إعادة جلب المتابعات للتأكد من دقة الحالة
        await fetchFollowing(token);
      } else {
        // فشل العملية: استعادة الحالة الأصلية
        user.isFollowing = wasFollowing;
        _updateLocalUserStatus(user.id, wasFollowing);
        notifyListeners();
      }
    } catch (e) {
      // حدوث استثناء: استعادة الحالة الأصلية
      user.isFollowing = wasFollowing;
      _updateLocalUserStatus(user.id, wasFollowing);
      notifyListeners();
      debugPrint("❌ Error in toggleFollow: $e");
    }
  }
}