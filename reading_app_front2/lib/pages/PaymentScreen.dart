import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reading_app_front2/conset_app.dart';
import 'package:reading_app_front2/models/book.dart';
import 'package:reading_app_front2/provider/payment_provider.dart';

class PaymentScreen extends StatelessWidget {
  static const routeName = '/payment';
  
  final Book book;

  const PaymentScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.burgundy.withOpacity(0.3),
      body: Center(
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5DC).withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Consumer<PaymentProvider>(
            builder: (context, paymentProvider, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "ملخص الطلب",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.burgundy),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    "كتاب: ${book.title}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "${book.price} ل.س",
                    style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppColors.burgundy),
                  ),
                  const SizedBox(height: 30),
                  paymentProvider.isLoading
                      ? const CircularProgressIndicator(color: AppColors.burgundy)
                      : ElevatedButton(
                          onPressed: () async {
                            print("--- [PaymentScreen] الضغط على زر الدفع للكتاب: ${book.id} ---");

                            // تنفيذ عملية الدفع فقط
                            bool success = await paymentProvider.processCheckout(
                              book.id,
                              book.price.toDouble(),
                              context,
                            );

                            if (success && context.mounted) {
                              // تم حذف تحديث BooksProvider هنا لمنع أي تغيير محلي في الذاكرة
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("تمت عملية الشراء بنجاح!"),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.pop(context); 
                            } else if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("حدث خطأ أثناء عملية الدفع، حاول مجدداً"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.burgundy,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 60, vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                          ),
                          child: const Text(
                            "دفع الآن",
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                  const SizedBox(height: 20),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline, size: 14, color: Colors.grey),
                      SizedBox(width: 5),
                      Text(
                        "عملية الدفع محمية ومشفرة بالكامل",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}