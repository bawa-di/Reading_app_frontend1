class UserProfileModel {
  final int id;
  final String name;
  final String email;
  final String? nickname; 
  final String? profileImg;
  final int? totalPoints;
  final UserStats? stats; 

  UserProfileModel({
    required this.id,
    required this.name,
    required this.email,
    this.nickname,
    this.profileImg,
    this.totalPoints,
    this.stats,
  });

  // 🛠️ التعديل الذكي لتركيب مسار الـ public/storage الصحيح بناءً على بنية مجلداتكِ
  String? get fullProfileImgUrl {
    if (profileImg == null || profileImg!.isEmpty) return null;
    
    final String serverIp = "http://192.168.34.216:8000"; 
    
    // تنظيف السلاش الأول إن وجد
    String cleanPath = profileImg!.startsWith('/') ? profileImg!.substring(1) : profileImg!;
    
    // 🔄 بما أن المجلد داخل public/storage، نتأكد من إضافة كلمة storage للمسار
    if (!cleanPath.startsWith('storage/')) {
      cleanPath = 'storage/$cleanPath';
    }
    
    return "$serverIp/$cleanPath";
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> dataMap = json.containsKey('data') 
        ? json['data'] 
        : json;

    return UserProfileModel(
      id: dataMap['id'] ?? 0,
      name: dataMap['name'] ?? '',
      email: dataMap['email'] ?? '',
      nickname: dataMap['nickname'], 
      profileImg: dataMap['profile_img'],
      totalPoints: dataMap['total_points'] ?? 0,
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