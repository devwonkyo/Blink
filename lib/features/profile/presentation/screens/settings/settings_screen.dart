import 'package:blink/core/theme/colors.dart';
import 'package:blink/core/utils/blink_sharedpreference.dart';
import 'package:blink/features/user/domain/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? currentUserId;
  final BlinkSharedPreference _sharedPreference = BlinkSharedPreference();

  @override
  void initState() {
    super.initState();
    _loadCurrentUserId();
  }

  Future<void> _loadCurrentUserId() async {
    final userId = await _sharedPreference.getCurrentUserId();
    setState(() {
      currentUserId = userId;
    });
    print('Settings Screen: $currentUserId');
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final authRepository = AuthRepository();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "로그아웃",
          style: TextStyle(color: AppColors.textWhite),
        ),
        content: Text(
          "정말 로그아웃 하시겠습니까?",
          style: TextStyle(color: AppColors.textGrey),
        ),
        backgroundColor: AppColors.backgroundDarkGrey,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("아니요", style: TextStyle(color: AppColors.primaryLightColor)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context, true);
            },
            child: Text("예", style: TextStyle(color: AppColors.primaryColor)),
          ),
        ],
      ),
    );

    if (result == true) {
      await authRepository.signOut();
      await _sharedPreference.removeUserInfo();
      context.go('/main-navigation/0');
    }
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = AppColors.primaryColor,
    Color textColor = AppColors.textWhite,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
        padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 16.w),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.primaryDarkColor,
            width: 2.0.w,
          ),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(color: textColor, fontSize: 16.sp),
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textGrey, size: 24.sp),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundBlackColor,
        title: Text(
          "설정",
          style: TextStyle(color: AppColors.textWhite, fontSize: 18.sp),
        ),
        centerTitle: true,
      ),
      backgroundColor: AppColors.backgroundBlackColor,
      body: currentUserId == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              children: [
                _buildSettingItem(
                  icon: Icons.history,
                  title: "시청 기록",
                  onTap: () {
                    context.push('/watch-history/$currentUserId');
                  },
                ),
                _buildSettingItem(
                  icon: Icons.video_library,
                  title: "내 동영상 관리",
                  onTap: () {
                    context.push('/manage-videos/$currentUserId');
                  },
                ),
                _buildSettingItem(
                  icon: Icons.logout,
                  title: "로그아웃",
                  iconColor: AppColors.errorRed,
                  textColor: AppColors.errorRed,
                  onTap: () {
                    _showLogoutDialog(context);
                  },
                ),
              ],
            ),
    );
  }
}
