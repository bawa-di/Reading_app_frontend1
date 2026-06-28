import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // مضاف لاستدعاء البروفايدرز
import 'package:reading_app_front2/conset_app.dart';
import 'package:reading_app_front2/provider/SuggestionProvider.dart';
import 'package:reading_app_front2/provider/user_provider.dart'; // مضاف لجلب التوكن

class BookSuggestionSheet extends StatefulWidget {
  final int? relatedBookId; // معرف الكتاب الحالي لربطه بالباك إند

  const BookSuggestionSheet({super.key, this.relatedBookId});

  @override
  State<BookSuggestionSheet> createState() => _BookSuggestionSheetState();
}

class _BookSuggestionSheetState extends State<BookSuggestionSheet> {
  // 🕹️ وحدات التحكم بالنصوص لاستخراج القيم عند الحفظ
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // مراقبة حالة التحميل من البروفايدر لتغيير شكل الزر
    final suggestionProvider = context.watch<SuggestionProvider>();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: const BoxDecoration(
          color: AppColors.creamBackground, // الخلفية الكريمية العتيقة للتطبيق
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔘 مؤشر السحب العلوي اللطيف لمنح النافذة مظهراً مرناً
                Center(
                  child: Container(
                    width: 50,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 📝 العنوان الرئيسي للنافذة
                Row(
                  children: [
                    const Icon(Icons.auto_stories_rounded, color: AppColors.burgundy, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      "اقترح كتاباً جديداً",
                      style: GoogleFonts.tajawal(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: AppColors.burgundy,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  "شاركينا عناوينك المفضلة لإضافتها إلى رفوف تطبيق جليس.",
                  style: GoogleFonts.tajawal(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),

                // 🛑 1. حقل إدخال عنوان الكتاب (إجباري)
                _buildLabel("عنوان الكتاب المقترح *"),
                TextFormField(
                  controller: _titleController,
                  textDirection: TextDirection.rtl,
                  style: GoogleFonts.tajawal(fontSize: 14),
                  decoration: _buildInputDecoration("مثال: أرض زيكولا"),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'الرجاء إدخال عنوان الكتاب';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ✍️ 2. حقل إدخال اسم المؤلف (إجباري)
                _buildLabel("اسم الكاتب / المؤلف *"),
                TextFormField(
                  controller: _authorController,
                  textDirection: TextDirection.rtl,
                  style: GoogleFonts.tajawal(fontSize: 14),
                  decoration: _buildInputDecoration("مثال: عمرو عبد الحميد"),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'الرجاء إدخال اسم المؤلف';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 💬 3. حقل نبذة عن الكتاب أو سبب الاقتراح (اختياري)
                _buildLabel("نبذة أو سبب الاقتراح (اختياري)"),
                TextFormField(
                  controller: _descController,
                  maxLines: 3,
                  textDirection: TextDirection.rtl,
                  style: GoogleFonts.tajawal(fontSize: 14),
                  decoration: _buildInputDecoration("اكتبي لمحة بسيطة عن قصته أو لماذا تنصحين به..."),
                ),
                const SizedBox(height: 28),

                // 🚀 4. زر التأكيد والإرسال الذكي (يتغير مؤشر تحميل عند الإرسال)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: suggestionProvider.isLoading
                        ? null // تعطيل الزر أثناء التحميل لمنع التكرار
                        : () {
                            if (_formKey.currentState!.validate()) {
                              _sendSuggestion();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.burgundy,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                    ),
                    child: suggestionProvider.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            "إرسال الاقتراح",
                            style: GoogleFonts.tajawal(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ويجيت نصوص العناوين الصغيرة فوق الحقول لترتيب المظهر البصري
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, right: 4),
      child: Text(
        text,
        style: GoogleFonts.tajawal(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  // ستايل الحقول (Input Decoration) الأنيق والموحد بالكامل
  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.tajawal(color: Colors.grey[400], fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.burgundy, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }

  // 🎯 دالة الربط الحقيقية مع الـ SuggestionProvider الخاص بكِ
  void _sendSuggestion() async {
    // 1. جلب التوكن من الـ UserProvider لمعرفة القارئة المفترحة
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.token;

    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء تسجيل الدخول أولاً لإرسال اقتراح.')),
      );
      return;
    }

    // 2. استدعاء البروفايدر لتنفيذ الطلب وتمرير النصوص الحية
    final provider = Provider.of<SuggestionProvider>(context, listen: false);
    
    final result = await provider.sendBookSuggestion(
      token: token,
      title: _titleController.text.trim(),
      author: _authorController.text.trim(),
      description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
      relatedBookId: widget.relatedBookId,
    );

    // 3. معالجة النتيجة بناءً على الـ Map الراجع من السيرفر
    // (افترضت هنا أن السيرفر يرجع نجاحاً بناءً على كود الحالة، يمكنكِ مطابقتها مع رد دالة السيرفر لديكِ)
    if (result['success'] == true || result.containsKey('id')) { 
      if (!mounted) return;
      
      // إغلاق نافذة الـ BottomSheet بنجاح
      Navigator.pop(context);

      // إظهار رسالة النجاح الأنيقة بلون البرغندي
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message'] ?? 'شكرًا لكِ! تم إرسال اقتراحكِ للمدير بنجاح.',
            style: GoogleFonts.tajawal(color: AppColors.burgundy, fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.pinkAccent,
        ),
      );
    } else {
      if (!mounted) return;
      // إظهار رسالة خطأ في حال فشلت العملية بالخلفية
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message'] ?? 'عذرًا، فشل إرسال الاقتراح. يرجى المحاولة مجددًا.',
            style: GoogleFonts.tajawal(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}