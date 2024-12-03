import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/repositories/comment_repository.dart';
import '../../data/models/comment_model.dart';
import 'package:blink/core/utils/blink_sharedpreference.dart';

class CommentBottomSheet extends StatefulWidget {
  final String videoId;

  const CommentBottomSheet({
    super.key,
    required this.videoId,
  });

  @override
  State<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  final _commentController = TextEditingController();
  final _commentRepository = CommentRepository();
  final _sharedPreference = BlinkSharedPreference();
  List<CommentModel> comments = [];

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    final loadedComments = await _commentRepository.getComments(widget.videoId);
    if (mounted) {
      setState(() {
        comments = loadedComments;
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _addComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    final currentUser = await _sharedPreference.getCurrentUserId();

    try {
      await _commentRepository.addComment(
        widget.videoId,
        currentUser,
        content,
      );
      _commentController.clear();
      await _loadComments();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('댓글 작성 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: EdgeInsets.only(
        top: 16.h,
        left: 16.w,
        right: 16.w,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16.h,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.9),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '댓글',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          Divider(height: 16.h, color: Colors.white24),
          Expanded(
            child: ListView.builder(
              itemCount: comments.length,
              itemBuilder: (context, index) =>
                  _buildCommentItem(comments[index]),
            ),
          ),
          Divider(height: 16.h, color: Colors.white24),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: '댓글 작성...',
                    hintStyle: const TextStyle(color: Colors.white54),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.r),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.r),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.r),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              IconButton(
                onPressed: _addComment,
                icon: const Icon(Icons.send),
                color: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(CommentModel comment) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16.r,
            backgroundColor: Colors.white24,
            child: Icon(
              Icons.person,
              size: 20.r,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.writerNickname,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  comment.content,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
