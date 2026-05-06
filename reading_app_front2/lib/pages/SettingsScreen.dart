import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:reading_app_front2/conset_app.dart';
import 'package:reading_app_front2/pages/EditProfilePage.dart';
import 'package:reading_app_front2/provider/user_provider.dart';

class SettingsScreen extends StatelessWidget {
  static String id = 'SettingsScreen';
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;

    return Scaffold(
      // استخدام اللون الكريمي من كلاس AppColors
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.burgundy,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textFieldFill),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "الإعدادات",
          style: GoogleFonts.katibeh(color: AppColors.textFieldFill, fontSize: 28),
        ),
        
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 30),

            _buildSectionHeader("معلومات الحساب"),
            _buildSettingsCard(
              children: [
                _buildSettingsItem(
                  icon: Icons.person_outline,
                  title: "معلومات شخصية",
                  subtitle: "تعديل معلومات",
                  onTap: () {
                    Navigator.pushNamed(context, EditProfilePage.id);
                  },
                ),
                _buildDivider(),
              ],
            ),

            const SizedBox(height: 25),
             _buildSectionHeader("الوضع"),
               _buildSettingsCard(
              children: [
                _buildSettingsItem(
                  icon: Icons.sunny,
                  title: "تغيير وضع التطبيق",
                  subtitle: "",
                  onTap: () {},
                ),
                _buildDivider(),
              ],
            ),
             
             const SizedBox(height: 25),

            _buildSectionHeader("الإجراءات"),
            _buildSettingsCard(
              children: [
                _buildSettingsItem(
                  icon: Icons.logout,
                  title: "تسجيل الخروج",
                  subtitle: "الخروج من الحساب الحالي",
                  onTap: () {
                    Navigator.pushReplacementNamed(context, 'LoginScreen');
                  },
                ),
                _buildDivider(),
                _buildSettingsItem(
                  icon: Icons.delete_forever_outlined,
                  title: "حذف الحساب",
                  subtitle: "حذف بياناتك نهائياً من دفة",
                  textColor: AppColors.burgundy,
                  onTap: () {
                    _showDeleteAccountDialog(context);
                  },
                ),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 10, bottom: 8),
        child: Text(
          title,
          style: GoogleFonts.katibeh(
            color: AppColors.burgundy,
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        // استخدام textFieldFill (الأبيض) لداخل الكرت
        color: AppColors.textFieldFill,
        borderRadius: BorderRadius.circular(20),
        // الإطار البرغندي المعتمد على AppColors
        border: Border.all(
          color: AppColors.burgundy.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.burgundy,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    bool isReadOnly = false,
    Color? textColor,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      leading: isReadOnly
          ? const SizedBox(width: 20)
          : const Icon(Icons.arrow_back_ios_new, size: 14, color: Colors.grey),
      title: Text(
        title,
        textAlign: TextAlign.right,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: textColor ?? Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        textAlign: TextAlign.right,
        style: const TextStyle(color: Colors.grey, fontSize: 13),
      ),
      trailing: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          // استخدام pinkAccent كخلفية خفيفة للأيقونات ليعطي لمسة جمالية
          color: AppColors.pinkAccent.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.burgundy, size: 22),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.burgundy.withOpacity(0.1),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.creamBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.burgundy, width: 1),
        ),
        title: Text(
          "حذف الحساب",
          textAlign: TextAlign.right,
          style: GoogleFonts.katibeh(color: AppColors.burgundy, fontSize: 24),
        ),
        content: const Text(
          "هل أنتِ متأكدة؟ سيؤدي هذا الإجراء إلى حذف كافة كتبكِ ونقاطكِ نهائياً.",
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              "تأكيد الحذف",
              style: TextStyle(
                color: AppColors.burgundy,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
