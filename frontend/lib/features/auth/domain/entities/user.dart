import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String? uid;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? profileImageUrl;

  const UserEntity({
    this.uid,
    this.email,
    this.firstName,
    this.lastName,
    this.profileImageUrl,
  });

  @override
  List<Object?> get props => [uid, email, firstName, lastName, profileImageUrl];

  String? get fullName {
    if (firstName == null && lastName == null) return null;
    return '${firstName ?? ''} ${lastName ?? ''}'.trim();
  }
}
