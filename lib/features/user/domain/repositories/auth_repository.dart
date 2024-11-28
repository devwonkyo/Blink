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
  Future<void> signUp({
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

      await _usersCollection.doc(user.id).set(user.toMap());

    } catch (e) {
      rethrow;
    }
  }

  // 로그인 및 마지막 로그인 시간 업데이트
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 마지막 로그인 시간 업데이트
      await _usersCollection.doc(credential.user!.uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });

      return credential;
    } catch (e) {
      rethrow;
    }
  }

  // 사용자 정보 가져오기
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final docSnapshot = await _usersCollection.doc(userId).get();
      return docSnapshot.data() as Map<String, dynamic>?;
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