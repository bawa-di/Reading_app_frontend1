class LeaderboardUser {
  final int id; // أضفنا الـ id هنا
  final String name;
  final String nickname;
  final int booksRead;
  final String? profileImg;

  LeaderboardUser({
    required this.id,
    required this.name,
    required this.nickname,
    required this.booksRead,
    this.profileImg,
  });

  factory LeaderboardUser.fromJson(Map<String, dynamic> json) {
    return LeaderboardUser(
      id: json['id'], // التأكد من جلب الـ id من الـ JSON القادم من لارافيل
      name: json['name'] ?? 'مستخدم مجهول',
      nickname: json['nickname'] ?? 'قارئ',
      booksRead: json['books_read'] ?? 0,
      profileImg: json['profile_img'],
    );
  }
}