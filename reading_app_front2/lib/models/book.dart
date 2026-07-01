import 'package:flutter/material.dart';

// 🟢 كلاس مركزي لإدارة الروابط
class ApiConstants {
  static const String baseUrl = 'http://192.168.34.216:8000';
  static const String baseApiUrl = '$baseUrl/api';
  static const String bookImagesUrl = '$baseUrl/books/images/';
  static const String baseBookPdfsUrl = '$baseUrl/books/pdfs/';
}

// 🟢 كلاس التصنيفات
class Genre {
  final int id;
  final String name;

  Genre({required this.id, required this.name});

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(id: json['id'] ?? 0, name: json['name'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

// 🟢 كلاس الكتاب (مُعدل بإضافة دالة copyWith)
class Book {
  final int id;
  final String title;
  final String author;
  final String? coverImagePath;
  final String? pdfPath;
  final String? category;
  final List<Genre>? geners;
  final String? description;
  double rating;
  final int? pages;
  final double? readingProgress;
  String? readingStatus;
  final String? accessType;
  final int? requiredBooksRead;
  final double price;
  final String? lockMessage;
  final bool hasPaid;

  Book({
    required this.id,
    required this.title,
    required this.author,
    this.coverImagePath,
    this.pdfPath,
    this.category,
    this.geners,
    this.description,
    this.rating = 4.5,
    this.pages,
    this.readingProgress,
    this.readingStatus,
    this.accessType,
    this.requiredBooksRead,
    this.price = 0.0,
    this.lockMessage,
    this.hasPaid = false,
  });

  // ✅ إضافة دالة copyWith للسماح بتعديل القيم (مثل hasPaid) مع الحفاظ على الـ final
  Book copyWith({
    bool? hasPaid,
    double? rating,
    String? readingStatus,
  }) {
    return Book(
      id: id,
      title: title,
      author: author,
      coverImagePath: coverImagePath,
      pdfPath: pdfPath,
      category: category,
      geners: geners,
      description: description,
      rating: rating ?? this.rating,
      pages: pages,
      readingProgress: readingProgress,
      readingStatus: readingStatus ?? this.readingStatus,
      accessType: accessType,
      requiredBooksRead: requiredBooksRead,
      price: price,
      lockMessage: lockMessage,
      hasPaid: hasPaid ?? this.hasPaid,
    );
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    // 1. معالجة التصنيفات
    List<Genre>? parsedGeners;
    if (json['geners'] != null) {
      parsedGeners = (json['geners'] as List)
          .map((genreJson) => Genre.fromJson(genreJson))
          .toList();
    }

    String? combinedCategoryNames;
    if (parsedGeners != null && parsedGeners.isNotEmpty) {
      combinedCategoryNames = parsedGeners.map((g) => g.name).join('، ');
    }

    // 2. معالجة الصور
    String? rawCover = json['cover_img'] ?? json['cover_image'] ?? json['image'];
    String? fullCoverPath;
    if (rawCover != null && rawCover.toString().trim().isNotEmpty) {
      String coverStr = rawCover.toString().trim();
      if (!coverStr.startsWith('http')) {
        String fileName = coverStr.replaceAll('public/', '').replaceAll('books/images/', '');
        fullCoverPath = '${ApiConstants.bookImagesUrl}$fileName';
      } else {
        fullCoverPath = coverStr;
      }
    }

    // 3. معالجة الـ PDF
    String? rawPdf = json['pdf_path'];
    String? fullPdfPath;
    if (rawPdf != null && rawPdf.toString().trim().isNotEmpty) {
      String pdfStr = rawPdf.toString().trim();
      if (!pdfStr.startsWith('http')) {
        String pdfName = pdfStr.replaceAll('public/', '').replaceAll('books/pdfs/', '');
        fullPdfPath = '${ApiConstants.baseBookPdfsUrl}$pdfName';
      } else {
        fullPdfPath = pdfStr;
      }
    }

    // 4. معالجة الحالة
    bool paidStatus = false;
    if (json.containsKey('has_paid')) {
      var val = json['has_paid'];
      if (val is bool) {
        paidStatus = val;
      } else if (val is int) {
        paidStatus = (val == 1);
      } else if (val is String) {
        paidStatus = (val.toLowerCase() == 'true' || val == '1');
      }
    }

    return Book(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'بدون عنوان',
      author: json['author'] ?? 'مؤلف مجهول',
      coverImagePath: fullCoverPath,
      pdfPath: fullPdfPath,
      category: combinedCategoryNames ?? 'عام',
      geners: parsedGeners ?? [],
      description: json['description'] ?? '',
      rating: (json['average_rating'] is num) ? (json['average_rating'] as num).toDouble() : 0.0,
      pages: (json['PageNumber'] is num) ? (json['PageNumber'] as num).toInt() : null,
      readingProgress: json['reading_progress'] != null ? (json['reading_progress'] as num).toDouble() : null,
      readingStatus: json['reading_status'] ?? json['status'],
      accessType: json['access_type'],
      requiredBooksRead: (json['required_books_read'] is num) ? (json['required_books_read'] as num).toInt() : null,
      price: (json['price'] != null) ? double.tryParse(json['price'].toString()) ?? 0.0 : 0.0,
      lockMessage: json['lock_message'],
      hasPaid: paidStatus,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'cover_image': coverImagePath,
      'pdf_path': pdfPath,
      'description': description,
      'average_rating': rating,
      'pages': pages,
      'reading_progress': readingProgress,
      'reading_status': readingStatus,
      'access_type': accessType,
      'required_books_read': requiredBooksRead,
      'price': price,
      'lock_message': lockMessage,
      'has_paid': hasPaid,
      'geners': geners?.map((g) => g.toJson()).toList(),
    };
  }
}