import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // ضروري للوصول لـ UserProvider
import 'package:reading_app_front2/provider/user_provider.dart';
import 'package:reading_app_front2/services/payment_service.dart';


class PaymentProvider with ChangeNotifier {
  final PaymentService _service = PaymentService();
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // أضفنا BuildContext للوصول إلى UserProvider
  Future<bool> processCheckout(int bookId, double amount, BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. جلب التوكن من UserProvider
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final String? token = userProvider.token;

      // 2. التحقق من وجود التوكن قبل الإرسال
      if (token == null || token.isEmpty) {
        debugPrint("Error: No authentication token found.");
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // 3. إرسال الطلب للسيرفر مع تمرير التوكن الحقيقي
      final result = await _service.checkout(
        bookId: bookId, 
        amount: amount, 
        token: token, // التوكن الآن يُمرر للسيرفس كما طلبتِ
        isTest: true
      );
      
      debugPrint("API Response: $result"); 

      _isLoading = false;
      notifyListeners();
      
      final bool isSuccess = result['success'] == true;
      
      if (!isSuccess) {
        debugPrint("Server returned error message: ${result['message']}");
      }
      
      return isSuccess;
    } catch (e) {
      debugPrint("Error caught in PaymentProvider: $e");
      
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}