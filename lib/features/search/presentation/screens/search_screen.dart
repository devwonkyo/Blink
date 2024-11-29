import 'package:blink/features/search/presentation/screens/searched_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:blink/features/search/data/datasources/local/search_local_datasource.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  final SearchLocalDataSource localDataSource = SearchLocalDataSource();
  List<String> recentSearches = [];
  final List<String> recommendedSearches = ["추천 검색어 1", "추천 검색어 2"];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  Future<void> _loadRecentSearches() async {
    final searches = await localDataSource.fetchRecentSearches();
    setState(() {
      recentSearches = searches;
    });
  }

  Future<void> _saveSearchQuery(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final searches = await localDataSource.fetchRecentSearches();

    if (searches.contains(query)) {
      searches.remove(query);
    }
    searches.insert(0, query);

    if (searches.length > 10) {
      searches.removeLast();
    }

    await prefs.setStringList(SearchLocalDataSource.recentSearchesKey, searches);
    await _loadRecentSearches();
  }

  Future<void> _deleteSearchQuery(String query) async {
    await localDataSource.deleteSearchQuery(query);
    await _loadRecentSearches();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            onPressed: () async {
              final query = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchedScreen(query: ''),
                ),
              );

              if (query != null) {
                await _saveSearchQuery(query);
              }
            },
            child: Text(
              '검색',
              style: TextStyle(color: Colors.red, fontSize: 16.sp),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (recentSearches.isNotEmpty) ...[
              Text(
                "최근 검색어",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),
              ListView.builder(
                itemCount: recentSearches.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final search = recentSearches[index];
                  return ListTile(
                    title: Text(search, style: TextStyle(fontSize: 14.sp)),
                    trailing: IconButton(
                      icon: Icon(Icons.close, size: 18.sp),
                      onPressed: () => _deleteSearchQuery(search),
                    ),
                    onTap: () async {
                      await _saveSearchQuery(search);
                      context.push('/search/results/$search');
                    },
                  );
                },
              ),
            ],
            if (recommendedSearches.isNotEmpty) ...[
              Text(
                "추천 검색어",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),
              ListView.builder(
                itemCount: recommendedSearches.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final search = recommendedSearches[index];
                  return ListTile(
                    title: Text(search, style: TextStyle(fontSize: 14.sp)),
                    onTap: () async {
                      await _saveSearchQuery(search);
                      context.push('/search/results/$search');
                    },
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
