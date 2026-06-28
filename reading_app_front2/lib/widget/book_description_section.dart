import 'package:flutter/material.dart';
import 'package:reading_app_front2/conset_app.dart';

class BookDescriptionSection extends StatelessWidget {
  final bool isLoading, isExpanded;
  final String errorMessage;
  final String? description;
  final VoidCallback onToggle;

  const BookDescriptionSection({
    super.key,
    required this.isLoading,
    required this.errorMessage,
    this.description,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('لمحة عن الكتاب', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.burgundy)),
            IconButton(
              onPressed: onToggle,
              icon: Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: AppColors.burgundy),
            ),
          ],
        ),
        if (isLoading && (description == null || description!.isEmpty))
          const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(color: AppColors.burgundy)))
        else if (errorMessage.isNotEmpty && (description == null || description!.isEmpty))
          Text(errorMessage, style: const TextStyle(color: Colors.red))
        else
          AnimatedCrossFade(
            firstChild: const SizedBox(),
            secondChild: Container(
              width: double.infinity, margin: const EdgeInsets.only(top: 10), padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: Text(
                (description != null && description!.isNotEmpty) ? description! : 'لا يوجد وصف متاح لهذا الكتاب حالياً.',
                style: TextStyle(color: Colors.grey.shade800, height: 1.7, fontSize: 14.5),
              ),
            ),
            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
      ],
    );
  }
}