import 'package:blink/features/user/data/models/user_model.dart';

abstract class UserRepository {
  Future<UserModel> getUserById(String userId);
}
