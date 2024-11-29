import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

import 'package:blink/features/search/data/datasources/local/search_local_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';

final BehaviorSubject<List<dynamic>> _popularStreamController = BehaviorSubject<List<dynamic>>();

class SearchedScreen extends StatefulWidget {
  final String query;

  const SearchedScreen({Key? key, required this.query}) : super(key: key);

  @override
  _SearchedScreenState createState() => _SearchedScreenState();
}

class _SearchedScreenState extends State<SearchedScreen> {
  final TextEditingController _searchController = TextEditingController();
  final SearchLocalDataSource localDataSource = SearchLocalDataSource();
  late String currentQuery;

  @override
  void initState() {
    super.initState();
    currentQuery = widget.query;
    _searchController.text = currentQuery;
    _initializePopularStream(currentQuery);
  }

  void _initializePopularStream(String query) {
    final popularStream = Rx.combineLatest3(
      FirebaseFirestore.instance.collection('users').snapshots(),
      FirebaseFirestore.instance.collection('videos').snapshots(),
      FirebaseFirestore.instance.collection('hashtags').snapshots(),
      (QuerySnapshot userSnapshot, QuerySnapshot videoSnapshot, QuerySnapshot hashtagSnapshot) {
        final users = userSnapshot.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['name'].toString().contains(query) ||
              data['email'].toString().contains(query);
        }).map((doc) => {'type': 'user', 'data': doc.data()}).toList();

        final videos = videoSnapshot.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['title'].toString().contains(query) ||
              data['description'].toString().contains(query);
        }).map((doc) => {'type': 'video', 'data': doc.data()}).toList();

        final hashtags = hashtagSnapshot.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['tag'].toString().contains(query);
        }).map((doc) => {'type': 'hashtag', 'data': doc.data()}).toList();

        return [...users, ...videos, ...hashtags];
      },
    );

    popularStream.listen((data) {
      _popularStreamController.add(data);
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
  }

  void _onSearch(String query) async {
    if (query.isNotEmpty) {
      await _saveSearchQuery(query);
      setState(() {
        currentQuery = query;
        _initializePopularStream(query);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '검색어를 입력하세요',
              border: InputBorder.none,
              hintStyle: TextStyle(fontSize: 18.sp),
            ),
            style: TextStyle(fontSize: 18.sp),
            onSubmitted: _onSearch,
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                final query = _searchController.text.trim();
                _onSearch(query);
              },
            ),
          ],
          bottom: TabBar(
            indicatorColor: Colors.red,
            labelColor: Colors.red,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: "인기", height: 40.h),
              Tab(text: "사용자", height: 40.h),
              Tab(text: "동영상", height: 40.h),
              Tab(text: "해시태그", height: 40.h),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildPopularContent(),
            _buildUserContent(),
            _buildVideoContent(),
            _buildHashtagContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularContent() {
    return StreamBuilder<List<dynamic>>(
      stream: _popularStreamController.stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final combinedResults = snapshot.data!;

        return ListView.builder(
          itemCount: combinedResults.length,
          itemBuilder: (context, index) {
            final result = combinedResults[index];
            if (result['type'] == 'user') {
              return _buildUserItem(result['data']);
            } else if (result['type'] == 'video') {
              return _buildVideoItem(result['data']);
            } else if (result['type'] == 'hashtag') {
              return _buildHashtagItem(result['data']);
            }
            return const SizedBox.shrink();
          },
        );
      },
    );
  }

  Widget _buildUserItem(Map<String, dynamic> user) {
    return ListTile(
      leading: CircleAvatar(
        radius: 20.r,
        backgroundImage: (user['profileImageUrl'] != null && user['profileImageUrl'].isNotEmpty)
            ? NetworkImage(user['profileImageUrl']!)
            : AssetImage('assets/images/default_profile.png') as ImageProvider,
        onBackgroundImageError: (exception, stackTrace) {
          debugPrint('Error loading image: $exception');
        },
      ),
      title: Text(user['name'] ?? 'Unknown'),
      subtitle: Text(user['email'] ?? 'No email'),
    );
  }

  Widget _buildVideoItem(Map<String, dynamic> video) {
    return ListTile(
      leading: Container(
        width: 50.w,
        height: 50.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          image: DecorationImage(
            image: (video['thumbnailUrl'] != null && video['thumbnailUrl'].isNotEmpty)
                ? NetworkImage(video['thumbnailUrl']!)
                : const AssetImage('assets/images/default_image.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
      title: Text(video['title'] ?? 'No title'),
      subtitle: Text(video['description'] ?? 'No description'),
    );
  }

  Widget _buildHashtagItem(Map<String, dynamic> hashtag) {
    return ListTile(
      leading: Icon(Icons.tag, size: 20.sp),
      title: Text(
        hashtag['tag'],
        style: TextStyle(fontSize: 14.sp),
      ),
    );
  }

  Widget _buildUserContent() {
    return _buildStreamList('users', ['name', 'email'], _buildUserItem);
  }

  Widget _buildVideoContent() {
    return _buildStreamList('videos', ['title', 'description'], _buildVideoItem);
  }

  Widget _buildHashtagContent() {
    return _buildStreamList('hashtags', ['tag'], _buildHashtagItem);
  }

  Widget _buildStreamList(String collection, List<String> fields, Function itemBuilder) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(collection).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final results = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return fields.any((field) => data[field].toString().contains(currentQuery));
        }).toList();

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            return itemBuilder(results[index].data() as Map<String, dynamic>);
          },
        );
      },
    );
  }
}
