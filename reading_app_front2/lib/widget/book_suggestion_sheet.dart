import 'package:flutter/material.dart';
import 'package:reading_app_front2/pages/SuggestBookScreen.dart';

void showBookSuggestionBottomSheet(BuildContext context, int bookId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: BookSuggestionSheet(relatedBookId: bookId),
      );
    },
  );
}