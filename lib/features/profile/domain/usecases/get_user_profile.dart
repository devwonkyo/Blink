import 'package:blink/features/user/domain/repositories/user_repository.dart';
import 'package:blink/features/user/domain/entities/user_entity.dart';

class GetUserProfile {
  final UserRepository repository;

  GetUserProfile(this.repository);

  Future<UserEntity> call(String userId) async {
    final userModel = await repository.getUserById(userId);
    return userModel.toEntity();
  }
}
