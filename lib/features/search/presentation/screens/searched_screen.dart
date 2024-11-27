import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchedScreen extends StatelessWidget {
  final String query;

  const SearchedScreen({Key? key, required this.query}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: TextField(
            controller: TextEditingController(text: query),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintStyle: TextStyle(fontSize: 18.sp),
            ),
            style: TextStyle(fontSize: 18.sp),
          ),
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
    return ListView(
      children: [
        Padding(
          padding: EdgeInsets.all(16.w),
          child: Text(
            "사용자",
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
        ),
        _buildUserItem("예시 이름", "예시 아이디", "팔로워 ex명 · 동영상 n개"),
        Divider(height: 1.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 4.w,
            mainAxisSpacing: 4.h,
          ),
          itemCount: 6,
          itemBuilder: (context, index) {
            return _buildGridItem(
              "assets/images/default_image.png",
              "예시 제목",
              "00년 4월 12일",
            );
          },
        ),
      ],
    );
  }

  Widget _buildUserItem(String name, String username, String description) {
    return ListTile(
      leading: CircleAvatar(
        radius: 20.r,
        backgroundImage: const AssetImage('assets/images/default_image.png'),
      ),
      title: Text(
        name,
        style: TextStyle(fontSize: 14.sp),
      ),
      subtitle: Text(
        description,
        style: TextStyle(fontSize: 12.sp),
      ),
      trailing: ElevatedButton(
        onPressed: () {
          // 팔로우 버튼 동작
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        ),
        child: Text(
          "팔로우",
          style: TextStyle(fontSize: 12.sp),
        ),
      ),
    );
  }

  Widget _buildGridItem(String imagePath, String title, String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          title,
          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
        ),
        if (date.isNotEmpty)
          Text(
            date,
            style: TextStyle(fontSize: 10.sp, color: Colors.grey),
          ),
      ],
    );
  }

  Widget _buildUserContent() {
    return Center(
      child: Text(
        "사용자 콘텐츠",
        style: TextStyle(fontSize: 16.sp),
      ),
    );
  }

  Widget _buildVideoContent() {
    return Center(
      child: Text(
        "동영상 콘텐츠정",
        style: TextStyle(fontSize: 16.sp),
      ),
    );
  }

  Widget _buildHashtagContent() {
    return Center(
      child: Text(
        "해시태그 콘텐츠",
        style: TextStyle(fontSize: 16.sp),
      ),
    );
  }
}
