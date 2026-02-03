import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../../../core/resources/data_state.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;

  AuthBloc(this._loginUseCase, this._registerUseCase) : super(const AuthInitial()) {
    on<LoginEvent>(onLogin);
    on<RegisterEvent>(onRegister);
  }

  void onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    // print("AuthBloc: onLogin called");
    emit(const AuthLoading());
    final result = await _loginUseCase(params: LoginParams(email: event.email, password: event.password));
    if (result is DataSuccess) {
      // print("AuthBloc: Login Success");
      emit(AuthSuccess(result.data!));
    } else {
      // print("AuthBloc: Login Failure - ${result.error}");
      emit(AuthFailure(result.error!));
    }
  }

  void onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    // print("AuthBloc: onRegister called");
    emit(const AuthLoading());
    final result = await _registerUseCase(
      params: RegisterParams(
        email: event.email,
        password: event.password,
        firstName: event.firstName,
        lastName: event.lastName,
      ),
    );
    if (result is DataSuccess) {
      // print("AuthBloc: Register Success");
      emit(AuthSuccess(result.data!));
    } else {
      // print("AuthBloc: Register Failure - ${result.error}");
      emit(AuthFailure(result.error!));
    }
  }
}
