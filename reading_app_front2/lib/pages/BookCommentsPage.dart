import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reading_app_front2/conset_app.dart';
import 'package:reading_app_front2/models/comment_model.dart';
import 'package:reading_app_front2/provider/comment_provider.dart';
import 'package:reading_app_front2/provider/user_provider.dart';

class BookCommentsPage extends StatefulWidget {
  final int bookId;
  const BookCommentsPage({super.key, required this.bookId});

  @override
  State<BookCommentsPage> createState() => _BookCommentsPageState();
}

class _BookCommentsPageState extends State<BookCommentsPage> {
  final TextEditingController _commentController = TextEditingController();

  // 🛠️ متغيرات التحكم بوضع الرد على التعليقات
  int? _replyingToCommentId;   // لتخزين الـ ID الخاص بالتعليق الذي نرد عليه
  String? _replyingToUserName; // لتخزين اسم المستخدم المراد الرد عليه

  @override
  void initState() {
    super.initState();
    // 🔄 جلب التعليقات تلقائياً من السيرفر فور الدخول للصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = Provider.of<UserProvider>(context, listen: false).token;
      if (token != null) {
        Provider.of<CommentProvider>(
          context,
          listen: false,
        ).fetchComments(bookId: widget.bookId, token: token);
      }
    });
  }

  @override
  void dispose() {
    _commentController.dispose(); // تنظيف الذاكرة عند الخروج من الصفحة
    super.dispose();
  }

  // 🗑️ دالة لإظهار تأكيد الحذف ومن ثم استدعاء البروفايدر لتحديث الواجهة فوراً
  void _showDeleteDialog(BuildContext context, int id, CommentProvider provider, String token) {
    // 1️⃣ أخذ نسخة آمنة من الـ ScaffoldMessenger قبل تدمير أي سياق (Context)
    final messenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: AppColors.creamBackground,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text(
              'حذف المراجعة',
              style: TextStyle(color: AppColors.burgundy, fontWeight: FontWeight.bold),
            ),
            content: const Text(
              'هل أنتِ متأكدة من رغبتكِ في حذف هذه المراجعة نهائياً؟ لا يمكن التراجع عن هذا الإجراء.',
              style: TextStyle(color: Colors.black87, fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.burgundy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  // إغلاق الـ Dialog أولاً باستخدام الـ context الخاص به
                  Navigator.pop(dialogContext); 

                  // إتمام عملية الحذف من السيرفر والانتظار
                  bool success = await provider.deleteComment(
                    commentId: id,
                    token: token,
                  );

                  // 2️⃣ حماية إضافية: التحقق من أن الصفحة الأصلية لا تزال معروضة ومستقرة
                  if (!mounted) return;

                  if (success) {
                    messenger.showSnackBar(
                      const SnackBar(content: Text('تم حذف المراجعة بنجاح')),
                    );
                  } else {
                    messenger.showSnackBar(
                      SnackBar(content: Text(provider.errorMessage)),
                    );
                  }
                },
                child: const Text('حذف'),
              ),
            ],
          ),
        );
      },
    );
  }

  // ✨ نافذة منبثقة لتعديل التعليق متناسقة مع ألوان "دُفّة"
  void _showEditBottomSheet(BuildContext context, dynamic item, CommentProvider provider, String token) {
    final TextEditingController editController = TextEditingController(text: item.content);
    final messenger = ScaffoldMessenger.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.creamBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 24,
              left: 24,
              right: 24,
              top: 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "تعديل المراجعة",
                  style: TextStyle(
                    color: AppColors.burgundy,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.textFieldFill,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.burgundy.withOpacity(0.3)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: editController,
                    maxLines: null,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.burgundy,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () async {
                          if (editController.text.trim().isEmpty) return;
                          Navigator.pop(bottomSheetContext); // إغلاق النافذة
                          
                          bool success = await provider.editComment(
                            commentId: item.id,
                            content: editController.text,
                            token: token,
                          );

                          if (!mounted) return;

                          if (!success) {
                            messenger.showSnackBar(
                              SnackBar(content: Text(provider.errorMessage)),
                            );
                          }
                        },
                        child: const Text("حفظ التعديل"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: () => Navigator.pop(bottomSheetContext),
                      child: const Text("إلغاء", style: TextStyle(color: Colors.grey)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final commentProvider = Provider.of<CommentProvider>(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.creamBackground,
        appBar: AppBar(
          title: const Text(
            "مراجعات القرّاء",
            style: TextStyle(color: AppColors.textFieldFill),
          ),
           shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        toolbarHeight: 70,
          titleTextStyle: AppTextStyles.headerStyle.copyWith(fontSize: 20),
          elevation: 0,
          backgroundColor: AppColors.burgundy,
          foregroundColor: AppColors.textFieldFill,
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Divider(
              color: AppColors.burgundy.withOpacity(0.1),
              height: 1,
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: commentProvider.isFetching
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.burgundy,
                      ),
                    )
                  : commentProvider.errorMessage.isNotEmpty
                      ? Center(
                          child: Text(
                            commentProvider.errorMessage,
                            style: const TextStyle(color: Colors.red, fontSize: 14),
                          ),
                        )
                      : commentProvider.comments.isEmpty
                          ? const Center(
                              child: Text(
                                "لا توجد تعليقات بعد.\nكن أول من يشارك رأيه!",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.burgundy,
                                  fontSize: 16,
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              itemCount: commentProvider.comments.length,
                              itemBuilder: (context, index) {
                                final comment = commentProvider.comments[index];
                                return _buildCommentCard(context, comment, commentProvider);
                              },
                            ),
            ),
            _buildCommentInputField(context, commentProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentCard(BuildContext context, CommentModel comment, CommentProvider commentProvider) {
    final token = Provider.of<UserProvider>(context, listen: false).token;
    final currentUserId = Provider.of<UserProvider>(context, listen: false).user?.id;
    final isMyComment = comment.userId == currentUserId;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.only(
        right: isMyComment ? 40 : 0,
        left: isMyComment ? 0 : 40,
      ),
      child: Column(
        crossAxisAlignment: isMyComment ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isMyComment ? AppColors.burgundy : AppColors.textFieldFill,
              borderRadius: BorderRadius.only(
                topRight: const Radius.circular(16),
                topLeft: const Radius.circular(16),
                bottomLeft: isMyComment ? const Radius.circular(16) : const Radius.circular(0),
                bottomRight: isMyComment ? const Radius.circular(0) : const Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.burgundy.withOpacity(0.03),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: isMyComment ? Colors.white.withOpacity(0.2) : AppColors.burgundy.withOpacity(0.2),
                      backgroundImage: comment.userImg != null ? NetworkImage(comment.userImg!) : null,
                      child: comment.userImg == null
                          ? Text(
                              comment.userName.isNotEmpty ? comment.userName[0].toUpperCase() : 'U',
                              style: TextStyle(
                                color: isMyComment ? Colors.white : AppColors.burgundy,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isMyComment ? " ${comment.userName}" : comment.userName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isMyComment ? Colors.white : AppColors.burgundy,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      comment.createdAt,
                      style: TextStyle(
                        color: isMyComment ? Colors.white70 : AppColors.burgundy.withOpacity(0.6),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    comment.content,
                    style: TextStyle(
                      fontSize: 14,
                      color: isMyComment ? Colors.white : Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: isMyComment
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.burgundy.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(6),
                          icon: const Icon(Icons.edit_rounded, size: 16, color: AppColors.burgundy),
                          onPressed: () {
                            _showEditBottomSheet(context, comment, commentProvider, token!);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.burgundy.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(6),
                          icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.burgundy),
                          onPressed: () {
                            _showDeleteDialog(context, comment.id, commentProvider, token!);
                          },
                        ),
                      ),
                    ],
                  )
                : TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _replyingToCommentId = comment.id;
                        _replyingToUserName = comment.userName;
                      });
                      FocusScope.of(context).requestFocus();
                    },
                    icon: const Icon(Icons.reply_rounded, size: 14, color: AppColors.burgundy),
                    label: const Text('رد', style: TextStyle(color: AppColors.burgundy, fontSize: 12)),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(50, 20),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
          ),
          if (comment.replies.isNotEmpty) ...[
            const SizedBox(height: 4),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comment.replies.length,
              itemBuilder: (context, rIndex) {
                final reply = comment.replies[rIndex];
                final isMyReply = reply.userId == currentUserId;

                return Container(
                  margin: const EdgeInsets.only(right: 16, bottom: 8),
                  child: Column(
                    crossAxisAlignment: isMyReply ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMyReply ? AppColors.burgundy.withOpacity(0.85) : AppColors.burgundy.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor: isMyReply ? Colors.white.withOpacity(0.2) : AppColors.burgundy,
                                  backgroundImage: reply.userImg != null ? NetworkImage(reply.userImg!) : null,
                                  child: reply.userImg == null
                                      ? Text(
                                          reply.userName.isNotEmpty ? reply.userName[0].toUpperCase() : 'R',
                                          style: const TextStyle(
                                            color: Colors.white, 
                                            fontSize: 10, 
                                            fontWeight: FontWeight.bold
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isMyReply ? " ${reply.userName}" : reply.userName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold, 
                                    fontSize: 12, 
                                    color: isMyReply ? Colors.white : AppColors.burgundy
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  reply.createdAt,
                                  style: TextStyle(
                                    color: isMyReply ? Colors.white70 : AppColors.burgundy.withOpacity(0.5), 
                                    fontSize: 9
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Text(
                                reply.content,
                                style: TextStyle(
                                  fontSize: 12, 
                                  color: isMyReply ? Colors.white : Colors.black87, 
                                  height: 1.4
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isMyReply)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.burgundy.withOpacity(0.05),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.all(4),
                                  icon: const Icon(Icons.edit_rounded, size: 14, color: AppColors.burgundy),
                                  onPressed: () {
                                    _showEditBottomSheet(context, reply, commentProvider, token!);
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.burgundy.withOpacity(0.05),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.all(4),
                                  icon: const Icon(Icons.delete_outline_rounded, size: 14, color: AppColors.burgundy),
                                  onPressed: () {
                                    _showDeleteDialog(context, reply.id, commentProvider, token!);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCommentInputField(BuildContext context, CommentProvider commentProvider) {
    final token = Provider.of<UserProvider>(context, listen: false).token;
    final messenger = ScaffoldMessenger.of(context);

    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24, top: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.burgundy,
            offset: const Offset(0, -4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_replyingToCommentId != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 4, right: 4),
              child: Row(
                children: [
                  Icon(Icons.reply_rounded, size: 16, color: AppColors.burgundy.withOpacity(0.7)),
                  const SizedBox(width: 4),
                  Text(
                    "أنتِ تردين على تعليق لـ $_replyingToUserName",
                    style: TextStyle(
                      color: AppColors.burgundy.withOpacity(0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _replyingToCommentId = null;
                        _replyingToUserName = null;
                      });
                    },
                    child: const Icon(Icons.cancel_rounded, size: 18, color: Colors.grey),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.textFieldFill,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: _replyingToCommentId != null ? AppColors.burgundy : AppColors.burgundy,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _commentController,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: _replyingToCommentId != null ? "اكتبي ردكِ هنا..." : "شارك القرّاء انطباعك أو اقتباساً أعجبك...",
                      hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.burgundy,
                  shape: BoxShape.circle,
                ),
                child: commentProvider.isSending
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () async {
                          if (_commentController.text.trim().isEmpty) return;

                          bool success;

                          if (_replyingToCommentId != null) {
                            success = await commentProvider.sendReply(
                              bookId: widget.bookId,
                              parentId: _replyingToCommentId!,
                              content: _commentController.text,
                              token: token!,
                            );
                          } else {
                            success = await commentProvider.sendComment(
                              bookId: widget.bookId,
                              content: _commentController.text,
                              token: token!,
                            );
                          }

                          if (!mounted) return;

                          if (success) {
                            _commentController.clear();
                            FocusScope.of(context).unfocus();
                            if (_replyingToCommentId != null) {
                              setState(() {
                                _replyingToCommentId = null;
                                _replyingToUserName = null;
                              });
                            }
                          } else {
                            messenger.showSnackBar(
                              SnackBar(content: Text(commentProvider.errorMessage)),
                            );
                          }
                        },
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}