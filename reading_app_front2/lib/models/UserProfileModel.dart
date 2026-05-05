class UserProfileModel {
  final int id;
  final String name;
  final String email;
  final String? nickname; // جعلناه اختيارياً لأنه قد لا يصل في اللوج إن
  final String? profileImg;
  final int? totalPoints;
  final UserStats? stats; // جعلناه اختيارياً

  UserProfileModel({
    required this.id,
    required this.name,
    required this.email,
    this.nickname,
    this.profileImg,
    this.totalPoints,
    this.stats,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      // ملاحظة: أزلنا ['data'] لأننا نمرر الجزء الخاص بالمستخدم مباشرة
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      nickname: json['nickname'], 
      profileImg: json['profile_img'],
      totalPoints: json['total_points'] ?? 0,
      // لا نستدعي stats إلا إذا كانت موجودة في الـ JSON
      stats: json['stats'] != null ? UserStats.fromJson(json['stats']) : null,
    );
  }
}

class UserStats {
  final int wantToRead;
  final int readingNow;
  final int finished;

  UserStats({
    required this.wantToRead,
    required this.readingNow,
    required this.finished,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      wantToRead: json['want_to_read_count'] ?? 0,
      readingNow: json['reading_now_count'] ?? 0,
      finished: json['finished_count'] ?? 0,
    );
  }
}