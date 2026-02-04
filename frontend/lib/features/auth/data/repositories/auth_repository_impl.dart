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
        return DataFailed(Exception('Error al iniciar sesión'));
      }

      // Verificar si el documento del usuario existe en Firestore
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      
      if (!userDoc.exists) {
        // Crear documento si no existe (para usuarios antiguos)
        String firstName = '';
        String lastName = '';
        
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
      
      await Future.delayed(const Duration(milliseconds: 200));
      
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
        // Manejar bug de casteo de Firebase Auth (Pigeon)
        if (e.toString().contains('PigeonUserDetails') || e.toString().contains('PigeonUserInfo')) {
          final currentUser = _firebaseAuth.currentUser;
          return DataSuccess(UserEntity(
            uid: currentUser?.uid ?? '', 
            email: email,
          ));
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
    User? user;
    try {
      // 1. Crear usuario en Firebase Auth
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      user = userCredential.user;
    } catch (e) {
      // Manejar bug de casteo: el usuario suele crearse aunque de error
      if (e.toString().contains('PigeonUserDetails') || e.toString().contains('PigeonUserInfo')) {
        user = _firebaseAuth.currentUser;
      } else {
        return DataFailed(e is Exception ? e : Exception(e.toString()));
      }
    }

    if (user == null) {
      return DataFailed(Exception('No se pudo crear el usuario en Auth'));
    }

    try {
      // 2. Crear documento en Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'profileImageUrl': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 3. Actualizar perfil local de Auth (opcional)
      try {
        final displayName = '$firstName $lastName'.trim();
        await user.updateDisplayName(displayName);
        await user.reload();
      } catch (_) {}

      return DataSuccess(UserEntity(
        uid: user.uid,
        email: email,
        firstName: firstName,
        lastName: lastName,
      ));
    } catch (e) {
      // Si falla Firestore pero Auth funcionó, devolvemos éxito con los datos conocidos
      return DataSuccess(UserEntity(
        uid: user.uid,
        email: email,
        firstName: firstName,
        lastName: lastName,
      ));
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
        return DataFailed(Exception('Sesión no iniciada'));
      }

      String currentFirstName = firstName ?? '';
      String currentLastName = lastName ?? '';
      
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data();
          if (firstName == null) currentFirstName = data?['firstName'] as String? ?? '';
          if (lastName == null) currentLastName = data?['lastName'] as String? ?? '';
        }
      } catch (_) {}

      final newFirstName = firstName ?? currentFirstName;
      final newLastName = lastName ?? currentLastName;

      await _firestore.collection('users').doc(user.uid).set({
        'email': user.email,
        'firstName': newFirstName,
        'lastName': newLastName,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      try {
        final newDisplayName = '$newFirstName $newLastName'.trim();
        await user.updateDisplayName(newDisplayName);
      } catch (_) {}

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
        return DataFailed(Exception('Sesión no iniciada'));
      }

      final storageRef = _firebaseStorage
          .ref()
          .child('user_profiles')
          .child(user.uid)
          .child('profile.jpg');

      final metadata = SettableMetadata(contentType: 'image/jpeg');
      final uploadTask = await storageRef.putFile(imageFile, metadata);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      await _firestore.collection('users').doc(user.uid).set({
        'profileImageUrl': downloadUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      try {
        await user.updatePhotoURL(downloadUrl);
      } catch (_) {}

      return DataSuccess(downloadUrl);
    } catch (e) {
      return DataFailed(Exception(e.toString()));
    }
  }

  @override
  Future<void> signOut() {
    return _firebaseAuth.signOut();
  }
}
