import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blink/features/search/presentation/blocs/search/search_bloc.dart';
import 'package:blink/features/search/presentation/blocs/search/search_event.dart';
import 'package:blink/features/search/presentation/blocs/search/search_state.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController searchController = TextEditingController();

    return BlocProvider(
      create: (context) => SearchBloc()..add(LoadRecentSearchEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: '검색어를 입력하세요',
              border: InputBorder.none,
              hintStyle: TextStyle(fontSize: 18.sp),
            ),
            style: TextStyle(fontSize: 18.sp),
          ),
          actions: [
            TextButton(
              onPressed: () {
                final query = searchController.text.trim();
                if (query.isNotEmpty) {
                  context.push('/search/results/$query');
                }
              },
              child: Text(
                '검색',
                style: TextStyle(color: Colors.red, fontSize: 16.sp),
              ),
            ),
          ],
        ),
        body: BlocBuilder<SearchBloc, SearchState>(
          builder: (context, state) {
            if (state is SearchInitial) {
              return Center(child: CircularProgressIndicator());
            } else if (state is SearchLoaded) {
              return ListView(
                children: [
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Text(
                      '최근 검색어',
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ...state.recentSearches
                      .map((search) => _buildRecentSearchItem(search))
                      .toList(),
                  Divider(height: 1.h),
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Text(
                      '회원님이 좋아할 만한 콘텐츠',
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ...state.recommendedContents
                      .map((content) => _buildRecommendedContentItem(content))
                      .toList(),
                ],
              );
            }
            return Center(child: Text('오류 발생', style: TextStyle(fontSize: 16.sp)));
          },
        ),
      ),
    );
  }

  Widget _buildRecentSearchItem(String text) {
    return ListTile(
      leading: Icon(Icons.history, size: 20.sp),
      title: Text(text, style: TextStyle(fontSize: 14.sp)),
      trailing: IconButton(
        icon: Icon(Icons.close, size: 20.sp),
        onPressed: () {
          // 삭제 기능 추가
        },
      ),
    );
  }

  Widget _buildRecommendedContentItem(String text) {
    return ListTile(
      leading: SizedBox(width: 8.w),
      title: Text(
        text,
        style: TextStyle(fontSize: 14.sp),
      ),
      onTap: () {
        // 콘텐츠 선택 시 동작
      },
    );
  }
}
