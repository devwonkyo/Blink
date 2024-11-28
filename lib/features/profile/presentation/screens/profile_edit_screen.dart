import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:blink/features/user/data/models/user_model.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({Key? key}) : super(key: key);

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  final _introductionController = TextEditingController();
  final _linkControllers = <TextEditingController>[TextEditingController()];
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
      final doc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
      if (doc.exists) {
        setState(() {
          _user = UserModel.fromJson(doc.data()!);
          _nameController.text = _user?.name ?? '';
          _idController.text = _user?.id ?? '';
          _introductionController.text = _user?.introduction ?? '';
          _dynamicLinkControllers = (_user?.linkList ?? []).map((link) {
            final controller = TextEditingController();
            controller.text = link;
            return controller;
          }).toList();
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
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

  Future<void> _saveProfile() async {
    if (_user == null) return;

    // ID 중복 체크
    final idQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('id', isEqualTo: _idController.text)
        .get();
    if (idQuery.docs.isNotEmpty && _idController.text != _user!.id) {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text("ID 설정 실패"),
          content: Text("불가능한 ID입니다. 다른 ID를 선택해주세요."),
        ),
      );
      return;
    }

    final updatedUser = _user!.copyWith(
      name: _nameController.text,
      id: _idController.text,
      introduction: _introductionController.text,
      linkList: _dynamicLinkControllers.map((controller) => controller.text).toList(),
      updatedAt: DateTime.now(),
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(updatedUser.id)
        .update(updatedUser.toMap());

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_user == null) {
      return const Scaffold(
        body: Center(
          child: Text("유저 정보를 불러올 수 없습니다."),
        ),
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
                        : _user!.profileImageUrl != null && _user!.profileImageUrl!.isNotEmpty
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
                controller: _idController,
                decoration: const InputDecoration(labelText: "ID"),
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
