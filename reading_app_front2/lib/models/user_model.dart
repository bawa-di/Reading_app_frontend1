class UserModel {
  final int id;
  final String name;
  final String email;
  final String? profileImg;

  UserModel({required this.id, required this.name, required this.email, this.profileImg});

  // تحويل JSON القادم من لارافل إلى كائن Dart
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      profileImg: json['profile_img'],
    );
  }
}