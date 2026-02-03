import 'dart:io';
import '../../../../core/resources/data_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class UploadProfileImageUseCase implements UseCase<DataState<String>, File> {
  final AuthRepository _authRepository;

  UploadProfileImageUseCase(this._authRepository);

  @override
  Future<DataState<String>> call({File? params}) {
    if (params == null) {
      return Future.value(DataFailed(Exception('Image file is required')));
    }
    return _authRepository.uploadProfileImage(params);
  }
}
