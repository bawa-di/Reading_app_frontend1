import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:reading_app_front2/conset_app.dart';
import 'package:reading_app_front2/models/book.dart';
import 'package:reading_app_front2/models/LeaderboardUser.dart';
import 'package:reading_app_front2/provider/leaderboard_provider.dart';
import 'package:reading_app_front2/provider/user_provider.dart';
import 'package:reading_app_front2/widget/book_card.dart';

class UserDetailsSheet extends StatefulWidget {
  final LeaderboardUser user;
  final Map<String, dynamic> details;

  const UserDetailsSheet({
    super.key,
    required this.user,
    required this.details,
  });

  @override
  State<UserDetailsSheet> createState() => _UserDetailsSheetState();
}

class _UserDetailsSheetState extends State<UserDetailsSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final leaderboardProvider = Provider.of<LeaderboardProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      // استخراج الـ ID الخاص بكِ من UserProvider
      final int? myId = userProvider.currentUserId; 

      // 1. التحقق إذا كان المستخدم هو صاحب الحساب
      final bool isOwner = (myId != null && myId == widget.user.id);
      
      // 2. التحقق إذا كان المستخدم ضمن قائمة المتابَعين
      final bool isFollowed = leaderboardProvider.followingUsers.any((u) => u.id == widget.user.id);
      
      // منع الدخول إذا لم يتحقق أي من الشرطين
      if (!isOwner && !isFollowed) {
        Navigator.pop(context); 
        _showCustomSnackBar("يمكنك فقط عرض ملفك الشخصي أو ملفات من تتابعهم");
      }
    });
  }

  // دالة الـ SnackBar الموحدة
  void _showCustomSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        backgroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(color: AppColors.burgundy, width: 2.0),
        ),
        content: Text(
          message,
          textAlign: TextAlign.right,
          style: const TextStyle(
            color: AppColors.burgundy,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lists = widget.details['reading_lists'];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.creamBackground,
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 60, bottom: 20, left: 20, right: 20),
              decoration: const BoxDecoration(
                color: AppColors.burgundy,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundImage: NetworkImage(widget.user.profileImg ?? ""),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.user.name,
                              style: GoogleFonts.katibeh(fontSize: 26, color: Colors.white),
                            ),
                            Text(
                              widget.user.nickname ?? "قارئ",
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.creamBackground,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: Colors.white.withOpacity(0.5)),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      dividerColor: Colors.transparent,
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: AppColors.burgundy.withOpacity(0.6),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: AppColors.burgundy,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      tabs: const [
                        Tab(text: "المقروءة"),
                        Tab(text: "يقرأ حالياً"),
                        Tab(text: "يريد قراءتها"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildBookList(lists['finished']),
                  _buildBookList(lists['reading_now']),
                  _buildBookList(lists['want_to_read']),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookList(dynamic list) {
    if (list == null || (list as List).isEmpty) {
      return Center(
        child: Text(
          "لا توجد كتب في هذه القائمة",
          style: GoogleFonts.katibeh(fontSize: 20, color: AppColors.burgundy),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 20),
      itemCount: list.length,
      itemBuilder: (context, i) {
        final bookData = list[i]['book'];
        return BookCard(book: Book.fromJson(bookData));
      },
    );
  }
}