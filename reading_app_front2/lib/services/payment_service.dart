import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymentService {
  final String baseUrl = 'http://192.168.34.216:8000/api'; 

  // دالة خاصة لتجهيز الهيدرز، تستقبل التوكن كمدخل
  Map<String, String> _getHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json', 
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> checkout({
    required int bookId, 
    required double amount, 
    required String token, // استقبال التوكن من البروفايدر
    bool isTest = false
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/payment/checkout'),
      headers: _getHeaders(token),
      body: jsonEncode({
        'book_id': bookId,
        'amount': amount,
        'is_test': isTest,
      }),
    );
    
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> confirmPayment({
    int? paymentId, 
    String? gatewayId, 
    required String token, // استقبال التوكن من البروفايدر
    String status = 'succeeded'
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/payment/confirm'),
      headers: _getHeaders(token),
      body: jsonEncode({
        'payment_id': paymentId,
        'gateway_id': gatewayId,
        'status': status,
      }),
    );
    return jsonDecode(response.body);
  }
}