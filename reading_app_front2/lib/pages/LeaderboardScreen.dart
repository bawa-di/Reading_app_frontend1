import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:reading_app_front2/conset_app.dart';
import 'package:reading_app_front2/models/LeaderboardUser.dart';
import 'package:reading_app_front2/provider/leaderboard_provider.dart';
import 'package:reading_app_front2/provider/user_provider.dart';

class LeaderboardScreen extends StatefulWidget {
  static String id = 'LeaderboardScreen';

  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final String? actualToken = userProvider.token;

    if (actualToken != null && actualToken.isNotEmpty) {
      Provider.of<LeaderboardProvider>(context, listen: false)
          .fetchLeaderboard(actualToken);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.creamBackground,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.burgundy,
          title: Text(
            "مجتمعي",
            style: GoogleFonts.katibeh(color: Colors.white, fontSize: 30),
          ),
          centerTitle: true,
        ),
        body: Consumer2<LeaderboardProvider, UserProvider>(
          builder: (context, leaderboardProvider, userProvider, child) {
            if (leaderboardProvider.isLoading) {
              return const Center(child: CircularProgressIndicator(color: AppColors.burgundy));
            }

            if (leaderboardProvider.error.isNotEmpty) {
              return _buildErrorWidget(leaderboardProvider.error);
            }

            final allUsers = leaderboardProvider.users;
            final int? myId = userProvider.user?.id;

            final topThree = allUsers.take(3).toList();
            final remainingUsers = allUsers.where((user) => user.id != myId).toList();

            if (allUsers.isEmpty) {
              return const Center(child: Text("لا توجد بيانات حالياً"));
            }

            return Column(
              children: [
                _buildPodiumSection(topThree),
                _buildTabSelector(),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 20),
                    itemCount: remainingUsers.length,
                    itemBuilder: (context, index) {
                      return _buildLeaderboardCard(user: remainingUsers[index]);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // --- قسم المنصة (التوب 3) مع عرض اللقب ---
  Widget _buildPodiumSection(List<LeaderboardUser> topUsers) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 20, 10, 30),
      decoration: const BoxDecoration(
        color: AppColors.burgundy,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(80)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (topUsers.length > 1) _buildPodiumAvatar(topUsers[1], "2", 80),
          if (topUsers.isNotEmpty) _buildPodiumAvatar(topUsers[0], "1", 110, isWinner: true),
          if (topUsers.length > 2) _buildPodiumAvatar(topUsers[2], "3", 80),
        ],
      ),
    );
  }

  Widget _buildPodiumAvatar(LeaderboardUser user, String rank, double height, {bool isWinner = false}) {
    return Column(
      children: [
        CircleAvatar(
          radius: isWinner ? 45 : 35,
          backgroundColor: AppColors.pinkAccent.withOpacity(0.3),
          child: CircleAvatar(
            radius: isWinner ? 40 : 30,
            backgroundColor: Colors.white,
            backgroundImage: (user.profileImg != null && user.profileImg!.isNotEmpty)
                ? NetworkImage(user.profileImg!)
                : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          user.name,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
        ),
        // عرض اللقب هنا تحت الاسم في المنصة
        Text(
          user.nickname ?? "قارئ دُفّة",
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
        const SizedBox(height: 10),
        Container(
          width: 50,
          height: height,
          decoration: BoxDecoration(
            color: isWinner ? AppColors.pinkAccent : Colors.white24,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(rank, style: GoogleFonts.katibeh(color: Colors.white, fontSize: 24)),
          ),
        ),
      ],
    );
  }

  // --- كرت المستخدم في القائمة السفلية مع عرض اللقب وعدد الكتب ---
  Widget _buildLeaderboardCard({required LeaderboardUser user}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.textFieldFill,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage: (user.profileImg != null && user.profileImg!.isNotEmpty)
                ? NetworkImage(user.profileImg!)
                : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                // عرض اللقب وعدد الكتب معاً هنا
                Text(
                  "${user.nickname ?? 'قارئ'} • ${user.booksRead} كتب",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          _followButton(user.id),
        ],
      ),
    );
  }

  Widget _followButton(int userId) {
    return InkWell(
      onTap: () => debugPrint("طلب متابعة للمستخدم: $userId"),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.pinkAccent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          "متابعة",
          style: GoogleFonts.katibeh(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildTabSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _tabItem("الكل", true),
          _tabItem("الذين أتابعهم", false),
        ],
      ),
    );
  }

  Widget _tabItem(String title, bool isActive) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: isActive ? AppColors.burgundy : Colors.grey,
            fontSize: 18,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        if (isActive) Container(height: 2, width: 40, color: AppColors.burgundy),
      ],
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 50, color: Colors.red),
          Text(error),
          ElevatedButton(
            onPressed: _loadData,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.burgundy),
            child: const Text("إعادة المحاولة", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}