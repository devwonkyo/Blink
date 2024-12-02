import 'package:blink/core/utils/blink_sharedpreference.dart';
import 'package:blink/features/user/data/models/user_model.dart';
import 'package:blink/features/user/domain/repositories/auth_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {

    //회원가입 이벤트
    on<SignUpRequested>((event, emit) async {
      emit(AuthLoading());
      print('로딩중');
      try {
        final result = await authRepository.signUp(
          email: event.email,
          password: event.password,
          name: event.name,
        );

        if(result.isSuccess){
          emit(Authenticated("회원가입이 완료되었습니다. 이메일 인증 진행 후 로그인 해주세요."));
        }else{
          emit(AuthError("error : ${result.message.toString()}"));
        }
      } catch (e) {
        emit(AuthError("error : ${e.toString()}"));
      }
    });

    //로그인 이벤트
    on<SignInRequested>((event, emit) async {
      emit(AuthLoading());
      print('로딩중');
      try {
        final result = await authRepository.signIn(
          email: event.email,
          password: event.password,
        );

        if(result.isSuccess){
          //유저 정보 가져와서 쉐어드에 넣고 토큰 값 저장
          await BlinkSharedPreference().saveUserInfo(
            result.data?.id ?? "undefined user",
            result.data?.email ?? "undefined email",
            result.data?.name ?? "undefined name",
            result.data?.nickname ?? "undefined nickname",
            result.data?.pushToken ?? ""
          );

          BlinkSharedPreference().checkCurrentUser();
          emit(LoginSuccess(result.message ?? "로그인에 성공했습니다."));
        }else{
          emit(LoginFailed("error : ${result.message.toString()}"));
        }
        print("로그인 완료");

      } catch (e) {
        emit(LoginFailed("error : ${e.toString()}"));
        print("error : ${e.toString()}");
      }
    });
  }
}
