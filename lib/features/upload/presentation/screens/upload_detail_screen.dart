import 'dart:io';

import 'package:blink/core/theme/colors.dart';
import 'package:blink/features/upload/presentation/blocs/upload/upload_video_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class UploadDetailScreen extends StatefulWidget {
  final String videoPath;
  final String thumbnailPath;

  const UploadDetailScreen({super.key, required this.videoPath, required this.thumbnailPath});

  @override
  State<UploadDetailScreen> createState() => _UploadDetailScreenState();
}

class _UploadDetailScreenState extends State<UploadDetailScreen> {
  late final TextEditingController _contentController;
  late final TextEditingController _titleController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _contentController = TextEditingController();
    _titleController = TextEditingController();
    context.read<UploadVideoBloc>().add(InitializeVideo(videoPath: widget.videoPath));
    print("upload 초기화");
    super.initState();
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UploadVideoBloc, UploadVideoState>(
      listener: (context, state) {
        if (state is UploadVideoSuccess) {
          showUploadSuccessDialog(context);
        } else if (state is UploadVideoError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error ?? '업로드 실패')),
          );
        }
      },
      builder: (context, state) {
        return Stack(
          children: [
            Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    context.pop();
                    context.pop();
                    },
                ),
              ),
              body: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.all(16.w),
                              child: TextFormField(
                                controller: _titleController,
                                maxLines: 1,
                                autofocus: true,
                                decoration: InputDecoration(
                                  hintText: '제목을 입력하세요...',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return '제목을 입력해주세요';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.all(16.w),
                                    child: TextFormField(
                                      controller: _contentController,
                                      maxLines: 8,
                                      decoration: InputDecoration(
                                        hintText: '설명을 추가하세요...',
                                        hintStyle: TextStyle(color: Colors.grey),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.r),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return '설명을 입력해주세요';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                                _buildThumbnailPreview(context),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0.w, vertical: 10.h),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 6.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  '# 해시태그',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: AppColors.primaryColor),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              backgroundColor: AppColors.primaryLightColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            child: Text(
                              '임시 저장',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()){
                                context.read<UploadVideoBloc>().add(
                                    UploadVideo(
                                        videoPath: widget.videoPath,
                                        description: _contentController.text,
                                        thumbnailImage: widget.thumbnailPath,
                                        videoTitle: _titleController.text
                                    )
                                );
                              }
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              backgroundColor: AppColors.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            child: Text(
                              '게시',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (state is UploadVideoLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  _buildThumbnailPreview(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 16.h, 16.w, 16.h),
      width: 100.w,
      height: 200.h,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Stack(
        children: [
          widget.thumbnailPath == "" ? // 썸네일 없을 경우 로고
          ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.asset(
                'assets/images/blink_logo.png',
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.fill,
              )
          ) :
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: Image.file(
              File(widget.thumbnailPath),
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            )
          ),
            Positioned(
              top: 4.h,
              right: 6.w,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 4.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  '미리 보기',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void showUploadSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // 바깥 영역 터치로 닫기 방지
      builder: (context) {
        return AlertDialog(
          title: Text('알림'),
          content: Text('영상이 성공적으로 업로드되었습니다.'),
          actions: [
            TextButton(
              onPressed: () {
                context.pop(); // 알림창 닫기
                context.go('/main', extra: 4);
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }
}
