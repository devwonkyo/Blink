import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:blink/features/user/data/models/user_model.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({Key? key}) : super(key: key);

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _nameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _introductionController = TextEditingController();
  List<TextEditingController> _dynamicLinkControllers = [];
  String? _profileImagePath;
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (doc.exists) {
          setState(() {
            _user = UserModel.fromJson(doc.data()!);
            _nameController.text = _user?.name ?? '';
            _nicknameController.text = _user?.nickname ?? '';
            _introductionController.text = _user?.introduction ?? '';
            _dynamicLinkControllers = (_user?.linkList ?? []).map((link) {
              final controller = TextEditingController();
              controller.text = link;
              return controller;
            }).toList();
            _isLoading = false;
          });
        }
      } catch (e) {
        debugPrint("데이터 로드 실패: $e");
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImagePath = pickedFile.path;
      });
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return null;

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${currentUser.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');

      await storageRef.putFile(imageFile);
      return await storageRef.getDownloadURL();
    } catch (e) {
      debugPrint("이미지 업로드 실패: $e");
      return null;
    }
  }

  Future<void> _saveProfile() async {
    if (_user == null) return;

    try {
      // 닉네임 중복 체크
      final nicknameQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('nickname', isEqualTo: _nicknameController.text)
          .get();
      if (nicknameQuery.docs.isNotEmpty &&
          _nicknameController.text != _user!.nickname) {
        _showErrorDialog("닉네임 설정 실패", "이미 사용 중인 닉네임입니다.");
        return;
      }

      String? updatedProfileImageUrl = _user!.profileImageUrl;

      // 프로필 이미지 업로드
      if (_profileImagePath != null) {
        updatedProfileImageUrl = await _uploadImage(File(_profileImagePath!));
      }

      final updatedUser = _user!.copyWith(
        name: _nameController.text,
        nickname: _nicknameController.text,
        introduction: _introductionController.text,
        linkList: _dynamicLinkControllers
            .map((controller) => controller.text)
            .toList(),
        profileImageUrl: updatedProfileImageUrl,
        updatedAt: DateTime.now(),
      );

      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid);

      // Firestore 업데이트
      await docRef.set(updatedUser.toMap());

      // 업데이트된 정보를 저장하고 이전 화면으로 돌아가기
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint("프로필 업데이트 실패: $e");
      _showErrorDialog("업데이트 실패", "프로필 업데이트 중 오류가 발생했습니다.");
    }
  }

  void _showErrorDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("확인"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_user == null) {
      return const Scaffold(
        body: Center(child: Text("유저 정보를 불러올 수 없습니다.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("프로필 편집"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50.r,
                    backgroundImage: _profileImagePath != null
                        ? FileImage(File(_profileImagePath!)) as ImageProvider
                        : _user!.profileImageUrl != null &&
                                _user!.profileImageUrl!.isNotEmpty
                            ? NetworkImage(_user!.profileImageUrl!)
                            : const AssetImage("assets/images/default_profile.png"),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "이름"),
              ),
              SizedBox(height: 10.h),
              TextField(
                controller: _nicknameController,
                decoration: const InputDecoration(labelText: "@닉네임"),
              ),
              SizedBox(height: 10.h),
              TextField(
                controller: _introductionController,
                decoration: const InputDecoration(labelText: "자기소개"),
              ),
              SizedBox(height: 20.h),
              const Text("링크 추가"),
              Column(
                children: [
                  ..._dynamicLinkControllers.asMap().entries.map((entry) {
                    final index = entry.key;
                    final controller = entry.value;
                    return Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller,
                            decoration: InputDecoration(
                              hintText: "링크 입력",
                              labelText: "링크 ${index + 1}",
                            ),
                          ),
                        ),
                        if (index != 0)
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () {
                              setState(() {
                                _dynamicLinkControllers.removeAt(index);
                              });
                            },
                          ),
                      ],
                    );
                  }),
                  if (_dynamicLinkControllers.length < 5)
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () {
                        setState(() {
                          _dynamicLinkControllers.add(TextEditingController());
                        });
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
