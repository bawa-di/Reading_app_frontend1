import 'package:flutter/material.dart';
import 'package:reading_app_front2/conset_app.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class BookPdfViewerPage extends StatefulWidget {
  final String pdfUrl;
  final String bookTitle;

  const BookPdfViewerPage({
    super.key,
    required this.pdfUrl,
    required this.bookTitle,
  });

  @override
  State<BookPdfViewerPage> createState() => _BookPdfViewerPageState();
}

class _BookPdfViewerPageState extends State<BookPdfViewerPage> {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  late PageController _pageController;

  int _currentPage = 1;
  int _pageCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pdfViewerController.dispose();
    super.dispose();
  }

  void _navigateToPage(int targetPage) {
    if (targetPage < 1 || targetPage > _pageCount) return;
    _pdfViewerController.jumpToPage(targetPage);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      // 💡 الحل الجذري للون النهدي: تغليف الشاشة بـ Theme مخصص يصفر ويغير ألوان الخلفية لـ مكوّنات الماتيريال داخلياً
      child: Theme(
        data: Theme.of(context).copyWith(
          scaffoldBackgroundColor: AppColors.creamBackground,
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: AppColors.textFieldFill,
            surface: AppColors.textFieldFill,
          ),
        ),
        child: Scaffold(
          backgroundColor: AppColors.textFieldFill,
          appBar: AppBar(
            title: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.bookTitle,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (!_isLoading && _pageCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      'صفحة $_currentPage من $_pageCount',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textFieldFill.withOpacity(0.75),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            backgroundColor: AppColors.burgundy,
            foregroundColor: AppColors.textFieldFill,
            centerTitle: true,
            toolbarHeight: 70,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            // ❌ تم إزالة شريط التقدم الأصفر (LinearProgressIndicator) تماماً من هنا
          ),
          body: Stack(
            children: [
              Opacity(
                opacity: _isLoading ? 0.0 : 1.0,
                child: NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification notification) {
                    return false;
                  },
                  child: SfPdfViewerTheme(
                    data: SfPdfViewerThemeData(
                      backgroundColor: AppColors.textFieldFill, 
                    ),
                    child: SfPdfViewer.network(
                      widget.pdfUrl,
                      controller: _pdfViewerController,
                      pageLayoutMode: PdfPageLayoutMode.single,
                      scrollDirection: PdfScrollDirection.horizontal,
                      canShowPageLoadingIndicator: false,
                      canShowScrollHead: false,
                      canShowScrollStatus: false,
                      onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                        setState(() {
                          _pageCount = details.document.pages.count;
                          _isLoading = false;
                        });
                      },
                      onPageChanged: (PdfPageChangedDetails details) {
                        setState(() {
                          _currentPage = details.newPageNumber;
                        });
                      },
                      onDocumentLoadFailed:
                          (PdfDocumentLoadFailedDetails details) {
                        setState(() {
                          _isLoading = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'فشل تحميل ملف الـ PDF: ${details.description}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              if (_isLoading)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        color: AppColors.burgundy,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'جاري تجهيز صفحات الكتاب لمطالعتك...',
                        style: TextStyle(
                          color: AppColors.burgundy,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: _isLoading
              ? null
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentPage > 1)
                        FloatingActionButton.small(
                          heroTag: 'prev_page',
                          backgroundColor: AppColors.burgundy.withOpacity(0.4),
                          foregroundColor: AppColors.textFieldFill,
                          onPressed: () =>
                              _navigateToPage(_currentPage - 1),
                          child: const Icon(Icons.chevron_left_rounded,
                              size: 28),
                        )
                      else
                        const SizedBox.shrink(),
                      if (_currentPage < _pageCount)
                        FloatingActionButton.small(
                          heroTag: 'next_page',
                          backgroundColor: AppColors.burgundy.withOpacity(0.4),
                          foregroundColor: AppColors.textFieldFill,
                          onPressed: () =>
                              _navigateToPage(_currentPage + 1),
                          child: const Icon(Icons.chevron_right_rounded,
                              size: 28),
                        )
                      else
                        const SizedBox.shrink(),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}