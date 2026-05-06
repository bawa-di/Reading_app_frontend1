import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:reading_app_front2/provider/user_provider.dart';
import 'package:reading_app_front2/conset_app.dart';

class EditProfilePage extends StatefulWidget {
  static String id = 'EditProfilePage';
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  // متحكمات النصوص
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // حالات التحكم في التعديل والرؤية
  bool _isNameEditable = false;
  bool _isEmailEditable = false;
  bool _obscureOld = true;
  bool _obscureNew = true;

  File? _image;

  @override
  void initState() {
    super.initState();
    // جلب البيانات الأولية من البروفايدر
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _nameController = TextEditingController(
      text: userProvider.user?.name ?? "",
    );
    _emailController = TextEditingController(
      text: userProvider.user?.email ?? "",
    );
  }

  Future _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Scaffold(
          backgroundColor: AppColors.creamBackground,
          appBar: AppBar(
            title: Text(
              "تعديل الحساب",
              style: GoogleFonts.katibeh(color: AppColors.textFieldFill, fontSize: 28),
            ),
            backgroundColor: AppColors.burgundy,
            elevation: 0,
            centerTitle: true,
            iconTheme: IconThemeData(color: AppColors.textFieldFill),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. صورة البروفايل مع القلم
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 62,
                          backgroundColor: AppColors.creamBackground,
                          child: CircleAvatar(
                            radius: 58,
                            backgroundColor: AppColors.textFieldFill,
                            backgroundImage: _image != null
                                ? FileImage(_image!)
                                : (userProvider.user?.profileImg != null
                                          ? NetworkImage(
                                              userProvider.user!.profileImg!,
                                            )
                                          : null)
                                      as ImageProvider?,
                            child:
                                (_image == null &&
                                    userProvider.user?.profileImg == null)
                                ? Icon(
                                    Icons.person,
                                    size: 50,
                                    color: AppColors.burgundy,
                                  )
                                : null,
                          ),
                        ),
                        Positioned(
                          bottom: 5,
                          right: 5,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: CircleAvatar(
                              backgroundColor: AppColors.burgundy,
                              radius: 18,
                              child: Icon(
                                Icons.camera_alt,
                                color: AppColors.pinkAccent,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40),

                  // 2. البيانات الأساسية مع تفعيل القلم
                  Text(
                    "البيانات الشخصية",
                    style: AppTextStyles.headerStyle.copyWith(fontSize: 16),
                  ),
                  SizedBox(height: 15),

                  _buildEditableField(
                    label: "الاسم الكامل",
                    controller: _nameController,
                    icon: Icons.person_outline,
                    isEditable: _isNameEditable,
                    onEditPressed: () =>
                        setState(() => _isNameEditable = !_isNameEditable),
                  ),
                  SizedBox(height: 15),

                  _buildEditableField(
                    label: "البريد الإلكتروني",
                    controller: _emailController,
                    icon: Icons.email_outlined,
                    isEditable: _isEmailEditable,
                    onEditPressed: () =>
                        setState(() => _isEmailEditable = !_isEmailEditable),
                  ),

                  // 3. قسم تغيير كلمة المرور
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Divider(color: AppColors.burgundy.withOpacity(0.2)),
                  ),
                  Text(
                    "تغيير كلمة المرور",
                    style: AppTextStyles.headerStyle.copyWith(fontSize: 16),
                  ),
                  SizedBox(height: 15),

                  _buildPasswordField(
                    label: "كلمة المرور الحالية",
                    controller: _oldPasswordController,
                    obscure: _obscureOld,
                    onToggle: () => setState(() => _obscureOld = !_obscureOld),
                  ),
                  SizedBox(height: 15),

                  _buildPasswordField(
                    label: "كلمة المرور الجديدة",
                    controller: _passwordController,
                    obscure: _obscureNew,
                    onToggle: () => setState(() => _obscureNew = !_obscureNew),
                  ),

                  SizedBox(height: 50),

                  // 4. زر الحفظ
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () async {
                        // استدعاء دالة التحديث من البروفايدر
                        await userProvider.updateUserData(
                          newName: _nameController.text,
                          newImage: _image,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "تم حفظ التغييرات بنجاح",
                              style: TextStyle(fontFamily: 'Cairo'),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.burgundy,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: userProvider.isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              "حفظ التغييرات",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ودجت الحقول القابلة للتعديل بالقلم
  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool isEditable,
    required VoidCallback onEditPressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.burgundy, size: 20),
            SizedBox(width: 8),
            Text(
              label,
              style:  GoogleFonts.katibeh(color: AppColors.burgundy,fontSize: 18),
            ),
            Spacer(),
            IconButton(
              icon: Icon(
                isEditable ? Icons.check_circle_outline : Icons.edit_outlined,
                color: isEditable ? AppColors.burgundy : AppColors.burgundy,
                size: 20,
              ),
              onPressed: onEditPressed,
            ),
          ],
        ),
        TextFormField(
          controller: controller,
          enabled: isEditable,
          style: TextStyle(color: AppColors.burgundy),
          decoration: InputDecoration(
            filled: !isEditable,
            fillColor: isEditable
                ? Colors.transparent
                : AppColors.pinkAccent.withOpacity(0.2),
            contentPadding: EdgeInsets.symmetric(horizontal: 10),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.burgundy),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.burgundy, width: 2),
            ),
            disabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent),
            ),
          ),
        ),
      ],
    );
  }

  // ودجت حقول كلمة المرور
  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(color: AppColors.burgundy),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: AppColors.burgundy.withOpacity(0.5),
          fontSize: 14,
        ),
        prefixIcon: Icon(
          Icons.lock_open_rounded,
          color: AppColors.burgundy,
          size: 20,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: AppColors.burgundy,
            size: 20,
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: AppColors.textFieldFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 15),
      ),
    );
  }
}
