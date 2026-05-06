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

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    // التحقق من مكان البيانات: 
    // إذا كان الـ JSON يحتوي على مفتاح 'data' (مثل تعديل الباك إند الجديد لصفحة الشخصية)
    // نستخدمه، وإلا نستخدم الـ json نفسه (مثل حالة تسجيل الدخول) لضمان عدم توقف الربط القديم.
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
      
      // قراءة الإحصائيات إذا كانت موجودة في الـ JSON (اختياري)
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