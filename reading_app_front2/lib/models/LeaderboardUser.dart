import 'package:flutter/material.dart';
import 'package:reading_app_front2/models/book.dart';

class LeaderboardUser {
  final int id;
  final String name;
  final String nickname;
  final String? profileImg;
  bool? isFollowing;

  final int finishedCount;
  final int readingNowCount;
  final int wantToReadCount;
  final int booksReadCount; 

  final List<Book> wantToReadBooks;
  final List<Book> readingNowBooks;
  final List<Book> finishedBooks;

  LeaderboardUser({
    required this.id,
    required this.name,
    required this.nickname,
    this.profileImg,
    this.isFollowing,
    this.finishedCount = 0,
    this.readingNowCount = 0,
    this.wantToReadCount = 0,
    this.booksReadCount = 0,
    this.wantToReadBooks = const [],
    this.readingNowBooks = const [],
    this.finishedBooks = const [],
  });

  factory LeaderboardUser.fromJson(Map<String, dynamic> json) {
    // 1. دالة مساعدة لتحويل القيم إلى أرقام
    int parseCount(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    // 2. التعامل مع البيانات (بدون افتراض وجود مفتاح 'data')
    final Map<String, dynamic> data = json;

    final stats = data['stats'] is Map ? (data['stats'] as Map<String, dynamic>) : {};
    final lists = data['reading_lists'] is Map ? (data['reading_lists'] as Map<String, dynamic>) : {};

    // 3. دالة معالجة الكتب المحسنة
    List<Book> parseBooks(dynamic list) {
      if (list == null || list is! List) return [];
      List<Book> validBooks = [];
      for (var item in list) {
        if (item is Map) {
          try {
            // التحقق مما إذا كان الكتاب داخل مفتاح 'book' أو هو الكائن نفسه
            if (item.containsKey('book') && item['book'] is Map) {
              validBooks.add(Book.fromJson(item['book'] as Map<String, dynamic>));
            } else {
              validBooks.add(Book.fromJson(item as Map<String, dynamic>));
            }
          } catch (e) {
            debugPrint("خطأ في قراءة كائن كتاب: $e");
            continue; 
          }
        }
      }
      return validBooks;
    }

    return LeaderboardUser(
      id: data['id'] ?? 0,
      name: data['name'] ?? 'مستخدم مجهول',
      nickname: data['nickname'] ?? 'قارئ جليس',
      profileImg: data['profile_img'],
      // دعم كل من Boolean و Integer (لأن لارفل قد ترسل 1 أو 0)
      isFollowing: data['is_following'] == true || data['is_following'] == 1,
      
      finishedCount: parseCount(stats['finished_count']),
      readingNowCount: parseCount(stats['reading_now_count']),
      wantToReadCount: parseCount(stats['want_to_read_count']),
      booksReadCount: parseCount(stats['finished_count']),
      
      wantToReadBooks: parseBooks(lists['want_to_read']),
      readingNowBooks: parseBooks(lists['reading_now']),
      finishedBooks: parseBooks(lists['finished']),
    );
  }
}