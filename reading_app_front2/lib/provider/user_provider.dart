import 'dart:io'; // أضيفي هذا لاستخدام ملفات الصور
import 'package:flutter/material.dart';
import 'package:reading_app_front2/models/UserProfileModel.dart';
import 'package:reading_app_front2/services/UserProfileService.dart';

class UserProvider with ChangeNotifier {
  UserProfileModel? _user;
  bool _isLoading = false;

  UserProfileModel? get user => _user;
  bool get isLoading => _isLoading;

  void setUser(UserProfileModel newUser) {
    _user = newUser;
    notifyListeners(); 
  }

  // 1. إضافة دالة التحديث لحل خطأ "updateUserData isn't defined"
  Future<void> updateUserData({String? newName, File? newImage}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // هنا مستقبلاً ستتصلين بالـ Service لإرسال البيانات للباك إند
      // مثال مؤقت لتحديث الاسم محلياً حتى تكتمل الـ API:
      if (_user != null && newName != null) {
        // افترضنا أن الموديل لديه خاصية الاسم، قومي بتغييرها حسب مسميات الموديل عندك
        // _user!.name = newName; 
      }
      
      // بعد نجاح الـ API نقوم بجلب البيانات المحدثة
      await fetchUserData(); 
    } catch (e) {
      print("Update Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUserData() async {
    _isLoading = true;
    notifyListeners(); 

    try {
      final updatedUser = await UserProfileService().getUserInfo();
      if (updatedUser != null) {
        _user = updatedUser;
      }
    } catch (e) {
      print("Provider Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners(); 
    }
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}