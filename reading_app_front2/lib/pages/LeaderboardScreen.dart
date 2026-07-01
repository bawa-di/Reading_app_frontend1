import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:reading_app_front2/conset_app.dart';
import 'package:reading_app_front2/models/LeaderboardUser.dart';
import 'package:reading_app_front2/pages/user_details_sheet.dart';
import 'package:reading_app_front2/provider/leaderboard_provider.dart';
import 'package:reading_app_front2/provider/user_provider.dart';

class LeaderboardScreen extends StatefulWidget {
  static String id = 'LeaderboardScreen';
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  String currentTab = "الكل";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = Provider.of<UserProvider>(context, listen: false).token;
      if (token != null) {
        final lp = Provider.of<LeaderboardProvider>(context, listen: false);
        lp.fetchLeaderboard(token);
        lp.fetchFollowing(token);
        lp.fetchFollowers(token);
      }
    });
  }

  Future<void> _showUserDetails(LeaderboardUser user) async {
    final token = Provider.of<UserProvider>(context, listen: false).token ?? "";
    final lp = Provider.of<LeaderboardProvider>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.burgundy),
      ),
    );

    final details = await lp.fetchUserDetails(token, user.id);
    if (mounted) Navigator.pop(context);

    if (details != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserDetailsSheet(user: user, details: details),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("فشل في تحميل بيانات المستخدم")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.creamBackground,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "مجتمعي",
            style: GoogleFonts.katibeh(color: Colors.white, fontSize: 30),
          ),
          centerTitle: true,
          backgroundColor: AppColors.burgundy,
        ),
        body: Consumer2<LeaderboardProvider, UserProvider>(
          builder: (context, lp, up, child) {
            if (lp.isLoading)
              return const Center(
                child: CircularProgressIndicator(color: AppColors.burgundy),
              );

            List<LeaderboardUser> displayed = currentTab == "أتابعهم"
                ? lp.followingUsers
                : currentTab == "المتابعون"
                ? lp.followersUsers
                : lp.users.where((u) => u.id != up.user?.id).toList();

            return Column(
              children: [
                _buildPodiumSection(lp.users.take(3).toList()),
                _buildTabSelector(),
                Expanded(
                  child: ListView.builder(
                    itemCount: displayed.length,
                    itemBuilder: (context, index) =>
                        _buildLeaderboardCard(displayed[index], up.token ?? ""),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPodiumSection(List<LeaderboardUser> topUsers) {
    return Container(
      padding: const EdgeInsets.fromLTRB(7, 10, 10, 20),
      decoration: const BoxDecoration(
        color: AppColors.burgundy,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(45)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (topUsers.length > 1)
            _buildPodiumAvatar(topUsers[1], "2", 80, stars: 2),
          if (topUsers.isNotEmpty)
            _buildPodiumAvatar(topUsers[0], "1", 110, isWinner: true, stars: 3),
          if (topUsers.length > 2)
            _buildPodiumAvatar(topUsers[2], "3", 80, stars: 1),
        ],
      ),
    );
  }

  Widget _buildPodiumAvatar(
    LeaderboardUser user,
    String rank,
    double height, {
    bool isWinner = false,
    required int stars,
  }) {
    return GestureDetector(
      onTap: () => _showUserDetails(user),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              stars,
              (index) =>
                  const Icon(Icons.star, color: AppColors.pinkAccent, size: 25),
            ),
          ),
          const SizedBox(height: 5),
          CircleAvatar(
            radius: isWinner ? 45 : 35,
            backgroundColor: Colors.white24,
            child: CircleAvatar(
              radius: isWinner ? 40 : 30,
              backgroundImage: user.profileImg != null
                  ? NetworkImage(user.profileImg!)
                  : null,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            user.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          // اللقب في الـ Podium فقط:
          Text(
            user.nickname ?? "قارئ",
            style: const TextStyle(
              color: AppColors.textFieldFill,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            width: 50,
            height: height,
            decoration: BoxDecoration(
              color: isWinner ? AppColors.pinkAccent : Colors.white24,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                rank,
                style: GoogleFonts.katibeh(color: Colors.white, fontSize: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardCard(LeaderboardUser user, String token) {
    return GestureDetector(
      onTap: () => _showUserDetails(user),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage: user.profileImg != null
                  ? NetworkImage(user.profileImg!)
                  : null,
            ),
            const SizedBox(width: 15),
            // تم إزالة الـ Column واللقب من هنا:
            Expanded(
              child: Text(
                user.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            _followButton(user, token),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: ["الكل", "أتابعهم", "المتابعون"]
            .map(
              (t) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: _tabItem(t),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _tabItem(String title) {
    bool isActive = currentTab == title;
    return GestureDetector(
      onTap: () => setState(() => currentTab = title),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: isActive ? AppColors.burgundy : Colors.grey,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (isActive)
            Container(height: 3, width: 20, color: AppColors.burgundy),
        ],
      ),
    );
  }

  Widget _followButton(LeaderboardUser user, String token) {
    return Consumer<LeaderboardProvider>(
      builder: (context, provider, child) {
        LeaderboardUser updatedUser = provider.users.firstWhere(
          (u) => u.id == user.id,
          orElse: () => user,
        );
        bool isFollowing = updatedUser.isFollowing ?? false;
        return InkWell(
          onTap: () => provider.toggleFollow(token, updatedUser),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: isFollowing ? Colors.transparent : AppColors.burgundy,
              border: isFollowing
                  ? Border.all(color: AppColors.burgundy)
                  : null,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isFollowing ? "إلغاء" : "متابعة",
              style: TextStyle(
                color: isFollowing ? AppColors.burgundy : Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}
