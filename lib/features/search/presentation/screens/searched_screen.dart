import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:rxdart/rxdart.dart';

final BehaviorSubject<List<dynamic>> _popularStreamController = BehaviorSubject<List<dynamic>>();

class SearchedScreen extends StatefulWidget {
  final String query;

  const SearchedScreen({Key? key, required this.query}) : super(key: key);

  @override
  _SearchedScreenState createState() => _SearchedScreenState();
}

class _SearchedScreenState extends State<SearchedScreen> {
  final TextEditingController _searchController = TextEditingController();
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
          return data['name'].toString().contains(query) || data['email'].toString().contains(query);
        }).map((doc) => {'type': 'user', 'data': doc.data()}).toList();

        final videos = videoSnapshot.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['title'].toString().contains(query) || data['description'].toString().contains(query);
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

  void _onSearch(String query) {
    if (query.isNotEmpty) {
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
            TextButton(
              child: Text(
                '검색',
                style: TextStyle(color: Colors.red, fontSize: 16.sp),
              ),
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
        body: Column(
          children: [
            StreamBuilder<List<dynamic>>(
              stream: _popularStreamController.stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildPopularContent(),
                  _buildUserContent(),
                  _buildVideoContent(),
                  _buildHashtagContent(),
                ],
              ),
            ),
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
        final users = combinedResults.where((item) => item['type'] == 'user').take(4).toList();
        final videos = combinedResults.where((item) => item['type'] == 'video').take(4).toList();
        final hashtags = combinedResults.where((item) => item['type'] == 'hashtag').take(4).toList();

        return SingleChildScrollView(
          child: Column(
            children: [
              _buildSection("사용자", users, () => DefaultTabController.of(context)?.animateTo(1)),
              _buildSection("동영상", videos, () => DefaultTabController.of(context)?.animateTo(2)),
              _buildSection("해시태그", hashtags, () => DefaultTabController.of(context)?.animateTo(3)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection(String title, List<dynamic> items, VoidCallback onMoreTap) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: onMoreTap,
                child: Text("더보기", style: TextStyle(fontSize: 14.sp)),
              ),
            ],
          ),
        ),
        ...items.map((item) {
          if (item['type'] == 'user') return _buildUserItem(item['data']);
          if (item['type'] == 'video') return _buildVideoItem(item['data']);
          if (item['type'] == 'hashtag') return _buildHashtagItem(item['data']);
          return const SizedBox.shrink();
        }).toList(),
        Divider(height: 20.h, thickness: 1.h),
      ],
    );
  }

  Widget _buildUserItem(Map<String, dynamic> user) {
    final profileImageUrl = user['profile_image_url'] as String?;
    
    return ListTile(
      leading: CircleAvatar(
        radius: 20.r,
        child: CachedNetworkImage(
          imageUrl: profileImageUrl?.isNotEmpty == true ? profileImageUrl! : "",
          placeholder: (context, url) => CircularProgressIndicator(
            strokeWidth: 2.w,
          ),
          errorWidget: (context, url, error) => CircleAvatar(
            radius: 20.r,
            backgroundImage: const AssetImage("assets/images/default_profile.png"),
          ),
          imageBuilder: (context, imageProvider) => CircleAvatar(
            radius: 20.r,
            backgroundImage: imageProvider,
          ),
        ),
      ),
      title: Text(user['name'] ?? 'Unknown'),
      subtitle: Text('@' + (user['nickname'] ?? 'No username')),
      onTap: () {
        final userId = user['id'];
        if (userId != null) {
          GoRouter.of(context).push('/profile/$userId');
        } else {
          debugPrint("유효하지 않은 사용자 ID");
        }
      },
    );
  }

  Widget _buildVideoItem(Map<String, dynamic> video) {
    return ListTile(
      leading: Container(
        width: 50.w,
        height: 50.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: CachedNetworkImage(
            imageUrl: video['thumbnailUrl']?.isNotEmpty == true ? video['thumbnailUrl']! : "",
            placeholder: (context, url) => Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.w,
              ),
            ),
            errorWidget: (context, url, error) => Image.asset(
              'assets/images/default_image.png',
              fit: BoxFit.cover,
            ),
            imageBuilder: (context, imageProvider) => Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
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
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: results.length,
          itemBuilder: (context, index) {
            return itemBuilder(results[index].data() as Map<String, dynamic>);
          },
        );
      },
    );
  }
}
