import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:reading_app_front2/conset_app.dart';
import 'package:reading_app_front2/provider/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  static String id = 'ProfileScreen';
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<UserProvider>(context, listen: false).fetchUserData(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;

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

            const SizedBox(height: 70),

            Text(
              user?.nickname ?? "",
              style: GoogleFonts.katibeh(
                fontSize: 26,
                color: AppColors.burgundy,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

         
            if (user?.stats != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.burgundy.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem("منتهية", user!.stats!.finished),
                      _buildVerticalDivider(),
                      _buildStatItem("أقرأ الآن", user.stats!.readingNow),
                      _buildVerticalDivider(),
                      _buildStatItem("أريد قراءته", user.stats!.wantToRead),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 25),
            _buildProfileTile(
              title: "اسم المستخدم",
              value: user?.name ?? "الاسم غير متوافر",
              icon: Icons.person_outline,
            ),
            _buildProfileTile(
              title: "البريد الإلكتروني",
              value: user?.email ?? "لا يوجد بريد",
              icon: Icons.email_outlined,
            ),
        
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
  Widget _buildStatItem(String label, int count) {
    return Column(
      children: [
        Text(
          "$count",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.burgundy,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.tajawal(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }
  Widget _buildVerticalDivider() {
    return Container(height: 30, width: 1, color: Colors.grey[300]);
  }
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
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        title: Text(
          title,
          textAlign: TextAlign.right,
          style: GoogleFonts.katibeh(color: AppColors.burgundy, fontSize: 20),
        ),
        subtitle: Text(
          value,
          textAlign: TextAlign.right,
          style:  GoogleFonts.katibeh(color: AppColors.burgundy, fontSize: 20),
        ),
        trailing: Icon(icon, color: AppColors.burgundy),
      ),
    );
  }
}
