import 'package:blink/core/utils/result.dart';
import 'package:blink/features/user/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  // users 컬렉션 참조
  final CollectionReference _usersCollection =
  FirebaseFirestore.instance.collection('users');

  // 회원가입 및 사용자 정보 저장
  Future<Result> signUp({
    required String email,
    required String password,
    required String nickname,
  }) async {
    try {
      // 1. Firebase Auth로 계정 생성
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. 이메일 인증 보내기 (선택사항)
      await credential.user?.sendEmailVerification();

      // 3. 생성된 계정에 닉네임 설정
      await credential.user?.updateDisplayName(nickname);

      // 4. UserModel 생성
      final user = UserModel(
        id: credential.user!.uid,
        email: email,
        name: nickname,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      //firestore 저장
      await _usersCollection.doc(user.id).set(user.toMap());

      return Result.success("회원가입이 완료되었습니다. 이메일 인증 진행 후 로그인 해주세요.");

    } catch (e) {
      return Result.failure("error : ${e.toString()}");
    }
  }

  // 로그인
  Future<DataResult<UserModel>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 이메일 인증 확인
      if (!userCredential.user!.emailVerified) {
        return DataResult.failure("이메일 인증이 필요합니다. 이메일을 확인해주세요.");
      }

      // 2. 로그인된 사용자의 uid 가져오기
      final id = userCredential.user?.uid;
      if (id == null) {
        return DataResult.failure("사용자 ID를 가져올 수 없습니다.");
      }

      // 3. Firestore에서 해당 uid로 사용자 정보 가져오기
      final userDoc = await _firestore.collection('users').doc(id).get();

      if (!userDoc.exists) {
        return DataResult.failure("사용자 정보를 찾을 수 없습니다.");
      }
      // 4. 문서 데이터를 UserModel로 변환
      final userData = userDoc.data() as Map<String, dynamic>;
      final userModel = UserModel.fromJson(userData);

      return DataResult.success(userModel, "로그인에 성공했습니다.");

    } catch (e) {
      return DataResult.failure("로그인에 실패했습니다. error : $e");
    }
  }

  // 사용자 정보 가져오기
  Future<UserModel?> getUserDataWithUserId(String userId) async {
    try {
      final docSnapshot = await _usersCollection.doc(userId).get();
      final data = docSnapshot.data();
      if (data != null) {
        // return UserModel.fromJson(data, userId);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // 사용자 정보 업데이트
  Future<void> updateUserData(String userId, Map<String, dynamic> data) async {
    try {
      await _usersCollection.doc(userId).update(data);
    } catch (e) {
      rethrow;
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    try {
      // 현재 사용자의 마지막 접속 시간 업데이트
      final user = _auth.currentUser;
      if (user != null) {
        await _usersCollection.doc(user.uid).update({
          'lastLogin': FieldValue.serverTimestamp(),
        });
      }
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // 회원 탈퇴
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Firestore에서 사용자 데이터 삭제
        await _usersCollection.doc(user.uid).delete();
        // Auth에서 사용자 삭제
        await user.delete();
      }
    } catch (e) {
      rethrow;
    }
  }
}