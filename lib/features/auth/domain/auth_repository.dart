import 'package:firebase_auth/firebase_auth.dart';
import 'package:speech_coach/features/auth/domain/user_entity.dart';

abstract class AuthRepository {
  Stream<User?> get authStateChanges;
  User? get currentUser;

  Future<UserEntity> signInWithEmail(String email, String password);
  Future<UserEntity> registerWithEmail(String email, String password, String name);
  Future<UserEntity> signInWithGoogle();
  Future<UserEntity> signInWithApple();
  Future<void> signOut();
  Future<void> resetPassword(String email);
  Future<UserEntity?> getUserProfile(String uid);
  Future<void> updateUserProfile(UserEntity user);
}
