part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

//로딩
class AuthLoading extends AuthState {}

//인증됨
class Authenticated extends AuthState {
  final UserModel userModel;

  const Authenticated(this.userModel);

  @override
  List<Object?> get props => [userModel];
}


//인증실패
class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}