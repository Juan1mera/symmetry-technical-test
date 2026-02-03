import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/resources/data_state.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseStorage _firebaseStorage;
  final FirebaseFirestore _firestore;

  AuthRepositoryImpl(
    this._firebaseAuth,
    this._firebaseStorage,
    this._firestore,
  );

  @override
  Stream<UserEntity?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((user) {
      if (user != null) {
        return UserModel.fromFirebase(user);
      }
      return null;
    });
  }

  @override
  UserEntity? getCurrentUser() {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      return UserModel.fromFirebase(user);
    }
    return null;
  }

  @override
  Future<DataState<UserEntity>> login(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = userCredential.user;
      if (user == null) {
        return DataFailed(Exception('Login failed'));
      }

      // Check if Firestore document exists, create it if not
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      
      if (!userDoc.exists) {
        // Create Firestore document for users who registered before this feature
        String firstName = '';
        String lastName = '';
        
        // Try to parse from displayName if it exists
        if (user.displayName != null && user.displayName!.isNotEmpty) {
          final nameParts = user.displayName!.split(' ');
          firstName = nameParts.first;
          if (nameParts.length > 1) {
            lastName = nameParts.sublist(1).join(' ');
          }
        }
        
        await _firestore.collection('users').doc(user.uid).set({
          'email': user.email,
          'firstName': firstName,
          'lastName': lastName,
          'profileImageUrl': user.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      
      // Wait for auth state to update
      await Future.delayed(const Duration(milliseconds: 200));
      
      // Get the user data from Firestore
      final updatedDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = updatedDoc.data();
      
      return DataSuccess(UserEntity(
        uid: user.uid,
        email: user.email,
        firstName: userData?['firstName'] as String?,
        lastName: userData?['lastName'] as String?,
        profileImageUrl: userData?['profileImageUrl'] as String?,
      ));
    } on FirebaseAuthException catch (e) {
      return DataFailed(e);
    } catch (e) {
       // Check if it's the known PigeonUserDetails bug
       if (e.toString().contains('PigeonUserDetails')) {
         // This is the type cast bug, but auth actually succeeded
         return DataSuccess(UserEntity(uid: '', email: email));
       }
       return DataFailed(Exception(e.toString()));
    }
  }

  @override
  Future<DataState<UserEntity>> register(
    String email,
    String password,
    String firstName,
    String lastName,
  ) async {
    try {
      // Create user with email and password
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = userCredential.user;
      if (user == null) {
        return DataFailed(Exception('User creation failed'));
      }

      // Create Firestore user document first (most important)
      await _firestore.collection('users').doc(user.uid).set({
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'profileImageUrl': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Try to update Firebase Auth profile with display name
      // This may fail with PigeonUserInfo bug, but we don't care since Firestore has the data
      try {
        final displayName = '$firstName $lastName'.trim();
        await user.updateDisplayName(displayName);
      } catch (e) {
        // Ignore PigeonUserInfo/PigeonUserDetails errors
        if (!e.toString().contains('PigeonUserInfo') && 
            !e.toString().contains('PigeonUserDetails')) {
          // print('Warning: Failed to update Firebase Auth displayName: $e');
        }
      }
      
      // Wait for auth state to update
      await Future.delayed(const Duration(milliseconds: 200));
      
      return DataSuccess(UserEntity(
        uid: user.uid,
        email: email,
        firstName: firstName,
        lastName: lastName,
      ));
      
    } on FirebaseAuthException catch (e) {
      return DataFailed(e);
    } catch (e) {
       // Check if it's the known PigeonUserDetails bug
       if (e.toString().contains('PigeonUserDetails') || 
           e.toString().contains('PigeonUserInfo')) {
         // This is the type cast bug, but auth actually succeeded
         return DataSuccess(UserEntity(
           uid: '',
           email: email,
           firstName: firstName,
           lastName: lastName,
         ));
       }
       return DataFailed(Exception(e.toString()));
    }
  }

  @override
  Future<DataState<UserEntity>> updateProfile({
    String? firstName,
    String? lastName,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return DataFailed(Exception('No user logged in'));
      }

      // Get current values from Firestore or Firebase Auth
      String currentFirstName = firstName ?? '';
      String currentLastName = lastName ?? '';
      
      // Try to get existing data from Firestore first
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data();
          if (firstName == null && data?['firstName'] != null) {
            currentFirstName = data!['firstName'] as String;
          }
          if (lastName == null && data?['lastName'] != null) {
            currentLastName = data!['lastName'] as String;
          }
        }
      } catch (e) {
        // If Firestore fails, fall back to Firebase Auth displayName
        if (user.displayName != null) {
          final nameParts = user.displayName!.split(' ');
          if (firstName == null && nameParts.isNotEmpty) {
            currentFirstName = nameParts.first;
          }
          if (lastName == null && nameParts.length > 1) {
            currentLastName = nameParts.sublist(1).join(' ');
          }
        }
      }

      // Use provided values or keep current
      final newFirstName = firstName ?? currentFirstName;
      final newLastName = lastName ?? currentLastName;

      // Update Firestore document (use set with merge to create if doesn't exist)
      await _firestore.collection('users').doc(user.uid).set({
        'email': user.email,
        'firstName': newFirstName,
        'lastName': newLastName,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Try to update Firebase Auth display name (may fail with PigeonUserInfo bug)
      try {
        final newDisplayName = '$newFirstName $newLastName'.trim();
        await user.updateDisplayName(newDisplayName);
      } catch (e) {
        // Ignore PigeonUserInfo error - data is already saved in Firestore
        if (!e.toString().contains('PigeonUserInfo') && 
            !e.toString().contains('PigeonUserDetails')) {
          // If it's a different error, log it but don't fail
          // print('Warning: Failed to update Firebase Auth displayName: $e');
        }
      }

      // Return success with updated data from Firestore
      final updatedDoc = await _firestore.collection('users').doc(user.uid).get();
      if (updatedDoc.exists) {
        final data = updatedDoc.data()!;
        return DataSuccess(UserEntity(
          uid: user.uid,
          email: user.email,
          firstName: data['firstName'] as String?,
          lastName: data['lastName'] as String?,
          profileImageUrl: data['profileImageUrl'] as String?,
        ));
      }
      
      return DataSuccess(UserEntity(
        uid: user.uid,
        email: user.email,
        firstName: newFirstName,
        lastName: newLastName,
      ));
    } catch (e) {
      return DataFailed(Exception(e.toString()));
    }
  }

  @override
  Future<DataState<String>> uploadProfileImage(File imageFile) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return DataFailed(Exception('No user logged in'));
      }

      // Upload to Firebase Storage
      final storageRef = _firebaseStorage
          .ref()
          .child('user_profiles')
          .child(user.uid)
          .child('profile.jpg');

      
      final metadata = SettableMetadata(contentType: 'image/jpeg');
      final uploadTask = await storageRef.putFile(imageFile, metadata);
      
      
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // Update Firestore document (use set with merge to ensure document exists)
      await _firestore.collection('users').doc(user.uid).set({
        'profileImageUrl': downloadUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Try to update Firebase Auth photo URL (may fail with PigeonUserInfo bug)
      try {
        await user.updatePhotoURL(downloadUrl);
      } catch (e) {
        // Ignore PigeonUserInfo error - data is already saved in Firestore
        if (!e.toString().contains('PigeonUserInfo') && 
            !e.toString().contains('PigeonUserDetails')) {
        } else {
        }
      }

      return DataSuccess(downloadUrl);
    } catch (e) {
      // print(' Error type: ${e.runtimeType}');
      return DataFailed(Exception(e.toString()));
    }
  }

  @override
  Future<void> signOut() {
    return _firebaseAuth.signOut();
  }
}
