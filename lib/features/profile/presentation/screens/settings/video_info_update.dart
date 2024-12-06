import 'dart:io';

import 'package:blink/core/theme/colors.dart';
import 'package:blink/features/upload/data/models/hashtag_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VideoInfoUpdateScreen extends StatefulWidget {
  final String videoId;
  final String videoPath;
  final String thumbnailPath;
  final String initialTitle;
  final String initialDescription;
  final String initialCategory;
  final List<String> initialHashtags;

  const VideoInfoUpdateScreen({
    super.key,
    required this.videoId,
    required this.videoPath,
    required this.thumbnailPath,
    required this.initialTitle,
    required this.initialDescription,
    required this.initialCategory,
    required this.initialHashtags,
  });

  @override
  _VideoInfoUpdateScreenState createState() => _VideoInfoUpdateScreenState();
}

class _VideoInfoUpdateScreenState extends State<VideoInfoUpdateScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _hashtagController;

  final _formKey = GlobalKey<FormState>();
  final List<String> _categories = [
    '일상',
    '게임',
    '음악',
    '댄스',
    '요리',
    '스포츠',
    '교육',
    '동물',
    '기타',
  ];
  late String _selectedCategory;
  late List<String> _hashtags;

  @override
  void initState() {
    _titleController = TextEditingController(text: widget.initialTitle);
    _descriptionController = TextEditingController(text: widget.initialDescription);
    _hashtagController = TextEditingController();
    _selectedCategory = widget.initialCategory;
    _hashtags = List.from(widget.initialHashtags);
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _hashtagController.dispose();
    super.dispose();
  }

  void _showHashtagBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        final TextEditingController localHashtagController = TextEditingController();
        List<HashtagModel> localSearchResults = [];

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                color: AppColors.backgroundBlackColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              ),
              child: Column(
                children: [
                  SizedBox(height: 8.h),
                  Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: localHashtagController,
                            decoration: InputDecoration(
                              hintText: '해시태그 입력 (예: #일상)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        ElevatedButton(
                          onPressed: () async {
                            String tag = localHashtagController.text.trim();
                            if (tag.isNotEmpty) {
                              if (tag.startsWith('#')) {
                                tag = tag.substring(1);
                              }
                              final results = await searchHashtags(tag);
                              setModalState(() {
                                localSearchResults = results.isEmpty
                                    ? [HashtagModel(query: tag, count: 0)]
                                    : results;
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          child: Text('검색'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      itemCount: localSearchResults.length,
                      itemBuilder: (context, index) {
                        final hashtag = localSearchResults[index];
                        return ListTile(
                          title: Text('#${hashtag.query}', style: TextStyle(color: Colors.black)),
                          trailing: hashtag.count == 0
                              ? const Text('새로운 해시태그', style: TextStyle(color: AppColors.primaryColor))
                              : Text('${hashtag.count}회', style: TextStyle(color: Colors.black)),
                          onTap: () {
                            if (!_hashtags.contains(hashtag.query)) {
                              setState(() {
                                _hashtags.add(hashtag.query);
                              });
                            }
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<List<HashtagModel>> searchHashtags(String query) async {
    if (query.isEmpty) return [];

    final result = await FirebaseFirestore.instance
        .collection('hashtags')
        .where('query', isGreaterThanOrEqualTo: query)
        .where('query', isLessThanOrEqualTo: '$query\uf8ff')
        .orderBy('query')
        .limit(10)
        .get();

    return result.docs
        .map((doc) => HashtagModel(query: doc['query'] ?? '', count: doc['count'] ?? 0))
        .toList();
  }

  void _saveEdits() async {
    if (_formKey.currentState!.validate()) {
      // Firestore에 업데이트할 데이터 생성
      final updatedData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category_id': _selectedCategory,
        'hash_tag_list': _hashtags,
        'updated_at': Timestamp.now(),
      };

      try {
        await FirebaseFirestore.instance
            .collection('videos')
            .doc(widget.videoId)
            .update(updatedData);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "동영상 정보가 성공적으로 업데이트되었습니다.",
              style: TextStyle(color: AppColors.textWhite),
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            backgroundColor: AppColors.backgroundDarkGrey,
          ),
        );

        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "동영상 정보 업데이트 중 오류가 발생했습니다.",
              style: TextStyle(color: AppColors.errorRed),
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            backgroundColor: AppColors.backgroundDarkGrey,
          ),
        );
        debugPrint("Firestore 업데이트 실패: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('동영상 정보 수정', style: TextStyle(fontSize: 20.sp)),
        backgroundColor: AppColors.backgroundDarkGrey,
      ),
      backgroundColor: AppColors.backgroundBlackColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: '제목을 입력하세요...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                ),
                validator: (value) => value == null || value.isEmpty ? '제목을 입력해주세요' : null,
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: '설명을 입력하세요...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                ),
                validator: (value) => value == null || value.isEmpty ? '설명을 입력해주세요' : null,
              ),
              SizedBox(height: 16.h),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? '카테고리를 선택해주세요' : null,
              ),
              SizedBox(height: 16.h),
              GestureDetector(
                onTap: _showHashtagBottomSheet,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    '해시태그 추가',
                    style: TextStyle(fontSize: 14.sp, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Wrap(
                spacing: 8.w,
                children: _hashtags
                    .map((tag) => Chip(
                          label: Text('#$tag'),
                          onDeleted: () {
                            setState(() {
                              _hashtags.remove(tag);
                            });
                          },
                        ))
                    .toList(),
              ),
              SizedBox(height: 30.h),
              Center(
                child: ElevatedButton(
                  onPressed: _saveEdits,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    fixedSize: Size(200.w, 50.h),
                  ),
                  child: Text(
                    '저장하기',
                    style: TextStyle(fontSize: 16.sp, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
