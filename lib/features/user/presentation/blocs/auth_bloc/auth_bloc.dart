import 'package:blink/features/user/data/models/user_model.dart';
import 'package:blink/features/user/domain/repositories/auth_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository = AuthRepository();

  AuthBloc() : super(AuthInitial()) {
    on<AuthEvent>((event, emit) {
      // TODO: implement event handler
    });



    on<SignUpRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final credential = await _authRepository.signUp(
          email: event.email,
          password: event.password,
          nickname: event.nickname,
        );

        /*if (credential. != null) {
          emit(Authenticated(credential.user!));
        } else {
          emit(const AuthError('회원가입에 실패했습니다.'));
        }*/
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });
  }
}
