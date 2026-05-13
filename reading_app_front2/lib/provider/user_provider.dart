import 'dart:convert';
import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:reading_app_front2/models/UserProfileModel.dart';
import 'package:reading_app_front2/services/UserProfileService.dart';
import 'package:reading_app_front2/services/AuthService.dart';

class UserProvider with ChangeNotifier {
  UserProfileModel? _user;
  String? _token; // - إضافة متغير لحفظ توكن المصادقة
  bool _isLoading = false;

  UserProfileModel? get user => _user;
  String? get token => _token; // - جلب التوكن لاستخدامه في الخدمات الأخرى
  bool get isLoading => _isLoading;

  // --- دالة تعيين المستخدم والتوكن (تُستدعى عند تسجيل الدخول) ---
  void setUser(UserProfileModel newUser, {String? userToken}) {
    _user = newUser;
    if (userToken != null) {
      _token = userToken; // - تخزين التوكن القادم من السيرفر
    }
    notifyListeners(); 
  }

  // --- دالة تعيين التوكن منفصلاً (إذا لزم الأمر) ---
  void setToken(String newToken) {
    _token = newToken;
    notifyListeners();
  }

  // --- دالة تحديث بيانات الملف الشخصي ---
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
        return data['message'] ?? "فشل التحديث، يرجى المحاولة لاحقاً";
      }
    } catch (e) {
      return "خطأ في الاتصال بالسيرفر";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- دالة جلب بيانات المستخدم من السيرفر ---
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

  // --- دالة تسجيل الخروج (تعديل لمسح التوكن) ---
  Future<String?> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await AuthService().logoutUser();

      // - مسح البيانات والتوكن عند تسجيل الخروج أو حدوث خطأ 401
      if (result['status'] == 200 || result['status'] == 401) {
        _user = null; 
        _token = null; // تصفير التوكن لضمان أمن التطبيق
        return null; 
      } else {
        return result['body']['message'] ?? "حدث خطأ أثناء تسجيل الخروج";
      }
    } catch (e) {
      return "فشل الاتصال، جربي مرة أخرى";
    } finally {
      _isLoading = false;
      notifyListeners(); 
    }
  }

  // --- دالة حذف الحساب النهائية ---
  Future<String?> deleteUserAccount() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await AuthService().deleteAccount();

      if (result['status'] == 200) {
        _user = null; 
        _token = null; // مسح التوكن عند حذف الحساب
        return null; 
      } else {
        return result['body']['message'] ?? "فشل حذف الحساب من السيرفر";
      }
    } catch (e) {
      return "حدث خطأ غير متوقع أثناء محاولة الحذف";
    } finally {
      _isLoading = false;
      notifyListeners(); 
    }
  }
}