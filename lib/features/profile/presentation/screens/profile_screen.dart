import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "이름",
          style: TextStyle(fontSize: 18.sp),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 20.sp),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, size: 20.sp),
            onPressed: () {
              // 추가 옵션 동작
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20.h),
            // 프로필 이미지
            CircleAvatar(
              radius: 50.r,
              backgroundImage: const AssetImage("assets/images/default_image.png"),
            ),
            SizedBox(height: 10.h),
            // 사용자 아이디
            Text(
              "@ID",
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.h),
            // 팔로잉/팔로워/좋아요 정보
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatItem("5", "팔로잉"),
                SizedBox(width: 20.w),
                _buildStatItem("17.4만", "팔로워"),
                SizedBox(width: 20.w),
                _buildStatItem("9.5만", "좋아요"),
              ],
            ),
            SizedBox(height: 20.h),
            // 팔로우 버튼
            ElevatedButton(
              onPressed: () {
                // 팔로우 버튼 동작
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 10.h),
              ),
              child: Text(
                "팔로우",
                style: TextStyle(fontSize: 14.sp),
              ),
            ),
            SizedBox(height: 20.h),
            // 자기소개
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text(
                "소개글입니다",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
              ),
            ),
            SizedBox(height: 10.h),
            // 링크 정보
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: GestureDetector(
                onTap: () {
                  // 링크 클릭 동작
                },
                child: Text(
                  "링크/link.com",
                  style: TextStyle(fontSize: 14.sp, color: Colors.blue),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(height: 20.h),
            // 동영상 섹션
            Divider(thickness: 1.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "동영상",
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.filter_list, size: 20.sp),
                    onPressed: () {
                      // 필터 버튼 동작
                    },
                  ),
                ],
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.w,
                mainAxisSpacing: 10.h,
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                return _buildVideoItem(
                  "assets/images/default_image.png",
                  index == 0 ? "207만" : "175.6만",
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5.h),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildVideoItem(String imagePath, String views) {
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
        SizedBox(height: 5.h),
        Text(
          "$views 조회수",
          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
