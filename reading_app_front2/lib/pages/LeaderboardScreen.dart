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
      _loadInitialData();
    });
  }

  void _loadInitialData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final String? token = userProvider.token;
    if (token != null && token.isNotEmpty) {
      final lp = Provider.of<LeaderboardProvider>(context, listen: false);
      lp.fetchLeaderboard(token);
      lp.fetchFollowing(token);
      lp.fetchFollowers(token);
    }
  }

  void _showUserDetails(int userId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UserDetailsSheet(userId: userId),
    );
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text("مجتمعي", style: GoogleFonts.katibeh(color: Colors.white, fontSize: 30)),
          centerTitle: true,
        ),
        body: Consumer2<LeaderboardProvider, UserProvider>(
          builder: (context, leaderboardProvider, userProvider, child) {
            if (leaderboardProvider.isLoading) {
              return const Center(child: CircularProgressIndicator(color: AppColors.burgundy));
            }

            final String? token = userProvider.token;
            final int? myId = userProvider.user?.id;
            List<LeaderboardUser> displayedUsers;
            
            if (currentTab == "أتابعهم") displayedUsers = leaderboardProvider.followingUsers;
            else if (currentTab == "المتابعون") displayedUsers = leaderboardProvider.followersUsers;
            else displayedUsers = leaderboardProvider.users.where((u) => u.id != myId).toList();

            final topThree = leaderboardProvider.users.take(3).toList();

            return Column(
              children: [
                _buildPodiumSection(topThree),
                _buildTabSelector(),
                Expanded(
                  child: ListView.builder(
                    itemCount: displayedUsers.length,
                    itemBuilder: (context, index) => _buildLeaderboardCard(
                      user: displayedUsers[index],
                      token: token ?? "",
                    ),
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
      padding: const EdgeInsets.fromLTRB(10, 20, 10, 30),
      decoration: const BoxDecoration(color: AppColors.burgundy, borderRadius: BorderRadius.vertical(bottom: Radius.circular(45))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // المركز الثاني (نجمتان)
          if (topUsers.length > 1) _buildPodiumAvatar(topUsers[1], "2", 80, stars: 2),
          // المركز الأول (3 نجوم)
          if (topUsers.isNotEmpty) _buildPodiumAvatar(topUsers[0], "1", 110, isWinner: true, stars: 3),
          // المركز الثالث (نجمة واحدة)
          if (topUsers.length > 2) _buildPodiumAvatar(topUsers[2], "3", 80, stars: 1),
        ],
      ),
    );
  }

  Widget _buildPodiumAvatar(LeaderboardUser user, String rank, double height, {bool isWinner = false, int stars = 0}) {
    return GestureDetector(
      onTap: () => _showUserDetails(user.id),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.topCenter,
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: isWinner ? 45 : 35,
                backgroundColor: isWinner ? AppColors.pinkAccent : AppColors.pinkAccent.withOpacity(0.7),
                child: CircleAvatar(
                  radius: isWinner ? 40 : 30,
                  backgroundImage: (user.profileImg != null && user.profileImg!.isNotEmpty)
                      ? NetworkImage(user.profileImg!)
                      : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                ),
              ),
              // رسم النجوم فوق الصورة
              if (stars > 0)
                Positioned(
                  top: -18,
                  child: Row(
                    children: List.generate(stars, (index) => const Icon(Icons.star, color: AppColors.creamBackground, size: 22)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(user.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Container(
            width: 50, height: height,
            decoration: BoxDecoration(color: isWinner ? AppColors.pinkAccent : Colors.white24, borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text(rank, style: GoogleFonts.katibeh(color: Colors.white, fontSize: 24))),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardCard({required LeaderboardUser user, required String token}) {
    return GestureDetector(
      onTap: () => _showUserDetails(user.id),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            CircleAvatar(radius: 25, backgroundImage: (user.profileImg != null && user.profileImg!.isNotEmpty) ? NetworkImage(user.profileImg!) : const AssetImage('assets/images/default_avatar.png') as ImageProvider),
            const SizedBox(width: 15),
            Expanded(child: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold))),
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
        children: ["الكل", "أتابعهم", "المتابعون"].map((title) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: _tabItem(title),
        )).toList(),
      ),
    );
  }

  Widget _tabItem(String title) {
    bool isActive = currentTab == title;
    return GestureDetector(
      onTap: () => setState(() => currentTab = title),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: isActive ? AppColors.burgundy : Colors.grey, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
          if (isActive) Container(height: 3, width: 20, color: AppColors.burgundy)
        ],
      ),
    );
  }

  Widget _followButton(LeaderboardUser user, String token) {
    return Consumer<LeaderboardProvider>(
      builder: (context, provider, child) {
        bool isFollowing = user.isFollowing ?? false;
        return InkWell(
          onTap: () => provider.toggleFollow(token, user),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: isFollowing ? Colors.transparent : AppColors.burgundy,
              border: isFollowing ? Border.all(color: AppColors.burgundy) : null,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(isFollowing ? "إلغاء" : "متابعة", style: TextStyle(color: isFollowing ? AppColors.burgundy : Colors.white)),
          ),
        );
      },
    );
  }
}