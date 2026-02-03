import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/resources/data_state.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;

  AuthRepositoryImpl(this._firebaseAuth);

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
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Wait for auth state to update
      await Future.delayed(const Duration(milliseconds: 200));
      
      // print("Login success: $email");
      return DataSuccess(UserEntity(uid: '', email: email));
      
    } on FirebaseAuthException catch (e) {
      // print("FirebaseAuthException Login: ${e.message}");
      return DataFailed(e);
    } catch (e) {
       // Check if it's the known PigeonUserDetails bug
       if (e.toString().contains('PigeonUserDetails')) {
        //  print("Login success (PigeonUserDetails workaround): $email");
         // This is the type cast bug, but auth actually succeeded
         return DataSuccess(UserEntity(uid: '', email: email));
       }
      //  print("Generic Exception Login: $e");
       return DataFailed(Exception(e.toString()));
    }
  }

  @override
  Future<DataState<UserEntity>> register(String email, String password) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Wait for auth state to update
      await Future.delayed(const Duration(milliseconds: 200));
      
      // print("Register success: $email");
      return DataSuccess(UserEntity(uid: '', email: email));
      
    } on FirebaseAuthException catch (e) {
      // print("FirebaseAuthException Register: ${e.message}");
      return DataFailed(e);
    } catch (e) {
       // Check if it's the known PigeonUserDetails bug
       if (e.toString().contains('PigeonUserDetails')) {
        //  print("Register success (PigeonUserDetails workaround): $email");
         // This is the type cast bug, but auth actually succeeded
         return DataSuccess(UserEntity(uid: '', email: email));
       }
      //  print("Generic Exception Register: $e");
       return DataFailed(Exception(e.toString()));
    }
  }

  @override
  Future<void> signOut() {
    return _firebaseAuth.signOut();
  }
}
