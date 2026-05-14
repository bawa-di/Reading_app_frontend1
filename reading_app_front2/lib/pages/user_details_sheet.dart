import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:reading_app_front2/conset_app.dart';
import 'package:reading_app_front2/models/LeaderboardUser.dart';
import 'package:reading_app_front2/provider/leaderboard_provider.dart';
import 'package:reading_app_front2/provider/user_provider.dart';

class UserDetailsSheet extends StatelessWidget {
  final int userId;

  const UserDetailsSheet({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final token = Provider.of<UserProvider>(context, listen: false).token ?? "";
    final leaderboardProvider = Provider.of<LeaderboardProvider>(
      context,
      listen: false,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      decoration: const BoxDecoration(
        color: AppColors.creamBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: FutureBuilder<Map<String, dynamic>?>(
        key: ValueKey(userId),
        future: leaderboardProvider.fetchUserDetails(token, userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 300,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.burgundy),
              ),
            );
          }

          if (snapshot.hasError ||
              snapshot.data == null ||
              snapshot.data!['data'] == null) {
            return const SizedBox(
              height: 200,
              child: Center(child: Text("عذراً، فشل تحميل البيانات")),
            );
          }

          final Map<String, dynamic> rawData = snapshot.data!['data'];

          // سطر التشخيص: سيطبع لكِ في الكونسول الأسماء العربية كما وصلت من رفيقتكِ
          print("الأسماء الواصلة من الباك-إند: ${rawData.keys.toList()}");

          // استخدام الموديل لتحويل البيانات
          final user = LeaderboardUser.fromJson(rawData);

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.burgundy.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),

              // الصورة الشخصية
              CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.burgundy.withOpacity(0.1),
                child: CircleAvatar(
                  radius: 46,
                  backgroundImage:
                      (user.profileImg != null && user.profileImg!.isNotEmpty)
                      ? NetworkImage(user.profileImg!)
                      : const AssetImage('assets/images/default_avatar.png')
                            as ImageProvider,
                ),
              ),
              const SizedBox(height: 15),

              // اسم المستخدم واللقب
              Text(
                user.name,
                style: GoogleFonts.katibeh(
                  fontSize: 32,
                  color: AppColors.burgundy,
                ),
              ),
              Text(
                user.nickname,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Divider(
                  thickness: 1,
                  indent: 30,
                  endIndent: 30,
                  color: AppColors.burgundy,
                ),
              ),

              // عرض العدادات بالأسماء العربية المرتبطة
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatBox("قرأ", user.finishedCount.toString()),
                  _buildStatBox("يقرأ حالياً", user.readingNowCount.toString()),
                  _buildStatBox("يود قراءته", user.wantToReadCount.toString()),
                ],
              ),
              const SizedBox(height: 30),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatBox(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.katibeh(
            fontSize: 35,
            color: AppColors.burgundy,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.burgundy,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
