import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // أضفنا استيراد البروفايدر
import 'package:reading_app_front2/conset_app.dart';
import 'package:reading_app_front2/provider/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  static String id = 'ProfileScreen';
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isChangingPassword = false;

  @override
  Widget build(BuildContext context) {
    // الاتصال بالخزان: مراقبة حالة المستخدم والبيانات
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;

    // إذا كانت البيانات لا تزال تُجلب من السيرفر، نعرض مؤشر التحميل
    if (userProvider.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.creamBackground,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.burgundy),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.burgundy,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 50,
                      right: 20,
                      left: 20,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: AppColors.textFieldFill,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Text(
                          "الملف الشخصي",
                          style: GoogleFonts.katibeh(
                            color: AppColors.textFieldFill,
                            fontSize: 30,
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 130,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.creamBackground,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[300],
                      // استخدام الصورة من البروفايدر مباشرة
                      backgroundImage:
                          (user?.profileImg != null &&
                              user!.profileImg!.isNotEmpty)
                          ? NetworkImage(user.profileImg!)
                          : null,
                      child:
                          (user?.profileImg == null ||
                              user!.profileImg!.isEmpty)
                          ? const Icon(
                              Icons.person,
                              size: 70,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 80),


            const SizedBox(height: 20),
            _buildProfileTile(
              title: "اسم المستخدم",
              value: "${user?.name ?? "الاسم غير متوافر"}",
              icon: Icons.person,
            ),
             _buildProfileTile(
              title: "البريد الإلكتروني",
              value: user?.email ?? "لا يوجد بريد",
              icon: Icons.email_outlined,
            ),
            _buildProfileTile(
              title: "لقب المستخدم",

              value: "${ user?.nickname ?? "اللقب غير متوافر"}",
              icon: Icons.star,
            
            ),
           
            _buildProfileTile(
              title: "النقاط الإجمالية",
              value: "${user?.totalPoints ?? 0} نقطة",
              icon: Icons.star_outline,
            ),

            if (_isChangingPassword)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 10,
                ),
               
                ),
          ],
        ),
      ),
    );
  }

  // --- دوال الـ Widgets بقيت كما هي للحفاظ على التصميم ---

  Widget _buildProfileTile({
    required String title,
    required String value,
    required IconData icon,
    Color? textColor,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.textFieldFill,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: AppColors.burgundy,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        title: Text(
          title,
          textAlign: TextAlign.right,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          value,
          textAlign: TextAlign.right,
          style: TextStyle(color: textColor ?? Colors.black54),
        ),
        trailing: Icon(icon, color: AppColors.burgundy),
      ),
    );
  }

  }
