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
  int _currentPage = 1;
  int _pageCount = 0;
  bool _isLoading = true;
  @override
  void dispose() {
    _pdfViewerController.dispose();
    super.dispose();
  }

  void _handleNextPage() {
    if (_currentPage < _pageCount) {
      _pdfViewerController.jumpToPage(_currentPage + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
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
          ),
          body: Opacity(
            opacity: _isLoading ? 0.0 : 1.0,
            child: SfPdfViewerTheme(
              data: SfPdfViewerThemeData(
                backgroundColor: AppColors.textFieldFill,
              ),
              child: SfPdfViewer.network(
                widget.pdfUrl,
                controller: _pdfViewerController,
                pageLayoutMode: PdfPageLayoutMode.single,
                scrollDirection: PdfScrollDirection.horizontal,
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
              ),
            ),
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
                      _currentPage > 1
                          ? FloatingActionButton.small(
                              heroTag: 'prev',
                              backgroundColor: AppColors.burgundy.withOpacity(
                                0.4,
                              ),
                              onPressed: () => _pdfViewerController.jumpToPage(
                                _currentPage - 1,
                              ),
                              child: const Icon(
                                Icons.chevron_left_rounded,
                                size: 28,
                              ),
                            )
                          : const SizedBox.shrink(),
                      FloatingActionButton.small(
                        heroTag: 'next',
                        backgroundColor: AppColors.burgundy.withOpacity(0.4),
                        onPressed: _handleNextPage,
                        child: const Icon(
                          Icons.chevron_right_rounded,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
