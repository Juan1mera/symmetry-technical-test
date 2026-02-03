import '../../../../core/resources/data_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class UpdateProfileUseCase implements UseCase<DataState<UserEntity>, UpdateProfileParams> {
  final AuthRepository _authRepository;

  UpdateProfileUseCase(this._authRepository);

  @override
  Future<DataState<UserEntity>> call({UpdateProfileParams? params}) {
    return _authRepository.updateProfile(
      firstName: params?.firstName,
      lastName: params?.lastName,
    );
  }
}

class UpdateProfileParams {
  final String? firstName;
  final String? lastName;

  UpdateProfileParams({
    this.firstName,
    this.lastName,
  });
}
