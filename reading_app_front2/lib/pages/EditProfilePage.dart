import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
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

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isNameEditable = false;
  bool _isEmailEditable = false;
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  File? _image;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _nameController = TextEditingController(text: userProvider.user?.name ?? "");
    _emailController = TextEditingController(text: userProvider.user?.email ?? "");
  }
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50, 
      );
      if (image != null) {
        setState(() => _image = File(image.path));
        debugPrint("تم اختيار الصورة: ${image.path}");
      }
    } catch (e) {
      debugPrint("خطأ في اختيار الصورة: $e");
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
              style: GoogleFonts.katibeh(
                color: AppColors.textFieldFill,
                fontSize: 28,
              ),
            ),
            backgroundColor: AppColors.burgundy,
            elevation: 0,
            centerTitle: true,
            iconTheme: const IconThemeData(color: AppColors.textFieldFill),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 62,
                          backgroundColor: AppColors.burgundy,
                          child: CircleAvatar(
                            radius: 58,
                            backgroundColor: AppColors.textFieldFill,
                            backgroundImage: _image != null
                                ? FileImage(_image!)
                                : (userProvider.user?.profileImg != null
                                    ? NetworkImage(userProvider.user!.profileImg!)
                                    : null) as ImageProvider?,
                            child: (_image == null && userProvider.user?.profileImg == null)
                                ? const Icon(
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
                            child: const CircleAvatar(
                              backgroundColor: AppColors.burgundy,
                              radius: 18,
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.white, 
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  Text(
                    "البيانات الشخصية",
                    style: AppTextStyles.headerStyle.copyWith(fontSize: 16, color: AppColors.burgundy),
                  ),
                  const SizedBox(height: 15),

                  _buildEditableField(
                    label: "الاسم الكامل",
                    controller: _nameController,
                    icon: Icons.person_outline,
                    isEditable: _isNameEditable,
                    onEditPressed: () => setState(() => _isNameEditable = !_isNameEditable),
                  ),
                  const SizedBox(height: 15),

                  _buildEditableField(
                    label: "البريد الإلكتروني",
                    controller: _emailController,
                    icon: Icons.email_outlined,
                    isEditable: _isEmailEditable,
                    onEditPressed: () => setState(() => _isEmailEditable = !_isEmailEditable),
                  ),

                
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Divider(color: AppColors.burgundy.withOpacity(0.2)),
                  ),
                  Text(
                    "تغيير كلمة المرور",
                    style: AppTextStyles.headerStyle.copyWith(fontSize: 16, color: AppColors.burgundy),
                  ),
                  const SizedBox(height: 15),

                  _buildPasswordField(
                    "كلمة المرور الحالية",
                    _oldPasswordController,
                    _obscureOld,
                    () => setState(() => _obscureOld = !_obscureOld),
                  ),
                  const SizedBox(height: 15),
                  _buildPasswordField(
                    "كلمة المرور الجديدة",
                    _passwordController,
                    _obscureNew,
                    () => setState(() => _obscureNew = !_obscureNew),
                  ),
                  const SizedBox(height: 15),
                  _buildPasswordField(
                    "تأكيد كلمة المرور",
                    _confirmPasswordController,
                    _obscureConfirm,
                    () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),

                  const SizedBox(height: 50),

           
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: userProvider.isLoading
                          ? null
                          : () async {
                              final result = await userProvider.updateUserData(
                                newName: _nameController.text.trim(),
                                newEmail: _emailController.text.trim(),
                                oldPassword: _oldPasswordController.text,
                                newPassword: _passwordController.text,
                                confirmPassword: _confirmPasswordController.text,
                                newImage: _image,
                              );

                              if (result == null) {
                              
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      backgroundColor: AppColors.textFieldFill,
                                      content: Text(
                                        "تم حفظ التغييرات بنجاح!",
                                        style: TextStyle(color: AppColors.burgundy),
                                      ),
                                    ),
                                  );
                                  setState(() {
                                    _isNameEditable = false;
                                    _isEmailEditable = false;
                                  });
                                }
                              } else {
                              
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(result)),
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.burgundy,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: userProvider.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "حفظ التغييرات",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

 
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
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.katibeh(color: AppColors.burgundy, fontSize: 18),
            ),
            const Spacer(),
            IconButton(
              icon: Icon(
                isEditable ? Icons.check_circle_outline : Icons.edit_outlined,
                color: AppColors.burgundy,
                size: 20,
              ),
              onPressed: onEditPressed,
            ),
          ],
        ),
        TextFormField(
          controller: controller,
          enabled: isEditable,
          style: const TextStyle(color: AppColors.burgundy),
          decoration: InputDecoration(
            filled: !isEditable,
            fillColor: isEditable ? Colors.transparent : AppColors.pinkAccent.withOpacity(0.1),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.burgundy),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.burgundy, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    bool obscure,
    VoidCallback onToggle,
  ) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: AppColors.burgundy),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: AppColors.burgundy.withOpacity(0.5),
          fontSize: 14,
        ),
        prefixIcon: const Icon(Icons.lock_open_rounded, color: AppColors.burgundy, size: 20),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: AppColors.burgundy),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: AppColors.textFieldFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _oldPasswordController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}