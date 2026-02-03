import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  
  @override
  List<Object?> get props => [];
}

class UpdateProfileNameEvent extends ProfileEvent {
  final String? firstName;
  final String? lastName;

  const UpdateProfileNameEvent({
    this.firstName,
    this.lastName,
  });

  @override
  List<Object?> get props => [firstName, lastName];
}

class UploadProfileImageEvent extends ProfileEvent {
  final File imageFile;

  const UploadProfileImageEvent(this.imageFile);

  @override
  List<Object?> get props => [imageFile];
}
