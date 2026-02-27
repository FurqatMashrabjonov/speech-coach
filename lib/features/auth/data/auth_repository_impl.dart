import 'package:firebase_auth/firebase_auth.dart';
import 'package:speech_coach/features/auth/data/auth_remote_datasource.dart';
import 'package:speech_coach/features/auth/domain/auth_repository.dart';
import 'package:speech_coach/features/auth/domain/user_entity.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _datasource;

  AuthRepositoryImpl(this._datasource);

  @override
  Stream<User?> get authStateChanges => _datasource.authStateChanges;

  @override
  User? get currentUser => _datasource.currentUser;

  @override
  Future<UserEntity> signInWithEmail(String email, String password) async {
    final credential = await _datasource.signInWithEmail(email, password);
    return _getUserOrCreate(credential);
  }

  @override
  Future<UserEntity> registerWithEmail(
      String email, String password, String name) async {
    final credential = await _datasource.registerWithEmail(email, password);
    final user = credential.user!;
    await user.updateDisplayName(name);

    final entity = UserEntity(
      uid: user.uid,
      email: email,
      displayName: name,
      photoUrl: user.photoURL,
      createdAt: DateTime.now(),
    );

    await _datasource.saveUserProfile(entity);
    return entity;
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    final credential = await _datasource.signInWithGoogle();
    return _getUserOrCreate(credential);
  }

  @override
  Future<UserEntity> signInWithApple() async {
    final credential = await _datasource.signInWithApple();
    return _getUserOrCreate(credential);
  }

  @override
  Future<void> signOut() async {
    await _datasource.signOut();
  }

  @override
  Future<void> resetPassword(String email) async {
    await _datasource.resetPassword(email);
  }

  @override
  Future<UserEntity?> getUserProfile(String uid) async {
    return await _datasource.getUserProfile(uid);
  }

  @override
  Future<void> updateUserProfile(UserEntity user) async {
    await _datasource.saveUserProfile(user);
  }

  Future<UserEntity> _getUserOrCreate(UserCredential credential) async {
    final user = credential.user!;

    // Try Firestore profile, but don't block sign-in if it fails
    var profile = await _datasource.getUserProfile(user.uid);
    if (profile == null) {
      profile = UserEntity(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
        photoUrl: user.photoURL,
        createdAt: DateTime.now(),
      );
      // Save in background — don't block sign-in
      _datasource.saveUserProfile(profile);
    }

    return profile;
  }
}
