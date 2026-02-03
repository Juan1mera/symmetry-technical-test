import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

abstract class AuthState extends Equatable {
  final UserEntity? user;
  final Exception? error;

  const AuthState({this.user, this.error});
    
  @override
  List<Object?> get props => [user, error];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthSuccess extends AuthState {
  const AuthSuccess(UserEntity user) : super(user: user);
}

class AuthFailure extends AuthState {
  const AuthFailure(Exception error) : super(error: error);
}
