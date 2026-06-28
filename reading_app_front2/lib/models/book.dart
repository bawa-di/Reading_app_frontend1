import 'package:flutter/material.dart';

// 🟢 كلاس مركزي لإدارة الروابط والـ Base URL
class ApiConstants {
  static const String baseUrl = 'http://192.168.34.216:8000'; 
  static const String baseApiUrl = '$baseUrl/api';
  static const String bookImagesUrl = '$baseUrl/books/images/';
  static const String baseBookPdfsUrl = '$baseUrl/books/pdfs/';
}

// 🟢 كلاس التصنيفات المحدث
class Genre {
  final int id;
  final String name;

  Genre({required this.id, required this.name});

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

// 🟢 كلاس الكتاب الآمن والمكتمل تماماً والمعدل لدعم كل التصنيفات والكتب المشابهة
class Book {
  final int id;
  final String title;
  final String author;
  final String? coverImagePath; 
  final String? pdfPath;         
  final String? category;       // يحتوي على جميع التصنيفات مدمجة بنص واحد للسهولة
  final List<Genre>? geners;    // مطابقة لتسمية الباك-إند الحالي
  final String? description;
  
  // القيمة قابلة للتعديل حياً في الذاكرة
  double rating;
  
  final int? pages;             
  final double? readingProgress;
  String? readingStatus;        // الحقل الخاص بحالة القراءة لمنع أخطاء الواجهات

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
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    
    // 1. تحويل مصفوفة الـ geners بالكامل بشكل آمن أولاً
    List<Genre>? parsedGeners;
    if (json['geners'] != null) {
      parsedGeners = (json['geners'] as List)
          .map((genreJson) => Genre.fromJson(genreJson))
          .toList();
    }

    // 2. دمج كافة أسماء التصنيفات في نص واحد للواجهات البسيطة
    String? combinedCategoryNames;
    if (parsedGeners != null && parsedGeners.isNotEmpty) {
      combinedCategoryNames = parsedGeners.map((g) => g.name).join('، ');
    }

    // 3. بناء مسار الصورة بالاعتماد على الـ ApiConstants
    String? rawCover = json['cover_img'] ?? json['cover_image'] ?? json['image'];
    String? fullCoverPath;

    if (rawCover != null && rawCover.toString().trim().isNotEmpty) {
      String coverStr = rawCover.toString().trim();
      if (!coverStr.startsWith('http')) {
        String fileName = coverStr
            .replaceAll('public/', '')
            .replaceAll('books/images/', '');
        
        fullCoverPath = '${ApiConstants.bookImagesUrl}$fileName'; 
      } else {
        fullCoverPath = coverStr;
      }
    }

    // 4. بناء مسار الـ PDF بالاعتماد على الـ ApiConstants
    String? rawPdf = json['pdf_path'];
    String? fullPdfPath;
    
    if (rawPdf != null && rawPdf.toString().trim().isNotEmpty) {
      String pdfStr = rawPdf.toString().trim();
      if (!pdfStr.startsWith('http')) {
        String pdfName = pdfStr
            .replaceAll('public/', '')
            .replaceAll('books/pdfs/', '');
            
        fullPdfPath = '${ApiConstants.baseBookPdfsUrl}$pdfName';
      } else {
        fullPdfPath = pdfStr;
      }
    }

    return Book(
      id: json['id'] ?? 0, 
      title: json['title'] ?? 'بدون عنوان',
      author: json['author'] ?? 'مؤلف مجهول',
      coverImagePath: fullCoverPath, 
      pdfPath: fullPdfPath,          
      category: combinedCategoryNames ?? 'عام', 
      geners: parsedGeners ?? [], // مصفوفة فارغة بدلاً من null لتجنب كراش الواجهات في الكتب المشابهة
      description: json['description'] ?? '',
      
      // تأمين قراءة التقييم؛ إن لم يرسله الباك (مثل الكتب المشابهة) يضع 0.0 بدلاً من كراش
      rating: (json['average_rating'] is num) 
          ? (json['average_rating'] as num).toDouble() 
          : 0.0,
          
      // ✨ التعديل الذكي لحقل الصفحات المتغير بين الكتاب الرئيسي (PageNumber) والكتب المشابهة
      pages: (json['PageNumber'] is num) 
          ? (json['PageNumber'] as num).toInt() 
          : ((json['pages'] is num) ? (json['pages'] as num).toInt() : null), 
          
      readingProgress: json['reading_progress'] != null ? (json['reading_progress'] as num).toDouble() : null,
      readingStatus: json['reading_status'] ?? json['status'], 
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
      'geners': geners?.map((g) => g.toJson()).toList(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Book && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}