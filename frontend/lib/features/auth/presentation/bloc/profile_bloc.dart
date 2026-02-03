import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/resources/data_state.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/upload_profile_image_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UpdateProfileUseCase _updateProfileUseCase;
  final UploadProfileImageUseCase _uploadProfileImageUseCase;

  ProfileBloc(
    this._updateProfileUseCase,
    this._uploadProfileImageUseCase,
  ) : super(const ProfileInitial()) {
    on<UpdateProfileNameEvent>(_onUpdateProfileName);
    on<UploadProfileImageEvent>(_onUploadProfileImage);
  }

  void _onUpdateProfileName(
    UpdateProfileNameEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    
    final result = await _updateProfileUseCase(
      params: UpdateProfileParams(
        firstName: event.firstName,
        lastName: event.lastName,
      ),
    );

    if (result is DataSuccess) {
      emit(ProfileUpdateSuccess(result.data!));
    } else {
      emit(ProfileError(result.error?.toString() ?? 'Failed to update profile'));
    }
  }

  void _onUploadProfileImage(
    UploadProfileImageEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    
    final result = await _uploadProfileImageUseCase(params: event.imageFile);

    if (result is DataSuccess) {
      emit(ProfileImageUploadSuccess(result.data!));
    } else {
      emit(ProfileError(result.error?.toString() ?? 'Failed to upload image'));
    }
  }
}
