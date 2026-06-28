import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reading_app_front2/models/UserProfileModel.dart';
import 'package:reading_app_front2/services/UserProfileService.dart';
import 'package:reading_app_front2/services/AuthService.dart';

class UserProvider with ChangeNotifier {
  // --- المتغيرات ---
  UserProfileModel? _user;
  String? _token;
  bool _isLoading = false;
  bool _hasNewNotification = false;

  // --- الـ Getters ---
  UserProfileModel? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get hasNewNotification => _hasNewNotification;

  // --- دالة التنظيف الموحدة (Reset) ---
  // يتم استدعاؤها عند تسجيل الخروج أو حذف الحساب لضمان عدم وجود بيانات عالقة
  void clearUserData() {
    _user = null;
    _token = null;
    _hasNewNotification = false;
    notifyListeners();
  }

  // --- إدارة الإشعارات ---
  void setNotificationStatus(bool status) {
    _hasNewNotification = status;
    notifyListeners();
  }

  // --- إدارة التوكن ---
  Future<void> loadTokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    notifyListeners();
  }

  void setToken(String newToken) async {
    _token = newToken;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', newToken);
    notifyListeners();
  }

  // --- تعيين المستخدم ---
  Future<void> setUser(UserProfileModel newUser, {String? userToken}) async {
    _user = newUser;
    if (userToken != null) {
      _token = userToken;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', userToken);
    }
    notifyListeners();
  }

  // --- جلب بيانات المستخدم من السيرفر ---
  Future<void> fetchUserData() async {
    _isLoading = true;
    notifyListeners();
    try {
      final updatedUser = await UserProfileService().getUserInfo();
      if (updatedUser != null) {
        _user = updatedUser;
      }
    } catch (e) {
      print("Fetch Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- تحديث بيانات الملف الشخصي ---
  Future<String?> updateUserData({
    String? newName,
    String? newEmail,
    String? oldPassword,
    String? newPassword,
    String? confirmPassword,
    File? newImage,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await UserProfileService().updateProfile(
        name: newName,
        email: newEmail,
        oldPassword: oldPassword,
        password: newPassword,
        passwordConfirmation: confirmPassword,
        imageFile: newImage,
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        await fetchUserData();
        return null;
      } else {
        return data['message'] ?? "فشل التحديث";
      }
    } catch (e) {
      return "خطأ في الاتصال بالسيرفر";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- تسجيل الخروج ---
  Future<String?> logout() async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = await AuthService().logoutUser();
      if (result['status'] == 200 || result['status'] == 401) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        clearUserData(); // تصفير كامل للبيانات
        return null;
      }
      return result['body']['message'] ?? "حدث خطأ أثناء تسجيل الخروج";
    } catch (e) {
      return "فشل الاتصال";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- حذف الحساب ---
  Future<String?> deleteUserAccount() async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = await AuthService().deleteAccount();
      if (result['status'] == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        clearUserData(); // تصفير كامل للبيانات
        return null;
      }
      return result['body']['message'] ?? "فشل حذف الحساب";
    } catch (e) {
      return "حدث خطأ أثناء الحذف";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}