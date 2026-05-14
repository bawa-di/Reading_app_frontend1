class LeaderboardUser {
  final int id;
  final String name;
  final String nickname;
  final String? profileImg;
  bool? isFollowing;

  // حقول العدادات (Stats) - موحدة مع البروفايل الشخصي
  final int finishedCount;
  final int readingNowCount;
  final int wantToReadCount;

  LeaderboardUser({
    required this.id,
    required this.name,
    required this.nickname,
    this.profileImg,
    this.isFollowing,
    this.finishedCount = 0,
    this.readingNowCount = 0,
    this.wantToReadCount = 0,
  });

  factory LeaderboardUser.fromJson(Map<String, dynamic> json) {
    // دالة داخلية لتحويل القوائم أو القيم النصية إلى أرقام
    int parseCount(dynamic value) {
      if (value == null) return 0;
      if (value is List) return value.length; 
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    // الوصول إلى الإحصائيات (Stats)
    // في صفحة البحث أو الليدربورد، قد تصل البيانات داخل كائن 'stats' أو مباشرة
    final stats = json['stats'] ?? json;

    return LeaderboardUser(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'مستخدم مجهول',
      nickname: json['nickname'] ?? 'قارئ دُفّة',
      profileImg: json['profile_img'],
      // معالجة حالة المتابعة (سواء كانت 1/0 أو true/false)
      isFollowing: json['is_following'] == 1 || json['is_following'] == true,
      
      // توحيد المفاتيح مع ما استخدمناه في البروفايل الشخصي
      finishedCount: parseCount(stats['finished_count'] ?? stats['أنهيتها']),
      readingNowCount: parseCount(stats['reading_now_count'] ?? stats['أقرأها الآن']),
      wantToReadCount: parseCount(stats['want_to_read_count'] ?? stats['أرغب بقراءتها']),
    );
  }
}