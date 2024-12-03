import 'dart:io';

import 'package:blink/core/utils/blink_sharedpreference.dart';
import 'package:blink/core/utils/result.dart';
import 'package:blink/features/video/data/models/video_model.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UploadRepository {
  final FirebaseStorage _fireStorage = FirebaseStorage.instance;

  Future<Result> uploadVideo(XFile video) async {
    final userId = await BlinkSharedPreference().getCurrentUserId();

    try {
      // XFile을 직접 Storage에 업로드
      final fileName = 'video_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final storageRef = _fireStorage.ref().child('videos/$fileName');

      // XFile에서 바로 업로드
      final uploadTask = await storageRef.putFile(File(video.path));
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      final videoMoel = VideoModel(
          id: "id",
          uploaderId: userId,
          title: "title",
          description: "description",
          videoUrl: downloadUrl,
          thumbnailUrl: "thumbnailUrl",
          views: 0,
          categoryId: "categoryId",
          createdAt: DateTime.now(),
          updatedAt: DateTime.now());
      // Firestore에 정보 저장
      await FirebaseFirestore.instance
          .collection('videos')
          .add(videoModel.toJson());
      return Result.success("업로드 성공");
    } catch (e) {
      return Result.failure("업로드 실패 error : %e");
    }
  }
}
