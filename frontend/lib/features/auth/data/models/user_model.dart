import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user.dart';

class UserModel extends UserEntity {
  const UserModel({
    String? uid,
    String? email,
    String? firstName,
    String? lastName,
    String? profileImageUrl,
  }) : super(
          uid: uid,
          email: email,
          firstName: firstName,
          lastName: lastName,
          profileImageUrl: profileImageUrl,
        );

  factory UserModel.fromFirebase(User firebaseUser) {
    // Parse displayName to extract firstName and lastName
    String? firstName;
    String? lastName;
    
    if (firebaseUser.displayName != null) {
      final nameParts = firebaseUser.displayName!.trim().split(' ');
      if (nameParts.isNotEmpty) {
        firstName = nameParts.first;
        if (nameParts.length > 1) {
          lastName = nameParts.sublist(1).join(' ');
        }
      }
    }

    return UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email,
      firstName: firstName,
      lastName: lastName,
      profileImageUrl: firebaseUser.photoURL,
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] as String?,
      firstName: data['firstName'] as String?,
      lastName: data['lastName'] as String?,
      profileImageUrl: data['profileImageUrl'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'profileImageUrl': profileImageUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  @override
  String? get fullName {
    if (firstName == null && lastName == null) return null;
    return '${firstName ?? ''} ${lastName ?? ''}'.trim();
  }
}
