import 'package:flutter/material.dart';
import 'package:reading_app_front2/models/UserProfileModel.dart';
import 'package:reading_app_front2/services/UserProfileService.dart';

class UserProvider with ChangeNotifier {
  UserProfileModel? _user;
  bool _isLoading = false;

  UserProfileModel? get user => _user;
  bool get isLoading => _isLoading;

  // --- الدالة المفقودة التي تسببت في الخطأ ---
  void setUser(UserProfileModel newUser) {
    _user = newUser;
    notifyListeners(); // ضرورية جداً لتنبيه الواجهات بالتغيير
  }
  // ---------------------------------------

  // دالة لجلب البيانات وتخزينها في الخزان
  Future<void> fetchUserData() async {
    if (_user != null) return; 

    _isLoading = true;
    notifyListeners(); 

    try {
      _user = await UserProfileService().getUserInfo();
    } catch (e) {
      print("Provider Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners(); 
    }
  }
}