import '../../../../core/resources/data_state.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<DataState<UserEntity>> login(String email, String password);
  Future<DataState<UserEntity>> register(String email, String password);
  Future<void> signOut();
  Stream<UserEntity?> get authStateChanges;
  UserEntity? getCurrentUser();
}
