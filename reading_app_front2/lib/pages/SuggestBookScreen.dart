import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reading_app_front2/conset_app.dart'; // ملف الألوان الخاص بكِ

class SuggestBookBottomSheet extends StatefulWidget {
  final int? relatedBookId; 

  const SuggestBookBottomSheet({super.key, this.relatedBookId});

  static void show(BuildContext context, {int? relatedBookId}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // نعم نتركها true لكن التحكم سيكون من الحاوية بالأسفل
      backgroundColor: Colors.transparent, 
      // هذا السطر يمنع سحبها لأعلى الشاشة كاملة
      enableDrag: true, 
      builder: (context) => SuggestBookBottomSheet(relatedBookId: relatedBookId),
    );
  }

  @override
  State<SuggestBookBottomSheet> createState() => _SuggestBookBottomSheetState();
}

class _SuggestBookBottomSheetState extends State<SuggestBookBottomSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      // الـ Widget السحرية التي تجبر القائمة على أخذ نصف الشاشة بالضبط مهما حدث
      child: FractionallySizedBox(
        heightFactor: 0.55, // 0.55 يعني تظهر فوق النصف بقليل جداً لتستوعب الكيبورد دون أن تصبح واجهة كاملة
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.creamBackground,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          child: Column(
            children: [
              // مؤشر السحب
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 10),

              // العنوان وزر الإغلاق
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "اقترح كتاباً جديداً",
                    style: GoogleFonts.tajawal(
                      fontSize: 16, 
                      fontWeight: FontWeight.bold, 
                      color: AppColors.burgundy
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                  )
                ],
              ),
              const SizedBox(height: 10),

              // جعل الحقول بداخل النصف منزلقة
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildBottomSheetField(
                          controller: _titleController,
                          hint: "عنوان الكتاب *",
                          icon: Icons.book_outlined,
                          validator: (val) => (val == null || val.trim().isEmpty) ? "هذا الحقل مطلوب" : null,
                        ),
                        const SizedBox(height: 12),
                        _buildBottomSheetField(
                          controller: _authorController,
                          hint: "اسم المؤلف *",
                          icon: Icons.person_outline_rounded,
                          validator: (val) => (val == null || val.trim().isEmpty) ? "هذا الحقل مطلوب" : null,
                        ),
                        const SizedBox(height: 12),
                        _buildBottomSheetField(
                          controller: _descriptionController,
                          hint: "نبذة بسيطة (اختياري)",
                          icon: Icons.notes_rounded,
                          maxLines: 2, // قللنا الأسطر قليلاً لضمان المساحة
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                Navigator.pop(context); 
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.burgundy,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              "إرسال الاقتراح",
                              style: GoogleFonts.tajawal(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSheetField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      textAlign: TextAlign.right,
      style: GoogleFonts.tajawal(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
        prefixIcon: Icon(icon, color: AppColors.burgundy.withOpacity(0.6), size: 18),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.burgundy, width: 1.2),
        ),
        errorStyle: const TextStyle(fontSize: 11),
      ),
    );
  }
}